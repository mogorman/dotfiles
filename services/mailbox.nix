{ config, lib, pkgs, ... }: {
  containers.mailbox = {
    autoStart = true;
    privateNetwork=true;
    
    hostAddress = "10.0.2.1";
    localAddress = "10.0.2.42";
    additionalCapabilities = [ "CAP_NET_ADMIN" ];
    bindMounts = {
      "/etc/resolv.conf" = {
        hostPath = "${../secrets/resolv.conf}";
        isReadOnly = true;
      };
      "/external/16tb/mailbox/" = {
        hostPath = "/external/16tb/mailbox/";
        isReadOnly = false;
      }; 
};
    config = {
      environment.systemPackages = with pkgs; [ openssh curl dig ];
      networking.firewall.enable = false;
      networking.useHostResolvConf = false;
      networking.wireguard.enable = true;
      networking.interfaces.eth0.ipv4.routes = [{
        address = "107.189.13.165";
        prefixLength = 32;
        via = "10.0.42.1";
      }];
 systemd = {
    packages = [ pkgs.qbittorrent-nox ];

    services."qbittorrent-nox" = {
      enable = true;
      serviceConfig = {
        Type = "simple";
        User = "media";
        ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
  users.users.mail = {
    isNormalUser = true;
    uid = 1002;
    extraGroups = [ "mail" ];
  };


      networking.wireguard.interfaces = {
        # "wg0" is the network interface name. You can name the interface arbitrarily.
        seed0 = {
          # Determines the IP address and subnet of the client's end of the tunnel interface.
          ips = [ "10.0.0.4/24" ];
          listenPort =
            51821; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

          # Path to the private key file.
          #
          # Note: The private key can also be included inline via the privateKey option,
          # but this makes the private key world-readable; thus, using privateKeyFile is
          # recommended.
          privateKeyFile = "${../secrets/wireguard/seedbox_key}";
          peers = [
            # For a client configuration, one peer entry for the server will suffice.

            {
              # Public key of the server (not a file path).
              # publicKey = "mGDiPjcuGqkC8usbMdvSJyqgl8xWfD/tBAsOOhdk8XM="; # s
               publicKey = "NaAiNsoYKxkjTjv29zx9+YSjZuoIXc8iydjNNbYbxVQ="; #s2
              # Forward all the traffic via VPN.
              allowedIPs = [ "0.0.0.0/0" ];

              # Set this to the server IP and port.
              endpoint = "107.189.13.165:51820";

              # Send keepalives every 25 seconds. Important to keep NAT tables alive.
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };
}
