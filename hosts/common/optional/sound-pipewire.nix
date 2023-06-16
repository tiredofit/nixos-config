{ config, ...}:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.rtkit.enable = true;
  sound.enable = false;
  hardware.pulseaudio.enable = false;
}