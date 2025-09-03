{
  config,
  pkgs,
  l,
  ...
}:

let
  cfg = config.nix-mineral;
in
{
  options = {
    nix-mineral = {
      preset = l.mkOption {
        description = ''
          The preset to use for the nix-mineral module.
          (all presets are applied on top of the default preset)

          - maximum: enables every optional security setting to have maximum protection.
          - default: only default settings.
          - compatibility: disables or enables settings to aim at compatibility.
          - performance: disables or enables settings to aim at performance.
        '';
        default = "default";
        type = l.types.enum [
          "maximum"
          "default"
          "compatibility"
          "performance"
        ];
      };
    };
  };

  config =
    let
      mkPreset = l.mkOverride 900;

      importWithArgs =
        path:
        import path {
          inherit
            config
            pkgs
            l
            mkPreset
            ;
        };
    in
    # Any other way of doing this causes infinite recursion for some reason
    # i tried using a hashtable, if elses, but the only one that worked was mkIf
    l.mkMerge [
      (l.mkIf (cfg.preset == "maximum") (importWithArgs ./maximum.nix))

      (l.mkIf (cfg.preset == "default") { })

      (l.mkIf (cfg.preset == "compatibility") (importWithArgs ./compatibility.nix))

      (l.mkIf (cfg.preset == "performance") (importWithArgs ./performance.nix))
    ];
}
