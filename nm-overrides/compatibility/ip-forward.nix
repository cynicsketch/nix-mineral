({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.compatibility.ip-forward.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Reenable ip forwarding.
    '';
  };

  config = mkIf config.nm-overrides.compatibility.ip-forward.enable {
    boot.kernel.sysctl."net.ipv4.ip_forward" = mkForce "1";
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = mkForce "1";
  };
})