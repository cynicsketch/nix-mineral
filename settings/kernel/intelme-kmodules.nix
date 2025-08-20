{
  l,
  cfg,
  ...
}:

{
  options = {
    intelme-kmodules = l.mkBoolOption ''
      Intel ME related kernel modules.
      Disable this to avoid putting trust in the highly privilege ME system,
      but there are potentially other consequences.

      If you use an AMD system, you can disable this without negative consequence
      and reduce attack surface.

      Intel users should read more about the issue at the below links:
      https://www.kernel.org/doc/html/latest/driver-api/mei/mei.html
      https://en.wikipedia.org/wiki/Intel_Management_Engine#Security_vulnerabilities
      https://www.kicksecure.com/wiki/Out-of-band_Management_Technology#Intel_ME_Disabling_Disadvantages
      https://github.com/Kicksecure/security-misc/pull/236#issuecomment-2229092813
      https://github.com/Kicksecure/security-misc/issues/239
    '' true;
  };

  config = l.mkIf (!cfg) {
    environment.etc."modprobe.d/nm-disable-intelme-kmodules.conf" = {
      text = ''
        install mei /usr/bin/disabled-intelme-by-security-misc
        install mei-gsc /usr/bin/disabled-intelme-by-security-misc
        install mei_gsc_proxy /usr/bin/disabled-intelme-by-security-misc
        install mei_hdcp /usr/bin/disabled-intelme-by-security-misc
        install mei-me /usr/bin/disabled-intelme-by-security-misc
        install mei_phy /usr/bin/disabled-intelme-by-security-misc
        install mei_pxp /usr/bin/disabled-intelme-by-security-misc
        install mei-txe /usr/bin/disabled-intelme-by-security-misc
        install mei-vsc /usr/bin/disabled-intelme-by-security-misc
        install mei-vsc-hw /usr/bin/disabled-intelme-by-security-misc
        install mei_wdt /usr/bin/disabled-intelme-by-security-misc
        install microread_mei /usr/bin/disabled-intelme-by-security-misc
      '';
    };
  };
}
