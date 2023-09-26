{ config, inputs, lib, pkgs, ...}:

let
  programs = lib.makeBinPath [inputs.hyprland.packages.default];
in
  with lib;
  with pkgs;
  {
    unplugged = pkgs.writeShellScript "unplugged" ''
      export PATH=$PATH:${programs}
      if command -v "Hyprland" &>/dev/null; then
        export HYPRLAND_INSTANCE_SIGNATURE=$(ls -w1 /tmp/hypr | tail -1)
        hyprctl --batch 'keyword decoration:drop_shadow 0 ; keyword animations:enabled 0'
      fi

      if command -v "nextcloud" &>/dev/null ; then
        systemctl --user stop nextcloud
      fi

      if command -v "easyeffects" &>/dev/null ; then
        systemctl --user stop easyeffects
      fi

      cpupower frequency-set -g powersave
    '';

    plugged = pkgs.writeShellScript "plugged" ''
      export PATH=$PATH:${programs}

      if command -v "Hyprland" &>/dev/null; then
        export HYPRLAND_INSTANCE_SIGNATURE=$(ls -w1 /tmp/hypr | tail -1)
        hyprctl --batch 'keyword decoration:drop_shadow 1 ; keyword animations:enabled 1'
      fi

      if command -v "nextcloud" &>/dev/null ; then
        systemctl --user start nextcloud
      fi

      if command -v "easyeffects" &>/dev/null ; then
        systemctl --user start easyeffects
      fi

      cpupower frequency-set -g performance
    '';
}
