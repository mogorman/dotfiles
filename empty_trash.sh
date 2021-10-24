#!/usr/bin/env bash
sudo nix-env --delete-generations old
sudo nix-collect-garbage
sudo nix-collect-garbage -d
sudo nix-store --gc --print-dead
sudo nix-store --optimise
sudo journalctl --vacuum-size=1M
