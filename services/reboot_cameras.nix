{ config, lib, pkgs, ... }: {
systemd.services.reboot_cameras_task= {
  serviceConfig.Type = "oneshot";
  path = with pkgs; [ bash curl ];
  script = ''
    bash /home/mog/code/dotfiles/scripts/reboot_doorbells.sh
  '';
};
systemd.timers.reboot_cameras_task = {
  wantedBy = [ "timers.target" ];
  partOf = [ "reboot_cameras_task.service" ];
  timerConfig = {
    OnCalendar = "Sun *-*-* 06:20:00";
    Unit = "reboot_cameras_task.service";
  };
};
}

