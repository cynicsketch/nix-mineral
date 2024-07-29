({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.security.disable-tcp-window-scaling.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Disable TCP window scaling.
    '';
  };

  config = mkIf config.nm-overrides.security.disable-tcp-window-scaling.enable {
    boot.kernel.sysctl."net.ipv4.tcp_window_scaling" = mkForce "0";
  };
})