{ config, lib, pkgs, ... }: {
services.nginx = {
enable = true;
virtualHosts."rldn.net" = {
    addSSL = true;
    enableACME = true;
    root = "/external/02tb/state/nginx/rldn.net";
};
};
}
