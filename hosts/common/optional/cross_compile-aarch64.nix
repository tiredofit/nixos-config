{ config, ... }:

{
  boot = {
    binfmt = {
      emulatedSystems = [ "aarch64-linux" ];        # Allow to build aarch64 binaries
    };
  };
}