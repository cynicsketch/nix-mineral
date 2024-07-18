({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.software-choice.secure-chrony.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Replace systemd-timesyncd with chrony for NTP, and configure chrony for NTS
    and to use the seccomp filter for security.
    '';
  };

  config = mkIf config.nm-overrides.software-choice.secure-chrony.enable {
    services.timesyncd = { enable = false; }; 
    services.chrony = {
      enable = true;
      
      extraFlags = [ "-F 1" ]; 
      # Enable seccomp filter for chronyd.
            
      enableRTCTrimming = false; 
      # Disable 'rtcautotrim' so that 'rtcsync' can be used instead. Either 
      # this or 'rtcsync' must be disabled to complete a successful rebuild,
      # or an error will be thrown due to these options conflicting with
      # eachother.
      
      # The below config is borrowed from GrapheneOS server infrastructure.
      # It enables NTS to secure NTP requests, among some other useful
      # settings.
      
      extraConfig = ''
        server time.cloudflare.com iburst nts
        server ntppool1.time.nl iburst nts
        server nts.netnod.se iburst nts
        server ptbtime1.ptb.de iburst nts

        minsources 2
        authselectmode require

        # EF
        dscp 46

        driftfile /var/lib/chrony/drift
        ntsdumpdir /var/lib/chrony

        leapsectz right/UTC
        makestep 1.0 3

        rtconutc
        rtcsync

        cmdport 0
      '';
    };
  };
})