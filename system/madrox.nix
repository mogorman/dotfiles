{ config, lib, pkgs, inputs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./common.nix
    ../secrets/secrets.nix
    ../packages/packages.nix
    ../users/mog.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
