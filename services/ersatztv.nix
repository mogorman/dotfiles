{ config, lib, pkgs, ... }: {
  systemd.services.ersatztv = {
    description = "ErsatzTV";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    enable = true;
    environment = {
      NIXPATH="nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels";
    };

    path = with pkgs; [ nix ];
    unitConfig = {
      Type="simple";
    };
    serviceConfig = {
      User = "media";
      Group = "users";
      Restart="always";
      ExecStart = "${pkgs.nix}/bin/nix run /home/media/ersatztv";
    };
  };
}
