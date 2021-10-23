{
  description = "my dotfiles for servers and laptops";

  inputs = {
    stable.url = "github:NixOS/nixpkgs/nixos-21.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "stable";
  };
  
   outputs = { stable, unstable, flake-utils, ... }: 
   let 
     system = "x86_64-linux";
     pkgs = import stable {
       inherit system;
       config = { allowUnfree = true; };
     };
     lib = stable.lib;
    in {
       nixosConfigurations = {
         random = lib.nixosSystem {
            inherit system;
            modules = [
              ./system/random.nix
            ];
         };
       };
    };
}
