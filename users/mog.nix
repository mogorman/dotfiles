{ config, lib, pkgs, ... }: {

  users.users.mog = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = config.mog_keys;
    extraGroups = [ "wheel" "docker" "render" "media" "video" "networkmanager" "dialout" ];
  };

}
