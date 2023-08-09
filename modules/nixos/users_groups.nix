{ config, pkgs, ... }:

{
  users.users.dave = {
     description = "Dave Conroy";
     isNormalUser = true;
     home = "/home/dave" ;
     shell = pkgs.bashInteractive ;
     uid = 2323;
     group = "users" ;
     extraGroups = [ "users" "networkmanager" "wheel" "docker" "adbusers" "libvirtd" "input" ];
     openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtKh1vr6m9j0y9T7sf928FcacPbIYP9DHzCv2hQIVPS daveconroy"
     ];
     hashedPassword = "$y$j9T$jEYLXjGrR06/tp76fxyDq/$mX4GTWL7CjVXgAcS5nAHEiT6WIH8uD/IfXj16fuTRQ1";
  };
}
