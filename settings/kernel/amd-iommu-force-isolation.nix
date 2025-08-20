{
  l,
  cfg,
  ...
}:

{
  options = {
    amd-iommu-force-isolation = l.mkBoolOption ''
      Set amd_iommu=force_isolation kernel parameter.
      set this to false as workaround for hanging issue on linux kernel 6.13.
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernelParams = [
      "amd_iommu=force_isolation"
    ];
  };
}
