({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.security.sysrq-sak.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Enable Secure Attention Key with the sysrq key.
    '';
  };

  config = mkIf config.nm-overrides.security.sysrq-sak.enable {
    boot.kernel.sysctl."kernel.sysrq" = mkForce "4";
  };
})