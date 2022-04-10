{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation {
  pname = "komga";
  version = "0.153.2";

  src = fetchurl {
    url = "https://github.com/gotson/komga/releases/download/v0.153.2/komga-0.153.2.jar";
    sha256 = "sha256-BHNyGEPdMa0pPu8F61uCE+U4AScTvm4x2JiIdL27Wr4=";
  };
  
  unpackPhase = ''
    runHook preUnpack
  #  mv *.jar $src/
    mkdir src
    cp -a $src src/$(stripHash "$src")
    runHook postUnpack
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp src/*.jar $out/bin/komga.jar
  '';
  meta = with lib; {
    description = "comic book manager";
    homepage = "https://komga.org";
    license = licenses.mit;
    maintainers = with maintainers; [ mog ];
  };
}

