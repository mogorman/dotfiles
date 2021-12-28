{ lib, buildPythonPackage, fetchFromGitHub, websockets, poetry, jsonschema }:

buildPythonPackage rec {
  pname = "ocpp";
  version = "0.10.0";

  format = "pyproject";

  src = fetchFromGitHub {
  owner = "mobilityhouse";
  repo = "ocpp";
  rev = "0.10.0";
  sha256 = "sha256-G4Uv+VjTyLUXY+Ts9c+xbcLiBCHsa9tCTvV6/aAprn0=";
};

  propagatedBuildInputs = [
    websockets
    poetry
    jsonschema
  ];

  meta = with lib; {
    description = "python ocpp lib";
    homepage = "https://github.com/mobilityhouse/ocpp";
    license = licenses.mit;
  };
}
