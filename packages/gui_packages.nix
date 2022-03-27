{ config, lib, pkgs, ... }: 
let 
    mog_zoom = pkgs.zoom-us.overrideAttrs (old: {
      postFixup = old.postFixup + ''
        wrapProgram $out/bin/zoom-us --unset XDG_SESSION_TYPE
      '';});
in {
  environment.systemPackages = with pkgs; [
    audacity
    dbeaver
    discord
    godot
    google-chrome
    gparted
    slack
    drawio
    mog_zoom
    insomnia
    sweethome3d.application
    teams
    gnome3.vinagre
    gnome.dconf-editor
    gnome.gnome-tweaks
    gnomeExtensions.gsconnect
    gnomeExtensions.freon
    gnomeExtensions.gtile
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.caffeine
    gnomeExtensions.bluetooth-quick-connect
    gnomeExtensions.gnome-bedtime
    gnomeExtensions.rounded-corners
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.timepp
    gnomeExtensions.syncthing-indicator
    gnomeExtensions.unite
    gnomeExtensions.wireguard-indicator
    gnomeExtensions.screen-autorotate
    unstable.gnomeExtensions.useless-gaps
    unstable.gnomeExtensions.pop-shell
    firefox
    gimp-with-plugins
    gnumeric
    libreoffice
    inkscape-with-extensions
    openscad
    ecryptfs
    ecryptfs-helper
    jellyfin-media-player
    tilix
    vlc
    gpa
    signal-desktop

    lm_sensors
    waydroid
    dmidecode
    gst_all_1.gstreamer.dev
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    keybinder
    xorg.xhost

    xorg.xeyes

    unstable.pika-backup
    vorta
    #gnome-network-displays
    krita
    #(callPackage ../packages/fildem.nix { })
  ];

  services.emacs = {
    enable = true;
    package = ((pkgs.emacsPackagesGen pkgs.emacsPgtkGcc).emacsWithPackages
      (epkgs:
        (with epkgs; [
          vterm
          use-package
          direnv
          company
          dashboard
          flycheck
          counsel
          counsel-projectile
          magit
          emacsql-sqlite
          #          forge
          #          emacsql
          magit-popup
          projectile
          lsp-mode
          lsp-ui
          company-quickhelp
        ])));
  };
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  powerManagement.powertop.enable = true;
  environment.variables = {
    VISUAL = "emacsclient";
    EDITOR = "emacsclient";
  };
  environment.sessionVariables = {
   MOZ_ENABLE_WAYLAND = "1";
  };

  programs.steam.enable = true;
  virtualisation.waydroid.enable = true;
}
