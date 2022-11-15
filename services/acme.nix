{ config, lib, pkgs, ... }: {

  security.acme = {
    acceptTerms = true;
    defaults.email = "mog@rldn.net";
    certs."rldn.net" = {
      group = "nginx";
      email = "mog@rldn.net";
      domain = "*.rldn.net";
      extraDomainNames = [ "rldn.net" ];
      dnsProvider = "linodev4";
      credentialsFile = ./../secrets/linode.ini;
    };
    certs."root.rldn.net" = {
      group = "nginx";
      email = "mog@rldn.net";
      domain = "rldn.net";
      dnsProvider = "linodev4";
      credentialsFile = ./../secrets/linode.ini;
    };
    certs."ogormanvein.com" = {
      group = "nginx";
      email = "mog@rldn.net";
      domain = "*.ogormanvein.com";
      extraDomainNames = [ "ogormanvein.com" ];
      dnsProvider = "linodev4";
      credentialsFile = ./../secrets/linode.ini;
    };
    certs."root.ogormanvein.com" = {
      group = "nginx";
      email = "mog@rldn.net";
      domain = "ogormanvein.com";
      dnsProvider = "linodev4";
      credentialsFile = ./../secrets/linode.ini;
    };  };
}
