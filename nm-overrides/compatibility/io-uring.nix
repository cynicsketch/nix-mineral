({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.compatibility.io-uring.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Reenable io_uring.
    '';
  };

  config = mkIf config.nm-overrides.compatibility.io-uring.enable {
    boot.kernel.sysctl."kernel.io_uring_disabled" = mkForce "0";
  };
})