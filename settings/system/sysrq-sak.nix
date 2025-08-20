{
  l,
  cfg,
  ...
}:

{
  options = {
    sysrq-sak = l.mkBoolOption ''
      Enable SAK (Secure Attention Key). SAK prevents keylogging, if used
      correctly. See URL: https://madaidans-insecurities.github.io/guides/linux-hardening.html#accessing-root-securely
    '' false;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl."kernel.sysrq" = l.mkForce "4";
  };
}
