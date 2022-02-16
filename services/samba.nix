{ config, lib, pkgs, ... }: {
  services.samba-wsdd = {
     discovery = true;
     enable = true;
  };
  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user 
      #use sendfile = yes
      #max protocol = smb2
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      public = {
        path = "/external/06tb/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "media";
        "force group" = "users";
      };
    };
  };
}
