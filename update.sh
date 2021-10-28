#!/usr/bin/env bash
nix flake update
wget -O ./hass/frontend/frigate-hass-card.js https://github.com/dermotduffy/frigate-hass-card/releases/latest/download/frigate-hass-card.js
wget -O ./hass/frontend/simple-thermostat.js https://github.com/nervetattoo/simple-thermostat/releases/latest/download/simple-thermostat.js
