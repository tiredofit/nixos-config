{ pkgs ? import <nixpkgs> { } }: rec {

    asus-touchpad-numpad = pkgs.python3.pkgs.callPakcage ./asus-touchpad-numbad { };
}