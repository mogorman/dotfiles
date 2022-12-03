{ config, lib, pkgs, ... }: {
systemd.services.disable_ethernet= {
  serviceConfig.Type = "oneshot";
  wantedBy = [ "basic.target" ];
  description = "disable usb ethernet device";
  enable = true;
  path = with pkgs; [ kmod ];
  script = ''
     modprobe  -r ax88179_178a
  '';
};
}

