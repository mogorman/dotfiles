{ stdenv, steam-run, writeScriptBin, makeWrapper, unzip, kubectl }:

let version = "1.5.21";
in stdenv.mkDerivation {
  name = "sdm";

  src = builtins.fetchurl {
    #url = "https://app.strongdm.com/releases/cli/linux";
#    url = "https://sdm-releases-production.s3.amazonaws.com/builds/sdm-cli/32.61.0/linux/amd64/FB5A678E3D2FE5BDA94124801D068C70EA1950A3/sdmcli_32.61.0_linux_amd64.zip";
    url = "https://downloads.strongdm.com/builds/sdm-cli/35.72.0/linux/amd64/0F824D8978809F9D5E25A52B62D681C0E3A99480/sdmcli_35.72.0_linux_amd64.zip";
     sha256 = "sha256:1mb0jb1gnfm10z4qng5d7y1h5gryqkci4l1x1hv3lh742fbqr4lj";

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
