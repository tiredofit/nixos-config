{ pkgs ? import <nixpkgs> { } }: rec {

  asus-touchpad-numpad = pkgs.python3.pkgs.callPackage ./asus-touchpad-numpad { };
}