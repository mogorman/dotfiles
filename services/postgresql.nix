{ config, lib, pkgs, ... }: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    ensureDatabases = [ "hass" ];
    dataDir = "/state/postgresql/${config.services.postgresql.package.psqlSchema}";
    ensureUsers = [{
      name = "hass";
      ensurePermissions = {
        "DATABASE hass" = "ALL PRIVILEGES";
      };
    }];
  };
}
