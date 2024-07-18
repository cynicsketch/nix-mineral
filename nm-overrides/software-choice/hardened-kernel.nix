({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.software-choice.hardened-kernel.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Use Linux kernel with hardened patchset.
    '';
  };

  config = mkIf config.nm-overrides.software-choice.hardened-kernel.enable {
    boot.kernelPackages = mkForce (pkgs).linuxPackages_hardened;
  };
})