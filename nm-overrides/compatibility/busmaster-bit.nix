({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.compatibility.busmaster-bit.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Reenable the busmaster bit at boot.
    '';
  };

  config = mkIf config.nm-overrides.compatibility.busmaster-bit.enable {
    boot.kernelParams = mkOverride 100 [ ("efi=no_disable_early_pci_dma") ];
  };
})