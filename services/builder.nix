{ config, pkgs, ... }:

{
	nix.buildMachines =  [{
	 hostName = "10.0.42.4";
	 system = "x86_64-linux";
	 maxJobs = 64;
	 speedFactor = 2;
	 supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
	 mandatoryFeatures = [ ];
         sshUser = "root";
         sshKey = "/home/mog/code/dotfiles/secrets/nix_builder";
	}];
	nix.distributedBuilds = true;
	# optional, useful when the builder has a faster internet connection than yours
	nix.extraOptions = ''
		builders-use-substitutes = true
	'';
}
