{ config, lib, inputs, pkgs, ... }: {
  environment.etc = {
    # Creates /etc/nanorc
    adblock_hosts = {
      source = "${inputs.dns_block}/dnsmasq/dnsmasq.blacklist.txt";
    };
    dnsmasq_hosts = {
      text = ''
        10.0.2.1 random
        10.0.2.1 home-assistant.local random.local
            '';

      # The UNIX file mode bits
      #    mode = "0440";
    };
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

      interface=wg0
      bind-interfaces

      no-negcache
      dhcp-host=8c:fe:74:17:29:e0,r610,10.0.2.251
      dhcp-host=1c:b9:c4:36:0f:00,r600,10.0.2.252
      dhcp-host=1c:b9:c4:07:f1:50,r310,10.0.2.253
      dhcp-host=b4:69:21:62:5a:c5,reddirk,10.0.100.30
      dhcp-host=30:05:5c:4d:9d:b6,printer,10.0.2.100
      dhcp-host=9c:8e:cd:32:16:9b,babycam,10.0.100.40
    '';
  };
  containers.adfreenetwork = {
    autoStart = true;
    additionalCapabilities = [ "CAP_NET_ADMIN" ];
    bindMounts = {
      "/rootetc" = {
        hostPath = "/etc";
        isReadOnly = true;
      };
    };
    config = {
      networking.firewall.enable = false;
      services.dnsmasq = {
        enable = true;
        servers = [ "8.8.8.8" "8.8.4.4" ];
        extraConfig = ''
          local=/lan/
          domain=lan
          no-hosts

          except-interface=lo
          interface=lan1
          dhcp-range=lan1,10.0.3.10,10.0.3.244,24h
          address=/floop.com/127.0.0.1

          bind-interfaces

          no-negcache
          conf-file=${inputs.dns_block}/dnsmasq/dnsmasq.blacklist.txt
        '';
      };
    };
  };
}
