{
  host-applications = import ./applications;
  host-feature = import ./feature;
  host-filesystem = import ./filesystem;
  host-hardware = import ./hardware;
  host-network = import ./network;
  host-role = import ./roles/default.nix;
  host-service = import ./service;
}
