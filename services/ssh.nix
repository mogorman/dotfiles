{ config, lib, pkgs, ... }: {
  programs.ssh.hostKeyAlgorithms = [ "ssh-rsa" "ecdsa-sha2-nistp256" "ssh-ed25519" ];
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
