{ config, lib, pkgs, ... }: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    ensureDatabases = [ "hass" "tubesync" ];
    dataDir = "/state/postgresql/${config.services.postgresql.package.psqlSchema}";
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all 172.17.0.2/32 trust
      host all all 172.17.0.3/32 trust
      host all all 172.17.0.4/32 trust
      host all all 172.17.0.5/32 trust
      host all all 172.17.0.6/32 trust
         host all all ::1/128 trust
    '';
    ensureUsers = [
      {
      name = "hass";
      ensurePermissions = {
        "DATABASE hass" = "ALL PRIVILEGES";
      };
      }
      {
      name = "tubesync";
      ensurePermissions = {
        "DATABASE tubesync" = "ALL PRIVILEGES";
      };
    }
   ];
  };
}
