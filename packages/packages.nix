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
    ethtool
    tcpdump
    conntrack-tools
    mcfly
    direnv
    nix-direnv
    usbutils
    ffmpeg-full
    gitit
    wireguard-tools
    ccextractor
    unstable.bazarr
    libva-utils
    intel-gpu-tools
    (callPackage ./mog_esphome.nix { })
    esptool
    (callPackage ./sdm.nix { })
    kubectl
    krew
    fzf
    pass-otp
    psmisc
  ];

  programs.bash.shellInit = ''
    export JAVA_TOOL_OPTIONS="-Dcom.eteks.sweethome3d.j3d.useOffScreen3DView=true"
      '';
  programs.bash.interactiveShellInit = ''
    eval "$(${pkgs.direnv}/bin/direnv hook bash)"
    eval "$(${pkgs.mcfly}/bin/mcfly init bash)"
      '';
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  virtualisation.docker = { enable = true; };
}
