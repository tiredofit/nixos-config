{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.sound;

  script_sound-tool = pkgs.writeShellScriptBin "sound-tool" ''
set -x
    if systemctl --user is-active pipewire >/dev/null 2>&1 && command -v "pw-dump" &>/dev/null && command -v "wpctl" &>/dev/null; then
        backend=pipewire
    elif systemctl --user is-active pulseaudio >/dev/null 2>&1 && command -v "pactl" &>/dev/null; then
        backend=pulseaudio
    else
        echo "ERROR: Can't detect sound backend"
        exit 1
    fi

    case $1 in
        output )
            case $2 in
                cycle )
                    case $backend in
                        pipewire )
                            ## Get current audio outputs and running status
                            output=$(pw-dump | ${pkgs.jq}/bin/jq -r '.[] | select(.info.props."media.class" == "Audio/Sink") | .id, .info.props."node.description", .info.state')

                            array=()
                            switch_next=0

                            # Dump them to an array
                            while IFS= read -r line; do
                                array+=("$line")
                            done <<< "$output"

                            # Loop through array, determine what's running and queue next iteration to be set to new default output
                            for ((i = 0; i < ''${#array[@]}; i=i+3)); do
                                if [ "$switch_next" == 1 ]; then
                                    wpctl set-default ''${array[i]}
                                    switch_next=0
                                fi

                                if [ "''${array[i+2]}" == "running" ]; then
                                    switch_next=1
                                fi
                            done

                                #  If the current running was the last item, make the first element active
                                if [ "$switch_next" == 1 ]; then
                                    wpctl set-default ''${array[0]}
                                    switch_next=0
                                fi

                            # Grab the NEW audio outputs status and display which one is active
                            output=$(pw-dump | ${pkgs.jq}/bin/jq -r '.[] | select(.info.props."media.class" == "Audio/Sink") | .id, .info.props."node.description", .info.state')

                            array=()

                            while IFS= read -r line; do
                                array+=("$line")
                            done <<< "$output"

                            for ((i = 0; i < ''${#array[@]}; i=i+3)); do
                                if [ "''${array[i+2]}" == "running" ]; then
                                    notify-send -h string:x-canonical-private-synchronous:my-notification --expire-time=1000 "''${array[i+1]}"
                                    echo "*''${array[i]} - ''${array[i+1]} - ''${array[i+2]}"
                                else
                                    echo " ''${array[i]} - ''${array[i+1]} - ''${array[i+2]}"
                                fi
                            done
                        ;;
                        pulseaudio )
                            function get_current_sink() {
                                pactl info | ${pkgs.gnused}/bin/sed -En 's/Default Sink: (.*)/\1/p'
                            }

                            sinks=$(pactl list short sinks | grep -v easyeffects)
                            sink_count=$(echo "$sinks" | ${pkgs.coreutils}/bin/wc -l)

                            current_sink=$(get_current_sink)
                            current_sink_index=$(echo "$sinks" | ${pkgs.gnugrep}/bin/grep -n "$current_sink" | ${pkgs.gnugrep}/bin/grep -Eo '^[0-9]+')

                            max_retries=6
                            retries=0

                            while true; do
                                [ "$retries" -ge "$max_retries" ] && echo "Reached retry limit of $max_sink_scripts, giving up." && break

                                new_sink_index=$(((current_sink_index + $retries) % $sink_count + 1))
                                new_sink=$(echo "$sinks" | ${pkgs.gnused}/bin/sed "''${new_sink_index}q;d" | ${pkgs.gawk}/bin/awk '{ print $2 }')

                                #echo "Switching to sink: $new_sink"
                                pactl set-default-sink "$new_sink"

                                [ "$(get_current_sink)" = "$new_sink" ] && break

                                # Note: switching could fail if, for example, the new sink does not have any available output port
                                echo "Failed to switch to sink: $new_sink, skipping to next sink..."
                                retries=$((retries + 1))
                            done
                        ;;
                    esac
                ;;
            esac
        ;;
        mic* )
            case $2 in
                down )
                    case $backend in
                        pipewire )
                            wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%-
                        ;;
                        pulseaudio )
                            pactl set-sink-volume @DEFAULT_SOURCE@ -1
                        ;;
                    esac
                ;;
                mute )
                    case $backend in
                        pipewire )
                            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
                        ;;
                        pulseaudio )
                            pactl set-sink-mute @DEFAULT_SOURCE@ toggle
                        ;;
                    esac
                ;;
                up )
                    case $backend in
                        pipewire )
                            wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 1%+
                        ;;
                        pulseaudio )
                            pactl set-sink-volume @DEFAULT_SOURCE@ +1
                        ;;
                    esac
                ;;
            esac
        ;;
        vol* )
            case $2 in
                down )
                    case $backend in
                        pipewire )
                            wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-
                        ;;
                        pulseaudio )
                            pactl set-sink-volume @DEFAULT_SINK@ -1
                        ;;
                    esac
                ;;
                mute )
                    case $backend in
                        pipewire )
                            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
                        ;;
                        pulseaudio )
                            pactl set-sink-mute @DEFAULT_SINK@ toggle
                        ;;
                    esac
                ;;
                up )
                    case $backend in
                        pipewire )
                            wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+
                        ;;
                        pulseaudio )
                            pactl set-sink-volume @DEFAULT_SINK@ +1
                        ;;
                    esac
                ;;
            esac
        ;;
    esac
    set +x
  '';
in
  with lib;
{
  options = {
    host.hardware.sound = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Sound";
      };
      server = mkOption {
        type = types.str;
        default = "pulseaudio";
        description = "Which sound server (pulseaudio/pipewire)";
      };
    };
  };

  config = {
    environment = mkIf cfg.enable {
      systemPackages = with pkgs; [
        script_sound-tool
      ];
    };

    sound = lib.mkMerge [
      (lib.mkIf (cfg.enable && cfg.server == "pulseaudio") {
        enable = true;
      })

      (lib.mkIf (cfg.enable && cfg.server == "pipewire") {
        enable = false;
      })

     (lib.mkIf (! cfg.enable ) {
        enable = false;
      })
     ];

    hardware.pulseaudio = mkIf (cfg.enable && cfg.server == "pulseaudio") {
      enable = true;
    };

    services.pipewire = mkIf (cfg.enable && cfg.server == "pipewire") {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    security.rtkit = mkIf (cfg.enable && cfg.server == "pipewire") {
      enable = true;
    };

    host.filesystem.impermanence.directories = mkIf (cfg.enable && cfg.server == "pipewire" && config.host.filesystem.impermanence.enable) [
      "/var/lib/pipewire"
    ];
  };
}
