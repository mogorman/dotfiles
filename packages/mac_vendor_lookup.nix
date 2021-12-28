{ lib, buildPythonPackage, fetchFromGitHub, aiohttp, aiofiles }:

buildPythonPackage rec {
  pname = "mac_vendor_lookup";
  version = "0.1.11";

  format = "pyproject";

  src = fetchFromGitHub {
  owner = "bauerj";
  repo = "mac_vendor_lookup" ;
  rev = "0.1.11";
  sha256 = "sha256-Vdjh8UQlH+MUtPrkxNbifZz1LzUqHCKdqZG9s1/J984=";
};

  propagatedBuildInputs = [
    aiohttp
    aiofiles
  ];

  postPatch = ''
  cp ${./mac-vendors.txt} mac-vendors.txt
  '';
  pythonImportsCheck = [ "mac_vendor_lookup" ];

  meta = with lib; {
    description = "mac id lookup";
    homepage = "https://github.com/bauerj/mac_vendor_lookup";
    license = licenses.asl20;
  };
}
