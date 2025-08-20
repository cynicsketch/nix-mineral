{
  l,
  cfg,
  ...
}:

{
  options = {
    iommu-passthrough = l.mkBoolOption ''
      Enable bypassing the IOMMU for direct memory access. Could increase I/O
      performance on ARM64 systems, with risk.
      if false, forces DMA to go through IOMMU to mitigate some DMA attacks.
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernelParams = [
      "iommu.passthrough=0"
    ];
  };
}
