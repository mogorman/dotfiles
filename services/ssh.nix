{ config, lib, pkgs, ... }: {
  services.openssh.enable = true;
  services.openssh.hostKeys = [
    {
      bits = 4096;
      path =
        "${config.dotfiles_dir}/secrets/keys/${config.networking.hostName}_ssh_host_rsa_key";
      type = "rsa";
    }
    {
      path =
        "${config.dotfiles_dir}/secrets/keys/${config.networking.hostName}_ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
}
