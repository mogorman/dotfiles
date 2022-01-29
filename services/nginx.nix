{ config, lib, pkgs, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "home.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:2099";
        extraConfig = ''
                 
                  satisfy any;    

          allow 10.0.2.1/24;
          allow 127.0.0.1;
                  deny  all;

                  auth_basic           "weymouth area";
                  auth_basic_user_file ${./../secrets/htpasswd}; 

             '';
       };
       "hass.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:8123";

          extraConfig = ''
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 86400;
                proxy_connect_timeout 10;
          '';
      };
       "jelly.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:8096";
      };
      "tv.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:8989";
        extraConfig = ''
                 
                  satisfy any;    

          allow 10.0.2.1/24;
          allow 127.0.0.1;
                  deny  all;

                  auth_basic           "weymouth area";
                  auth_basic_user_file ${./../secrets/htpasswd}; 

             '';
      };
      "movies.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:7878";
        extraConfig = ''
                 
                  satisfy any;    

          allow 10.0.2.1/24;
          allow 127.0.0.1;
                  deny  all;

                  auth_basic           "weymouth area";
                  auth_basic_user_file ${./../secrets/htpasswd}; 

             '';
      };
       "ogormanvein.com" = {
        forceSSL = true;
        useACMEHost = "ogormanvein.com";

        locations."/" = {
          root = "/var/www/ogormanvein.com";
          extraConfig = ''
            autoindex on;
            autoindex_localtime on;
          '';
 
      };
     };
    };
  };
}
