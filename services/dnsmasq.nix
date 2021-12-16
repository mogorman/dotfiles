{ config, lib, pkgs, ... }: {
  services.dnsmasq = {
    enable = true;
    servers = [ "8.8.8.8" "8.8.4.4" ];
    extraConfig = ''
      local=/lan/
      domain=lan
      expand-hosts

      interface=lan0
      dhcp-range=lan0,10.0.2.10,10.0.2.244,24h

      interface=guest0
      dhcp-range=guest0,10.0.10.10,10.0.10.244,24h

      interface=iot0
      dhcp-range=iot0,10.0.100.10,10.0.100.244,24h

      bind-interfaces

      no-negcache
      dhcp-host=8c:fe:74:17:29:e0,r610,10.0.2.251
      dhcp-host=1c:b9:c4:36:0f:00,r600,10.0.2.252
      dhcp-host=1c:b9:c4:07:f1:50,r310,10.0.2.253
      dhcp-host=b4:69:21:62:5a:c5,reddirk,10.0.100.30
      dhcp-host=34:68:95:a6:f4:06,printer,10.0.100.100
    '';
  };
}
