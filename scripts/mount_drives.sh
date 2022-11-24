#!/usr/bin/env bash

sudo cryptsetup luksOpen /dev/disk/by-uuid/2eba0bac-7bf4-4207-a695-78e064c57665 drive_1
sudo cryptsetup luksOpen /dev/disk/by-uuid/261ffed2-dcc2-4f1d-b9c8-7222510bfbb4 drive_2
sudo cryptsetup luksOpen /dev/disk/by-uuid/8702cb62-ad8f-4925-9595-e6c30bbb501a drive_3
sudo cryptsetup luksOpen /dev/disk/by-uuid/88c2c241-b24c-4420-881f-be7df6663734 drive_4
sudo systemctl start mount_drive.target 
