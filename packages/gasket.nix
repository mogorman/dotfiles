{ lib, stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
  name = "gasket-${version}-${kernel.version}";
  version = "2021-10-24";

  src = fetchFromGitHub {
    owner = "google";
    repo = "gasket-driver";
    rev = "f047773516dd65435becf09d8d03e5ef2a9f4165";
    sha256 = "sha256-uhRxJiysnwoW3uNE8o0D99aVRNQWWUwa5t7Gt998UrE=";
  };

  sourceRoot = "source/src";

  makeFlags = [ "KVERSION=${kernel.modDirVersion}" ];

  patchPhase = "sed -ie 's,/lib/modules,${kernel.dev}/lib/modules,' Makefile";

  installPhase = ''
    xz apex.ko
    xz gasket.ko
    install -Dm 644 $src/debian/gasket-dkms.udev $out/lib/udev/rules.d/51-gasket-dkms.rules
    install -m644 -b -D gasket.ko.xz $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/staging/gasket/gasket.ko.xz
    install -m644 -b -D apex.ko.xz $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/staging/gasket/apex.ko.xz
  '';

  meta = with lib; {
    priority = 1;
    description = "A kernel module for google coral devices";
    homepage = "https://www.coral.ai";
    license = licenses.gpl2;
    maintainers = [ maintainers.mog ];
    platforms = linux.platforms;
  };
}
