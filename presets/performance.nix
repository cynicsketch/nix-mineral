{
  mkPreset,
  ...
}:

{
  nix-mineral = {
    settings = {
      kernel = {
        # if false, may prevent low resource systems from booting.
        busmaster-bit = mkPreset true;

        # Disables all CPU mitigations to improve performance.
        cpu-mitigations = mkPreset "off";

        # Could increase I/O performance on ARM64 systems, with risk.
        iommu-passthrough = mkPreset true;

        # PTI (Page Table Isolation) may tax performance.
        pti = mkPreset false;
      };

      system = {
        # allow 32-bit libraries and applications to run.
        multilib = mkPreset true;
      };
    };
  };
}
