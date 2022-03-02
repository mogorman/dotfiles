{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    audacity
    dbeaver
    discord
    godot
    google-chrome
    gparted
    slack
    zoom-us
    insomnia
    sweethome3d.application
    teams
    gnome3.vinagre
    firefox
    gimp-with-plugins
    gnumeric
    libreoffice
    inkscape
    openscad
    ecryptfs
    ecryptfs-helper
    gnome.gnome-tweaks
    jellyfin-media-player
    tilix
    vlc
    gpa
    signal-desktop
    gnomeExtensions.gsconnect
    lm_sensors
    waydroid
    unstable.libcamera
    dmidecode
    gst_all_1.gstreamer.dev
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    keybinder
    #(callPackage ../packages/fildem.nix { })
    ((pkgs.emacsPackagesGen pkgs.emacsPgtkGcc).emacsWithPackages (epkgs:
      (with epkgs; [
        vterm
        use-package
        direnv
        darkokai-theme
        company
        dashboard
        flycheck
        counsel
        counsel-projectile
        magit
        #          forge
        #          emacsql
        magit-popup
        projectile
        lsp-mode
        lsp-ui
        company-quickhelp
        #          elixir-mode
        #          exunit
        #          erlang
      ])))
  ];

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

  programs.steam.enable = true;
  virtualisation.waydroid.enable = true;
}
