{ lib, buildPythonPackage, fetchFromGitHub, pkgs }:

buildPythonPackage rec {
  pname = "fildem";
  version = "0.6.7";

  format = "pyproject";

  src = fetchFromGitHub {
  owner = "gonzaarcr";
  repo = "Fildem" ;
  rev = "0.6.7";
  sha256 = "sha256-Vdjh8UQlH+MUtPrkxNbifZz1LzUqHCKdqZG9s1/J986=";
};
#Depends: libbamf3-dev, bamfdaemon, libkeybinder-3.0-dev, appmenu-gtk2-module, appmenu-gtk3-module, unity-gtk-module-common, python3-gi, python3:any

  propagatedBuildInputs = [
    pkgs.pygobject3
  ];

  meta = with lib; {
    description = "global menu";
    homepage = "https://github.com/gonzaarcr/Fildem";
    license = licenses.gpl3;
  };
}
