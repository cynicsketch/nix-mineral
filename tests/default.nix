{ pkgs, nixosModule }:

let
  mkTest = path: import path { inherit pkgs nixosModule; };
in
{
  mineral-settings-kernel = mkTest ./settings-kernel.nix;
  mineral-settings-network = mkTest ./settings-network.nix;
  mineral-settings-system = mkTest ./settings-system.nix;
  mineral-extras-chrony = mkTest ./extras-chrony.nix;
  mineral-extras-usbguard = mkTest ./extras-usbguard.nix;
  mineral-preset-default = mkTest ./preset-default.nix;
  mineral-preset-maximum = mkTest ./preset-maximum.nix;
}
