{ config, lib, pkgs, ... }: {

  users.users.tim = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = config.mog_keys;
    extraGroups = [ "docker" "render" "media" "video" "networkmanager" "dialout" ];
  };

}
