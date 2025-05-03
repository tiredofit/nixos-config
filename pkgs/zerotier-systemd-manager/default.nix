{ lib, buildGoModule, fetchFromGitHub, }:

buildGoModule rec {
  pname = "zerotier-systemd-manager";
  version = "4122208d8ffe8c6b2483ba636f9c4b47f0e97885";

  src = fetchFromGitHub {
    owner = "tiredofit";
    repo = "zerotier-systemd-manager";
    rev = "${version}";
    hash = "sha256-NvRlqPA+6gmt7RdhhF4fcYgr/NbVdUILJ9axx/3QrVk=";
  };

  vendorHash = "sha256-40e/FFzHbWo0+bZoHQWzM7D60VUEr+ipxc5Tl0X9E2A=";
  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Manages systemd per-interface DNS resolution for Zerotier networks";
    homepage = "https://github.com/zerotier/zerotier-systemd-manager";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tiredofit ];
    mainProgram = "zerotier-systemd-manager";
  };
}
