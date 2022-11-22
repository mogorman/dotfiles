#!/usr/bin/env bash

sudo cryptsetup luksOpen disk_image drive_a
sudo systemctl start mount_drive.target 
