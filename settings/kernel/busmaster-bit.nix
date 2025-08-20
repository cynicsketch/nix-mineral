{
  l,
  cfg,
  ...
}:

{
  options = {
    busmaster-bit = l.mkBoolOption ''
      Enable busmaster bit at boot.
      if false, this may prevent low resource systems from booting.
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernelParams = [
      "efi=disable_early_pci_dma"
    ];
  };
}
