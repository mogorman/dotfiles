{ config, lib, pkgs, ... }: {
  services.nginx = {
    enable = true;
    package = pkgs.oldstable.nginxStable;
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
      "pepsi.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://10.0.42.2:8080";

        extraConfig = ''
        
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 86400;
                proxy_connect_timeout 10;
        proxy_set_header Host $host;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_buffering off;
             '';

       };


      "syncthing.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:8384";
        extraConfig = ''

                  satisfy any;

          allow 10.0.2.1/24;
          allow 127.0.0.1;
                  deny  all;

                  auth_basic           "weymouth area";
                  auth_basic_user_file ${./../secrets/htpasswd};

             '';
       };
      "frigate.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:5000";
        extraConfig = ''
        add_header Cache-Control no-cache;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 86400;
                proxy_connect_timeout 10;
        proxy_set_header Host $host;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_buffering off;

                  satisfy any;

          allow 10.0.2.1/24;
          allow 10.0.42.1/24;
          allow 127.0.0.1;
                  deny  all;

                  auth_basic           "weymouth area";
                  auth_basic_user_file ${./../secrets/htpasswd};

             '';
       };
      "comics.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:4123";
        extraConfig = ''
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 86400;
                proxy_connect_timeout 10;
        proxy_set_header Host $host;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
             '';
       };
      "zigbee.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:8124";
        extraConfig = ''

                  satisfy any;

          allow 10.0.2.1/24;
          allow 127.0.0.1;
                  deny  all;

                  auth_basic           "weymouth area";
                  auth_basic_user_file ${./../secrets/htpasswd};
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 86400;
                proxy_connect_timeout 10;
        proxy_set_header Host $host;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
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
        extraConfig = ''
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    location = / {
       # return 302 http://$host/web/;
        return 302 https://$host/web/;
    }
    location / {
        # Proxy main Jellyfin traffic
        proxy_pass http://127.0.0.1:8096;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_set_header X-Forwarded-Host $http_host;

        # Disable buffering when the nginx proxy gets very resource heavy upon streaming
        proxy_buffering off;
    }

    # location block for /web - This is purely for aesthetics so /web/#!/ works instead of having to go to /web/index.html/#!/
    location = /web/ {
        # Proxy main Jellyfin traffic
        proxy_pass http://127.0.0.1:8096/web/index.html;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_set_header X-Forwarded-Host $http_host;
    }

    location /socket {
        # Proxy Jellyfin Websockets traffic
        proxy_pass http://127.0.0.1:8096;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_set_header X-Forwarded-Host $http_host;
    }
        '';
      };
      "youtube.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:4848";
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
                  
                  satisfy any;    

          allow 10.0.2.1/24;
          allow 127.0.0.1;
                  deny  all;

                  auth_basic           "weymouth area";
                  auth_basic_user_file ${./../secrets/htpasswd}; 

             '';
      };
      "tv.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:8989";
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
                  
                  satisfy any;    

          allow 10.0.2.1/24;
          allow 127.0.0.1;
                  deny  all;

                  auth_basic           "weymouth area";
                  auth_basic_user_file ${./../secrets/htpasswd}; 

             '';
      };
      "books.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:4849";
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
    client_max_body_size 10000M;
             '';
      };
      "movies.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://127.0.0.1:7878";
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
                 
                  satisfy any;    

          allow 10.0.2.1/24;
          allow 127.0.0.1;
                  deny  all;

                  auth_basic           "weymouth area";
                  auth_basic_user_file ${./../secrets/htpasswd}; 

             '';
      };
      "org.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://10.0.42.2:9000";
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
             '';
      };
      "torrent.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        locations."/".proxyPass = "http://172.17.0.1:8080";
        extraConfig = ''
                 proxy_set_header Host $host;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_redirect off;
    proxy_http_version 1.1;
        proxy_cookie_path  /                  "/; Secure"; 
                  satisfy any;    

          deny 10.0.2.1;
          allow 10.0.2.0/24;
          allow 127.0.0.1;
                  deny  all;

                  auth_basic           "weymouth area";
                  auth_basic_user_file ${./../secrets/htpasswd}; 

             '';
      };
      "octoprint.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";
        extraConfig = ''

proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $http_connection;
proxy_http_version 1.1;
 location / {
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Scheme $scheme;
    proxy_set_header X-Forwarded-Proto  $scheme;
    proxy_set_header X-Forwarded-For    $remote_addr;
    proxy_set_header X-Real-IP		$remote_addr;
    proxy_pass       http://10.0.2.91:80;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    proxy_http_version 1.1;
    proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Scheme https;
client_max_body_size 0;
  }
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
       "www.ogormanvein.com" = {
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
        "rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";

        locations."/" = {
          root = "/var/www/rldn.net";
          extraConfig = ''
            autoindex on;
            autoindex_localtime on;
          '';
 
      };
     };
       "www.rldn.net" = {
        forceSSL = true;
        useACMEHost = "rldn.net";

        locations."/" = {
          root = "/var/www/rldn.net";
          extraConfig = ''
            autoindex on;
            autoindex_localtime on;
          '';
 
      };
     };
    };
};
}
