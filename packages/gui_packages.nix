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
    firefox
    gimp-with-plugins
    gnumeric
    libreoffice
    inkscape-with-extensions
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
    dmidecode
    gst_all_1.gstreamer.dev
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    keybinder
    xorg.xhost
    gnome.dconf-editor
    xorg.xeyes
    unstable.gnomeExtensions.pop-shell
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
