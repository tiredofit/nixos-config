{ config, lib, pkgs, ... }:
{
  services = {
    deluge = {
      enable = true;
      dataDir = "/var/local/data/deluge";
      declarative = false ;
      authFile = pkgs.writeTextFile {
        name = "deluge-auth";
        text = ''
          localclient::10
        '';
      };
      config = {
        allow_remote = false ;
        add_paused = false;
        auto_managed = true;
        autoadd_enable = false;
        cache_expiry = 60;
        cache_size = 512;
        daemon_port = 58846;
        del_copy_torrent_file = false;
        dht = true;
        dont_count_slow_torrents = true;
        download_location = "/mnt/media/downloads" ;
        enabled_plugins = ["Label" "Stats" ];
        enc_in_policy = 2;
        enc_level = 2;
        enc_out_policy = 2;
        ignore_limits_on_local_network = true;
        info_sent = 0.0;
        listen_ports = [ 6990 ] ;
        listen_random_port = 59103 ;
        listen_reuse_port = true ;
        listen_use_sys_port = false ;
        max_active_downloading = 8;
        max_active_limit = 16;
        max_active_seeding = 1;
        max_connections_global = -1;
        max_connections_per_second = 30;
        max_connections_per_torrent = -1;
        max_half_open_connections = 200;
        max_download_speed = -1.0;
        max_upload_slots_global = 6;
        max_upload_speed = -1.0;
        max_upload_speed_per_torrent = -1;
        move_completed = false;
        move_completed_path = "/var/lib/deluge/complete";
        natpmp = true ;
        new_release_check = false;
        outgoing_ports = [ 6990 6990 ] ;
        pre_allocate_storage = false ;
        prioritize_first_last_pieces = true;
        queue_new_to_top = false;
        random_outgoing_ports = false;
        random_port = false;
        rate_limit_ip_overhead = true;
        remove_seed_at_ratio = true;
        seed_time_limit = 1;
        seed_time_ratio_limit = 0.1;
        send_info = false;
        stop_seed_at_ratio = true;
        stop_seed_ratio = 0.009999999776482582;
        super_seeding = false ;
        torrentfiles_location = "/var/local/data/deluge/torrents";
        upnp = true;
        utpex = true ;
      };
      web = {
        enable = true;
        openFirewall = true ;
        port = 8112;
      };
    };
  };
}
