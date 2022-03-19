{ config, lib, pkgs, ... }:

{
 services.syncthing = {
    enable = true;
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    devices = {
      "madrox" = { id = "6IHF6AO-WO3N2QR-OTXFG73-NDBK5I6-DDOG4TD-KPP6OWG-SKLAFIK-B7ZXMQ5"; };
    };
    folders = {
      "share" = {        # Name of folder in Syncthing, also the folder ID
        path = "/external/06tb/state/syncthing/share";    # Which folder to add to Syncthing
        devices = [ "madrox" ];      # Which devices to share the folder with
      };
    };
  };
}
