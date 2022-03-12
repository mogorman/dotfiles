{ config, lib, pkgs, ... }: {
  systemd.services."systemd-nspawn@debian".serviceConfig.ExecStart = ''
    ${config.systemd.package}/bin/systemd-nspawn --quiet --keep-unit --boot --link-journal=try-guest  --settings=override --machine=debian
  '';
  systemd.nspawn.debian = {
    enable = false;

    filesConfig = {
      Bind = [ "/dev/dri" "/dev/shm" "/dev/snd" "/run/user/1000/pulse:/run/user/host/pulse" ];
      BindReadOnly = [
        "/tmp/.X11-unix/"
      ];
    };
    networkConfig= { Private=false;};
    execConfig = {
      Boot = true;
      Environment = [ "DISPLAY=:0" ];
      Private = false;
    };
  };
}
