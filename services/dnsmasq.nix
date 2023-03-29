{ config, lib, inputs, pkgs, ... }: {
  environment.etc = {
    # Creates /etc/nanorc
    adblock_hosts = {
      source = "${inputs.dns_block}/dnsmasq/dnsmasq.blacklist.txt";
    };
    dnsmasq_hosts = {
      text = ''
        10.0.2.1 zaphod rldn.net.
        10.0.2.2 random home-assistant.local random.local jelly.rldn.net tv.rldn.net movies.rldn.net torrent.rldn.net books.rldn.net hass.rldn.net frigate.rldn.net octoprint.rldn.net pb.rldn.net youtube.rldn.net habitica.rldn.net
            '';

      # The UNIX file mode bits
      #    mode = "0440";
    };
  };
  systemd.services.dnsmasq = {
    path = [ pkgs.dnsmasq pkgs.bash pkgs.curl ];
  };
  services.dnsmasq = {
    enable = true;
    servers = [ "8.8.8.8" "8.8.4.4" ];
    extraConfig = ''
      local=/lan/
      domain=lan
      no-hosts
      addn-hosts=/etc/dnsmasq_hosts

      interface=lan0
      dhcp-range=lan0,10.0.2.10,10.0.2.244,24h

      interface=guest0
      dhcp-range=guest0,10.0.10.10,10.0.10.244,24h

      interface=iot0
      dhcp-range=iot0,10.0.100.10,10.0.100.244,24h

      dhcp-script=${../scripts/dnsmasq_script.sh}

      no-negcache
      dhcp-host=7a:24:f6:87:9b:3a,random,10.0.2.2
      dhcp-host=8c:fe:74:17:29:e0,r610,10.0.2.251
      dhcp-host=1c:b9:c4:36:0f:00,r600,10.0.2.252
      dhcp-host=1c:b9:c4:07:f1:50,r310,10.0.2.253
      dhcp-host=b8:27:eb:39:c4:7f,octoprint,10.0.2.91


      dhcp-host=b4:69:21:62:5a:c5,reddirk,10.0.100.30
      dhcp-host=30:05:5c:4d:9d:b6,printer,10.0.2.100
      dhcp-host=9c:8e:cd:32:16:9b,babycam,10.0.100.40
      dhcp-host=9c:8e:cd:30:9b:d5,frontdoor,10.0.100.41
      dhcp-host=9c:8e:cd:37:d0:08,sidedoor,10.0.100.42

    '';
  };
#  containers.adfreenetwork = {
#    autoStart = true;
#    additionalCapabilities = [ "CAP_NET_ADMIN" ];
#    bindMounts = {
#      "/rootetc" = {
#        hostPath = "/etc";
#        isReadOnly = true;
#      };
#    };
#    config = {
#      networking.firewall.enable = false;
#      services.dnsmasq = {
#        enable = true;
#        servers = [ "8.8.8.8" "8.8.4.4" ];
#        extraConfig = ''
#          local=/lan/
#          domain=lan
#          no-hosts
#
#          except-interface=lo
#          interface=lan1
#          dhcp-range=lan1,10.0.3.10,10.0.3.244,24h
#          address=/floop.com/127.0.0.1
#
#          bind-interfaces
#
#          no-negcache
#          conf-file=${inputs.dns_block}/dnsmasq/dnsmasq.blacklist.txt
#        '';
#      };
#    };
#  };
}
