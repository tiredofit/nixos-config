{ config, inputs, outputs, lib, pkgs, self, ... }:
  with lib;
{
  imports = [
    inputs.nix-modules.nixosModules
    ./locale.nix
    ./nix.nix
    ../../users
  ];


  boot = {
    initrd = {
      systemd = {
        #strip = mkDefault true;                         # Saves considerable space in initrd
      };
    };
    kernel.sysctl = {
      "vm.dirty_ratio" = mkDefault 6;                   # sync disk when buffer reach 6% of memory
    };
  };

  environment = {
    defaultPackages = [];                               # Don't install any default programs, force everything
    enableAllTerminfo = mkDefault false;
  };

  hardware.enableRedistributableFirmware = mkDefault true;
  host = {
    application = {
      bash.enable = mkDefault true;
      bind.enable = mkDefault true;
      binutils.enable = mkDefault true;
      coreutils.enable = mkDefault true;
      curl.enable = mkDefault true;
      diceware.enable = mkDefault true;
      dust.enable = mkDefault true;
      e2fsprogs.enable = mkDefault true;
      fzf.enable = mkDefault true;
      fping.enable = mkDefault true;
      git.enable = mkDefault true;
      htop.enable = mkDefault true;
      iftop.enable = mkDefault true;
      inetutils.enable = mkDefault true;
      iotop.enable = mkDefault true;
      iperf.enable = mkDefault true;
      lazydocker.enable = mkDefault true;
      less.enable = mkDefault true;
      links.enable = mkDefault true;
      liquidprompt.enable = mkDefault false;
      lsof.enable = mkDefault true;
      lnav.enable = mkDefault true;
      mtr.enable = mkDefault true;
      nano.enable = mkDefault true;
      ncdu.enable = mkDefault true;
      net-tools.enable = mkDefault true;
      pciutils.enable = mkDefault true;
      psmisc.enable = mkDefault true;
      reptyr.enable = mkDefault true;
      ripgrep.enable = mkDefault true;
      rsync.enable = mkDefault true;
      starship.enable = mkDefault false;
      strace.enable = mkDefault true;
      tmux.enable = mkDefault true;
      wget.enable = mkDefault true;
      zoxide.enable = mkDefault true;
      zsh.enable = mkDefault false;
    };
    configDir = self.outPath;
    feature = {
      console.terminfo = {
        ghostty.enable = mkDefault true;
        kitty.enable = mkDefault true;
      };
      home-manager.enable = mkDefault true;
      secrets.enable = mkDefault true;
    };
    network = {
      domainname = mkDefault "tiredofit.ca";
    };
    service = {
      herald = {
        general = {
          log_level = mkDefault "verbose";
        };
        inputs = {
          docker_pub = mkDefault {
            type = "docker";
            api_url = "unix:///var/run/docker.sock";
            expose_containers = false;
            process_existing = true;
            record_remove_on_stop = true;
            filter = [
              {
                type = "label";
                conditions = [
                  {
                    key = "traefik.proxy.visibility";
                    value = "public";
                  }
                  {
                    key = "traefik.proxy.visibility";
                    value = "any";
                    logic = "or";
                  }
                ];
              }
            ];
          };
          docker_int = mkDefault {
            type = "docker";
            api_url = "unix:///var/run/docker.sock";
            expose_containers = false;
            process_existing = true;
            record_remove_on_stop = true;
            filter = [
              {
                type = "label";
                conditions = [
                  {
                    key = "traefik.proxy.visibility";
                    value = "internal";
                  }
                  {
                    key = "traefik.proxy.visibility";
                    value = "any";
                    logic = "or";
                  }
                ];
              }
            ];
          };
        };
        domains = {
          domain01 = mkDefault {
            profiles = {
              inputs = [ "docker_pub" ];
              outputs = [ "output01" ];
            };
          };
          domain02 = mkDefault {
            profiles = {
              inputs = [ "docker_int" ];
              outputs = [ "output02"];
            };
          };
        };
      };
      logrotate = {
        enable = mkDefault true;
      };
      ssh = {
        enable = mkDefault true;
        harden = mkDefault true;
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableGlobalCompInit = mkDefault false;
  };
  programs.starship = {
    settings = {
      scan_timeout = 35;
      command_timeout = 700;
      add_newline = false;
      format = "$time\\[$username$hostname$directory\\] $character";
      right_format = "$php$nix_shell$docker_context$golang$direnv$memory_usage$battery";

      time = {
        disabled = false;
        format = "[$time]($style) ";
        time_format = "%T";
        style = "bold blue";
      };

      username = {
        style_user = "white bold";
        style_root = "black bold";
        format = "[$user]($style)";
        disabled = false;
        show_always = true;
      };

      hostname = {
        ssh_only = true;
        format = "[$ssh_symbol](bold blue)@[$hostname](bold yellow):";
        trim_at = ".";
        disabled = false;
      };

      directory = {
        truncation_length = 8;
        truncation_symbol = "…/";
        format = "[$path]($style)[$read_only]($read_only_style)";
      };

      character = {
        success_symbol = "[\\$](bold green)";
        error_symbol = "[✗](bold red)";
      };

      direnv = {
        disabled = false;
        format = "[$loaded/$allowed]($style)";
        symbol = "";
        style = "bold green";
        allowed_msg = "✅";
        denied_msg = "❌";
        loaded_msg = "●";
      };

      php = {
        format = "🐘";
      };

      nix_shell = {
        symbol = "❄️";
        format = "[$symbol$state]($style) ";
        impure_msg = "[I](bold red)";
        pure_msg = "[P](bold green)";
        unknown_msg = "[U](bold yellow)";
      };

      golang = {
        format = "🐹(bold cyan)";
      };

      docker_context = {
        disabled = false;
        format = "🐋 [$context](blue bold)";
        detect_files = [ "compose.yml" "compose.yaml" "docker-compose.yml" "docker-compose.yaml" "Dockerfile" "Containerfile" ];
      };

      memory_usage = {
        disabled = false;
        threshold = 70;
        style = "bold dimmed green";
        format = "$symbol [$''{ram}]($style) ";
      };

      battery = {
        full_symbol = "🔋 ";
        display = [
            { threshold = 10; style = "bold red"; }
            { threshold = 50; style = "bold yellow"; }
            { threshold = 70; style = "bold green"; }
        ];
      };

      cmd_duration = {
        min_time = 500;
        format = "[$duration](bold yellow)";
      };

      git_branch = {
        symbol = "🌱 ";
        truncation_length = 4;
        truncation_symbol = "";
        ignore_branches = [ "main" ];
      };

      git_commit = {
        commit_hash_length = 4;
        tag_symbol = "🔖 ";
      };

      git_state = {
        format = "[\\($state( $progress_current of $progress_total)\\)]($style) ";
      };

      git_metrics = {
        added_style = "bold blue";
      };

      git_status = {
        ahead = "⇡$''{count}";
        diverged = "⇕⇡$''{ahead_count}⇣$''{behind_count}";
        behind = "⇣$''{count}";
      };

      status = {
        style = "bg:blue";
        format = "[\\[$symbol$common_meaning$signal_name$maybe_int\\]]($style) ";
        map_symbol = true;
        disabled = false;
      };
    };
  };
  security = {
    pam.loginLimits = [
      {
        domain = "@wheel";
        item = "nofile";
        type = "soft";
        value = "524288";
      }
      {
        domain = "@wheel";
        item = "nofile";
        type = "hard";
        value = "1048576";
      }
    ];
    sudo.wheelNeedsPassword = mkDefault false;
  };

  services.fstrim.enable = mkDefault true;
  users.mutableUsers = mkDefault false;
}
