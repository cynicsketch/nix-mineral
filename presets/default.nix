# This file is part of nix-mineral (https://github.com/cynicsketch/nix-mineral/).
# Copyright (c) 2025 cynicsketch
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
