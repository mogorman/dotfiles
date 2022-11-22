{ config, lib, pkgs, ... }:

{
  systemd.targets.mount_drive = {
    enable = true;
    requires = [ "export-drive_a.mount" "nfs-mountd.service" "nfs-server.service" ];
    after = [ "export-drive_a.mount" "allowSecretsDirAccess.service" "nfs-server.service" ];
  };

  systemd.services.nfs-mountd = { 
    wantedBy = lib.mkForce [ ];
   };

  systemd.services.nfs-server = { 
    wantedBy = lib.mkForce [ ];
   };

  services.nfs.server = {
    enable = true;
    exports = ''
            /export 10.0.42.0/24(rw,fsid=0,no_subtree_check,insecure,no_root_squash) 10.0.2.1(rw,fsid=0,no_subtree_check,insecure,no_root_squash)  10.0.2.201(rw,fsid=0,no_subtree_check,insecure,no_root_squash) 
            /export/drive_a 10.0.42.0/24(rw,no_subtree_check,insecure,no_root_squash) 10.0.2.1(rw,no_subtree_check,insecure,no_root_squash)  10.0.2.201(rw,no_subtree_check,insecure,no_root_squash) 
    '';
  };
}
