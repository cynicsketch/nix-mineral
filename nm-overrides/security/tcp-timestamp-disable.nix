({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.security.tcp-timestamp-disable.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Disable TCP timestamps to avoid leaking system time, as opposed to enabling
    it by default to protect against wrapped sequence numbers/improve
    performance
    '';
  };

  config = mkIf config.nm-overrides.security.tcp-timestamp-disable.enable {
    boot.kernel.sysctl."net.ipv4.tcp_timestamps" = mkForce "0";
  };
})