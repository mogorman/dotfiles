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
    #youtube-dl
    screen
    ethtool
    tcpdump
    conntrack-tools
    mcfly
    direnv
    nix-direnv
    usbutils
    unstable.jellyfin-ffmpeg
    gitit
    wireguard-tools
    ccextractor
    unstable.bazarr
    libva-utils
    intel-gpu-tools
    esptool
    kubectl
    krew
    fzf
    #pass-otp
    psmisc
    powertop
    ripgrep
    coreutils
    fd
    nix-index
    borgbackup
    syncthing
    imagemagick
    tor
    (callPackage ./mog_esphome.nix { })
    (callPackage ./sdm.nix { })
    (callPackage ./amcrest2mqtt.nix { })
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
