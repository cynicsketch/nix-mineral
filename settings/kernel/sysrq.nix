{
  l,
  cfg,
  ...
}:

{
  options = {
    sysrq = l.mkOption {
      description = ''
        Control the magic SysRq key functionality of the Linux kernel.
        It is a 'magical' key combo you can hit which the kernel will respond to regardless of whatever else it is doing,
        unless it is completely locked up.

        `none` - Keep the default configuration of your kernel.
        `off` - Disables sysrq completely.
        `sak` - Enable SAK (Secure Attention Key).

        SAK prevents keylogging, if used correctly.
        See URL: https://madaidans-insecurities.github.io/guides/linux-hardening.html#accessing-root-securely
      '';
      default = "off";
      type = l.types.enum [
        "none"
        "off"
        "sak"
      ];
    };
  };

  config = l.mkIf (cfg != "none") {
    boot.kernel.sysctl."kernel.sysrq" = l.mkForce (if cfg == "off" then "0" else "4");
  };
}
