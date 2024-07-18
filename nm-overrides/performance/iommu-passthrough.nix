({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.performance.iommu-passthrough.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Enable bypassing the IOMMU for direct memory access.
    '';
  };

  config = mkIf config.nm-overrides.performance.iommu-passthrough.enable {
    boot.kernelParams = mkOverride 100 [ ("iommu.passthrough=1")  ];
  };
})