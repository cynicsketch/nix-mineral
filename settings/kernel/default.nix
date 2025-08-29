{
  options,
  config,
  pkgs,
  lib,
  l,
  cfg,
  ...
}:

let
  categoryModules =
    l.mkCategoryModules cfg
      [
        ./only-signed-modules.nix
        ./lockdown.nix
        ./busmaster-bit.nix
        ./iommu-passthrough.nix
        ./cpu-mitigations.nix
        ./pti.nix
        ./binfmt-misc.nix
        ./io-uring.nix
        ./amd-iommu-force-isolation.nix
        ./tcp-timestamps.nix
      ]
      {
        inherit
          options
          config
          pkgs
          lib
          ;
      };
in
{
  options = {
    kernel = l.mkOption {
      description = ''
        Settings meant to harden the linux kernel.
      '';
      default = { };
      type = l.mkCategorySubmodule categoryModules;
    };
  };

  config = l.mkCategoryConfig categoryModules;
}
