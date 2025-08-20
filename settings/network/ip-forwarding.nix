{
  l,
  cfg,
  ...
}:

{
  options = {
    ip-forwarding = l.mkBoolOption ''
      Enable or disable IP forwarding.
      if false, this may cause issues with certain VM networking,
      and must be true if the system is meant to function as a router.
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      # NOTE: `mkOverride 900` is used when a default value is already defined in NixOS.
      "net.ipv4.ip_forward" = l.mkDefault "0";
      "net.ipv4.conf.all.forwarding" = l.mkOverride 900 "0";
      "net.ipv4.conf.default.forwarding" = l.mkDefault "0";
      "net.ipv6.conf.all.forwarding" = l.mkDefault "0";
      "net.ipv6.conf.default.forwarding" = l.mkDefault "0";
    };
  };
}
