{ config, lib, pkgs, ... }: {
services.avahi = {
  enable = true;
  reflector = false;
  ipv6 = false;
  nssmdns = true;
  publish = {
    enable = true;
    addresses = true;
    userServices = true;
    workstation = true;
    hinfo = true;
    domain = true;
  };
  interfaces = [
    "lan0"
    "iot0"
  ];

  extraServiceFiles = {
    ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
    home-assistant = ''
      <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name replace-wildcards="yes">%h</name>
            <host-name>home-assistant.local</host-name>
        <service>
          <type>_http._tcp</type>
          <port>8123</port>
        </service>
      </service-group>
    '';
  };
};

}
