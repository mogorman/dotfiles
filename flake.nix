{
  description = "my dotfiles for servers and laptops";

  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    oldeststable.url = "github:NixOS/nixpkgs/nixos-21.11";
    olderstable.url = "github:NixOS/nixpkgs/nixos-22.05";
    oldstable.url = "github:NixOS/nixpkgs/nixos-22.11";
    stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay/master";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "stable";
    frigate-hass-integration = {
      url = "github:blakeblackshear/frigate-hass-integration";
      flake = false;
    };
    ocpp-hass-integration = {
      url = "github:lbbrhzn/ocpp";
      flake = false;
    };
    owlet-hass-integration = {
      url = "github:mogorman/ha-sensor.owlet";
      flake = false;
    };
    dns_block = {
      url = "github:notracking/hosts-blocklists";
      flake = false;
    };
    webrtc-card = {
      url = "github:AlexxIT/WebRTC";
      flake = false;
    };
    sonarr_ha = {
      url = "github:custom-components/sensor.sonarr_upcoming_media";
      flake = false;
    };
    upcoming-media-card = {
      url = "github:custom-cards/upcoming-media-card";
      flake = false;
    };
    zha-network-card = {
      url = "github:dmulcahey/zha-network-card";
      flake = false;
    };
    entity-attributes-card = {
      url = "github:custom-cards/entity-attributes-card";
      flake = false;
    };
    dahua-hass = {
      url = "github:rroller/dahua";
     flake = false;
    };
  };

  outputs = { stable, oldstable, unstable, nixos-hardware, emacs-overlay, flake-utils, ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import stable {
        inherit system;
        config = { allowUnfree = true; };
      };
      lib = stable.lib;
      overlays = {
       oldstable = final: prev: {
          oldstable = (import oldstable {
            inherit system;
            config = { allowUnfree = true; };
          });
        };
        unstable = final: prev: {
          unstable = (import unstable {
            inherit system;
            config = { allowUnfree = true; };
          });
        };
        jellyfin-web = final: prev: {
           jellyfin-web = prev.jellyfin-web.override (oldAttrs: { installPhase = ''
              runHook preInstall
              mkdir -p $out/share
              cp -a dist $out/share/jellyfin-web
              sed  's~</body[^>]*>~<script plugin="Jellyscrub" version="1.0.0.0" mog="true" src="/Trickplay/ClientScript"></script>&~' < dist/index.html > $out/share/jellyfin-web/index.html
              runHook postInstall
           ''; 
         });
         };
      };
    in {
      nixosConfigurations = {
        madrox = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ({ config, pkgs, lib, ... }: {
              nixpkgs.overlays = [
                overlays.unstable
                overlays.oldstable
                emacs-overlay.overlay
                (self: super: {
                  nix-direnv =
                    super.nix-direnv.override { enableFlakes = true; };
                })
             (self: super: {
                   libcamera = super.callPackage packages/libcamera_stable.nix {};
                })
                 ];
            })
            {
              options.dotfiles_dir = lib.mkOption {
                type = lib.types.str;
                default = "/home/mog/code/dotfiles";
              };
              options.camera_password = lib.mkOption {
                type = lib.types.str;
                default = "nope";
              };
              options.mog_keys = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI8RHuXXH4cxrIhuIyRQ2ZrzKHBuzBfHLbCMGGaupOfHzagDTvLjFmSpQrxLzguJ6QYpTOmTUTNv40XvsYvgyQg2FZLO15n/zQ5VxuH+rfmXvjsOIHZJ2Hp6h5MdXwtFWE3wgppuJ58DAldIDv/ZN2F3u84GT6tJNnI1QSaPS/DqF8Z1vqd6kWrughA5GC7byVSj2JAzyPE8CjNW4eRwZlJAYkbq5+BfTNG+KlL4pPCxIs6axcfANZ0Hykdr7F//PP9yvYaPYzm/qEY8KGROTPH1hDfrBBc85WN40Q1XUTNJwHsYUF15LL7pl6hh+i3lmoCFTjsdqPPjJStDsedhPR vhomekey"
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8ZL7Qr293/QIApN5iodPHf0rio/T6KsZYhomrBRZUIpu6THQrBLuop2VmJvqNnULuNz2WfJp220Arj7qLKrxlohkE+rssmYjHYxMuIdcToms+Pr9u1G9vmZ7DX1ms8d/1u7oyx8DQeE966nuVS229mrN8dy6DsfLOIj2ZHWb0Mf5EKiIBLFVR7fakKLkoX50sUVrns70yo5yM2EGQISM6K/pQ4FzbGndEy4x0HoF70406eF7TlKrEic4B8UOKFqe80cTZZTC+bBjeNUrG2EvSL4pFN64pqlRAZJeq2M3j1Ts1WKeewbtb1uJsbAZoM6d9TSffHr5cv/t5abq2KFZll2TzTpAr5zg9OOR80MCKhphoLBWlDOlMBuLtJO/BUVoFGoK1m9Nh+8g4RJAGS8WvQrVbkq6Rbo/rloXuEsXVrxwQwVH7gFj07NIO2322kJxBPaZ32RHnYrPIqAI3tH7Zz5TZrAxwhubVO3ZA65VbzDIFK0VP4hO4nRSaF1VYkm8wXv+LnefRp74FLzBjo1UN6CvBjzU5iWbQNsuGoXeyrarGIv53n6lY3VVtD51iEH2ZQB3Cr7YczJkwGFbe52QhmTAhNGZqd7uNyGJuXOo0NzNXWeXJ+/AbTZ5LtZ90f+/FyJcssyKcJHY6LjtTraN0FueRcFWv2GzKOEJj9cCoKw== cardno:000500006D02"
                ];
              };
            }
            ./system/madrox.nix
          ];
        };

        zaphod = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ({ config, pkgs, lib, ... }: {
              nixpkgs.overlays = [ overlays.unstable overlays.oldstable ];
            })
            {
              options.dotfiles_dir = lib.mkOption {
                type = lib.types.str;
                default = "/home/mog/code/dotfiles";
              };
              options.camera_password = lib.mkOption {
                type = lib.types.str;
                default = "nope";
              };
              options.owlet_password = lib.mkOption {
                type = lib.types.str;
                default = "nope";
              };
              options.mog_keys = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI8RHuXXH4cxrIhuIyRQ2ZrzKHBuzBfHLbCMGGaupOfHzagDTvLjFmSpQrxLzguJ6QYpTOmTUTNv40XvsYvgyQg2FZLO15n/zQ5VxuH+rfmXvjsOIHZJ2Hp6h5MdXwtFWE3wgppuJ58DAldIDv/ZN2F3u84GT6tJNnI1QSaPS/DqF8Z1vqd6kWrughA5GC7byVSj2JAzyPE8CjNW4eRwZlJAYkbq5+BfTNG+KlL4pPCxIs6axcfANZ0Hykdr7F//PP9yvYaPYzm/qEY8KGROTPH1hDfrBBc85WN40Q1XUTNJwHsYUF15LL7pl6hh+i3lmoCFTjsdqPPjJStDsedhPR vhomekey"
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8ZL7Qr293/QIApN5iodPHf0rio/T6KsZYhomrBRZUIpu6THQrBLuop2VmJvqNnULuNz2WfJp220Arj7qLKrxlohkE+rssmYjHYxMuIdcToms+Pr9u1G9vmZ7DX1ms8d/1u7oyx8DQeE966nuVS229mrN8dy6DsfLOIj2ZHWb0Mf5EKiIBLFVR7fakKLkoX50sUVrns70yo5yM2EGQISM6K/pQ4FzbGndEy4x0HoF70406eF7TlKrEic4B8UOKFqe80cTZZTC+bBjeNUrG2EvSL4pFN64pqlRAZJeq2M3j1Ts1WKeewbtb1uJsbAZoM6d9TSffHr5cv/t5abq2KFZll2TzTpAr5zg9OOR80MCKhphoLBWlDOlMBuLtJO/BUVoFGoK1m9Nh+8g4RJAGS8WvQrVbkq6Rbo/rloXuEsXVrxwQwVH7gFj07NIO2322kJxBPaZ32RHnYrPIqAI3tH7Zz5TZrAxwhubVO3ZA65VbzDIFK0VP4hO4nRSaF1VYkm8wXv+LnefRp74FLzBjo1UN6CvBjzU5iWbQNsuGoXeyrarGIv53n6lY3VVtD51iEH2ZQB3Cr7YczJkwGFbe52QhmTAhNGZqd7uNyGJuXOo0NzNXWeXJ+/AbTZ5LtZ90f+/FyJcssyKcJHY6LjtTraN0FueRcFWv2GzKOEJj9cCoKw== cardno:000500006D02"
                ];
              };
            }
            ./system/zaphod.nix
          ];
        };

        random = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ({ config, pkgs, lib, ... }: {
              nixpkgs.overlays = [ overlays.unstable overlays.oldstable overlays.jellyfin-web ];
            })
            {
              options.dotfiles_dir = lib.mkOption {
                type = lib.types.str;
                default = "/home/mog/code/dotfiles";
              };
              options.camera_password = lib.mkOption {
                type = lib.types.str;
                default = "nope";
              };
              options.owlet_password = lib.mkOption {
                type = lib.types.str;
                default = "nope";
              };
              options.mog_keys = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI8RHuXXH4cxrIhuIyRQ2ZrzKHBuzBfHLbCMGGaupOfHzagDTvLjFmSpQrxLzguJ6QYpTOmTUTNv40XvsYvgyQg2FZLO15n/zQ5VxuH+rfmXvjsOIHZJ2Hp6h5MdXwtFWE3wgppuJ58DAldIDv/ZN2F3u84GT6tJNnI1QSaPS/DqF8Z1vqd6kWrughA5GC7byVSj2JAzyPE8CjNW4eRwZlJAYkbq5+BfTNG+KlL4pPCxIs6axcfANZ0Hykdr7F//PP9yvYaPYzm/qEY8KGROTPH1hDfrBBc85WN40Q1XUTNJwHsYUF15LL7pl6hh+i3lmoCFTjsdqPPjJStDsedhPR vhomekey"
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8ZL7Qr293/QIApN5iodPHf0rio/T6KsZYhomrBRZUIpu6THQrBLuop2VmJvqNnULuNz2WfJp220Arj7qLKrxlohkE+rssmYjHYxMuIdcToms+Pr9u1G9vmZ7DX1ms8d/1u7oyx8DQeE966nuVS229mrN8dy6DsfLOIj2ZHWb0Mf5EKiIBLFVR7fakKLkoX50sUVrns70yo5yM2EGQISM6K/pQ4FzbGndEy4x0HoF70406eF7TlKrEic4B8UOKFqe80cTZZTC+bBjeNUrG2EvSL4pFN64pqlRAZJeq2M3j1Ts1WKeewbtb1uJsbAZoM6d9TSffHr5cv/t5abq2KFZll2TzTpAr5zg9OOR80MCKhphoLBWlDOlMBuLtJO/BUVoFGoK1m9Nh+8g4RJAGS8WvQrVbkq6Rbo/rloXuEsXVrxwQwVH7gFj07NIO2322kJxBPaZ32RHnYrPIqAI3tH7Zz5TZrAxwhubVO3ZA65VbzDIFK0VP4hO4nRSaF1VYkm8wXv+LnefRp74FLzBjo1UN6CvBjzU5iWbQNsuGoXeyrarGIv53n6lY3VVtD51iEH2ZQB3Cr7YczJkwGFbe52QhmTAhNGZqd7uNyGJuXOo0NzNXWeXJ+/AbTZ5LtZ90f+/FyJcssyKcJHY6LjtTraN0FueRcFWv2GzKOEJj9cCoKw== cardno:000500006D02"
                ];
              };
            }
            ./system/random.nix
          ];
        };

        trillian = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ({ config, pkgs, lib, ... }: {
              nixpkgs.overlays = [ overlays.unstable overlays.oldstable  ];
            })
            {
              options.dotfiles_dir = lib.mkOption {
                type = lib.types.str;
                default = "/home/mog/code/dotfiles";
              };
              options.camera_password = lib.mkOption {
                type = lib.types.str;
                default = "nope";
              };
              options.owlet_password = lib.mkOption {
                type = lib.types.str;
                default = "nope";
              };
              options.mog_keys = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI8RHuXXH4cxrIhuIyRQ2ZrzKHBuzBfHLbCMGGaupOfHzagDTvLjFmSpQrxLzguJ6QYpTOmTUTNv40XvsYvgyQg2FZLO15n/zQ5VxuH+rfmXvjsOIHZJ2Hp6h5MdXwtFWE3wgppuJ58DAldIDv/ZN2F3u84GT6tJNnI1QSaPS/DqF8Z1vqd6kWrughA5GC7byVSj2JAzyPE8CjNW4eRwZlJAYkbq5+BfTNG+KlL4pPCxIs6axcfANZ0Hykdr7F//PP9yvYaPYzm/qEY8KGROTPH1hDfrBBc85WN40Q1XUTNJwHsYUF15LL7pl6hh+i3lmoCFTjsdqPPjJStDsedhPR vhomekey"
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8ZL7Qr293/QIApN5iodPHf0rio/T6KsZYhomrBRZUIpu6THQrBLuop2VmJvqNnULuNz2WfJp220Arj7qLKrxlohkE+rssmYjHYxMuIdcToms+Pr9u1G9vmZ7DX1ms8d/1u7oyx8DQeE966nuVS229mrN8dy6DsfLOIj2ZHWb0Mf5EKiIBLFVR7fakKLkoX50sUVrns70yo5yM2EGQISM6K/pQ4FzbGndEy4x0HoF70406eF7TlKrEic4B8UOKFqe80cTZZTC+bBjeNUrG2EvSL4pFN64pqlRAZJeq2M3j1Ts1WKeewbtb1uJsbAZoM6d9TSffHr5cv/t5abq2KFZll2TzTpAr5zg9OOR80MCKhphoLBWlDOlMBuLtJO/BUVoFGoK1m9Nh+8g4RJAGS8WvQrVbkq6Rbo/rloXuEsXVrxwQwVH7gFj07NIO2322kJxBPaZ32RHnYrPIqAI3tH7Zz5TZrAxwhubVO3ZA65VbzDIFK0VP4hO4nRSaF1VYkm8wXv+LnefRp74FLzBjo1UN6CvBjzU5iWbQNsuGoXeyrarGIv53n6lY3VVtD51iEH2ZQB3Cr7YczJkwGFbe52QhmTAhNGZqd7uNyGJuXOo0NzNXWeXJ+/AbTZ5LtZ90f+/FyJcssyKcJHY6LjtTraN0FueRcFWv2GzKOEJj9cCoKw== cardno:000500006D02"
                ];
              };
            }
            ./system/trillian.nix
          ];
        };
      };
    };
}
