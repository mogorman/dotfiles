{ lib, stdenv, pkgs, fetchFromGitHub }:

let version = "1.0.16";
in stdenv.mkDerivation {
  pname = "amcrest2mqtt";
  version = "1.0.16";
  patches = [ ../patches/amcrest2mqtt.patch ];
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "dchesterton";
    repo = "amcrest2mqtt";
    rev = "1.0.16";
    sha256 = "sha256-lPtgLLJ/L/xzJz2boLcBhxtik6SZl3t3DhbwTdBvbQ0=";
  };

  buildInputs = [
    (pkgs.unstable.python39.withPackages (pythonPackages:
      with pythonPackages; [
        amcrest
        paho-mqtt
        python-slugify
      ]))
  ];

  meta = with lib; {
    description = "amcrest2mqtt";
    homepage = "https://github.com/dchesterton/amcrest2mqtt";
    license = licenses.mit;
  };

  installPhase = ''
    mkdir -p $out/bin
    echo "#!/usr/bin/env python" > src/amcrest2mqtt
    cat src/amcrest2mqtt.py >> src/amcrest2mqtt
    chmod +x src/amcrest2mqtt

    cp src/amcrest2mqtt $out/bin/
  '';
}
