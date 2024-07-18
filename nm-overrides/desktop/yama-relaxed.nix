({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.desktop.yama-relaxed.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Instead of disabling ptrace, restrict only so that parent processes can
    ptrace descendants.
    '';
  };

  config = mkIf config.nm-overrides.desktop.yama-relaxed.enable {
    boot.kernel.sysctl."kernel.yama.ptrace_scope" = mkForce "1";
  };
})