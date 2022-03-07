{ stdenv, steam-run, writeScriptBin, makeWrapper, unzip, kubectl }:

let version = "1.5.21";
in stdenv.mkDerivation {
  name = "sdm";

  src = builtins.fetchurl {
    url = "https://app.strongdm.com/releases/cli/linux";
    sha256 = "sha256:01vpxlgampm532xjvmjx834p1j4cmb5ypc2l81m7crasgva3syby";
  };

  # preUnpack = ''
  #   ls src
  #   ls env-vars
  #   ${unzip}/bin/unzip 3cjskkd8vnd1qam07dx2nk9sg588bpkr-linux
  # '';
  nativeBuildInputs = [ makeWrapper kubectl ];

  unpackCmd = ''
    mkdir -p src
    ${unzip}/bin/unzip $src
    mv sdm src/
  '';

  installPhase = ''
    ls
    mkdir -p $out/bin
    cp sdm $out/bin/.sdm-unwrapped
    makeWrapper ${steam-run}/bin/steam-run $out/bin/sdm --add-flags $out/bin/.sdm-unwrapped
  '';
}
