{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ripgrep-all
    fd
    river
    tilix
    gnumeric
    vim
    wget
    firefox
    gparted
    vlc
    pciutils
    git
    direnv
    nix-direnv
    lorri
    victor-mono
    psmisc
    curl
    screen
    signal-desktop
    zoom-us
    gimp-with-plugins
    qcad
    dbeaver
    google-chrome
    gpa
    gnupg
    sweethome3d.application
    git-crypt
    kubectl
    krew
    fzf
    libreoffice
    tor
    jellyfin-media-player
    mcfly
    gnome.gnome-remote-desktop
    kdenlive
    kitty
    waybar
    hyprpaper
    pavucontrol
    foot
    playerctl
    pamixer
    light
    ispell
    godot_4
    docker-compose
    nixfmt
    (callPackage ./sdm.nix { })
    (pkgs.writeShellApplication {
      name = "slack";
      text = "${pkgs.slack}/bin/slack --use-gl=desktop";
    })
    (pkgs.makeDesktopItem {
      name = "slack";
      exec = "slack";
      desktopName = "Slack";
      icon = "${pkgs.slack}/share/pixmaps/slack.png";
    })
    (pkgs.writeShellApplication {
      name = "discord";
      text = "${pkgs.discord}/bin/discord --use-gl=desktop";
    })
    (pkgs.makeDesktopItem {
      name = "discord";
      exec = "discord";
      desktopName = "Discord";
      icon = "${pkgs.discord}/share/pixmaps/discord.png";
    })
    (pkgs.writeShellApplication {
      name = "insomnia";
      text = "${pkgs.insomnia}/bin/insomnia --use-gl=desktop";
    })
    (pkgs.makeDesktopItem {
      name = "insomnia";
      exec = "insomnia";
      desktopName = "Insomnia";
      icon = "${pkgs.insomnia}/share/icons/hicolor/256x256/apps/insomnia.png";
    })

    (pkgs.makeDesktopItem {
      name = "emacs";
      exec = "emacs";
      desktopName = "Emacs";
      icon = "/home/mog/code/dotfiles/icons/doom_emacs_icon.png";
    })
    ((pkgs.emacsPackagesFor pkgs.emacs29-pgtk).emacsWithPackages
      (epkgs: (with epkgs; [ vterm multi-vterm ])))
  ];
}
