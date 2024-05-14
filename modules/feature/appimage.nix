{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.appimage;
in
  with lib;
{
  options = {
    host.feature.appimage = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables Support for executing AppImages";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };
}
