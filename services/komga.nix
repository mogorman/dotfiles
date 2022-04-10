{ config, lib, pkgs, ... }: {
  systemd.services.komga = {
    description = "komga comics";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "media";
      Group = "users";
      StateDirectory = "komga";
      CacheDirectory = "komga";
      WorkingDirectory="/external/06tb/state/komga";
      ExecStart = "${pkgs.adoptopenjdk-jre-bin}/bin/java -jar ${
          (pkgs.callPackage ../packages/komga.nix { })
        }/bin/komga.jar --server.address=127.0.0.1 --server.port=4123 --komga.config-dir=/external/06tb/state/komga";
    };
  };
}
