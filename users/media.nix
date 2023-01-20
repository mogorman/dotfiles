{ config, lib, pkgs, ... }: {

  users.users.media = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = config.mog_keys;
    extraGroups = [ "media" "video" "render" "docker" ];
  };

}
