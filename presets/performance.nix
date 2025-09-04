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

        # Enable symmetric multithreading and just use default CPU mitigations,
        # to potentially improve performance.
        # DO NOT disable all cpu mitigations,
        cpu-mitigations = mkPreset "smt-on";

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
