{ config, lib, pkgs, ... }: {

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    nmap
    git
    nixfmt
    git-crypt
    gnupg
    pinentry
    pinentry-curses
    pciutils
    docker
    docker-compose
    htop
    sshfs
    lsof
    youtube-dl
    screen
  ];

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "curses";
  };
  virtualisation.docker.enable = true;

}
