{lib, ...}:

with lib;
{
  imports = [
    ./docker_container_manager.nix
    ./eternal_terminal.nix
    ./logrotate.nix
    ./ssh.nix
    ./vscode_server.nix
    ./zabbix_agent.nix
  ];
}
