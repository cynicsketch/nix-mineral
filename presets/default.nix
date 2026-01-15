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

  presets = {
    maximum = "enables every optional security setting to have maximum protection";
    compatibility = "disables or enables settings to aim at compatibility";
    performance = "disables or enables settings to aim at performance";
  };

  presetsEnum = l.types.enum ([ "default" ] ++ (l.attrNames presets));
in
{
  options = {
    nix-mineral = {
      preset = l.mkOption {
        description = ''
          The preset to use for the nix-mineral module.
          (all presets are applied on top of the default preset)

          - default: only default settings.
          ${l.concatStringsSep "\n" (
            l.mapAttrsToList (name: description: "- ${name}: ${description}.") presets
          )}
        '';
        default = "default";
        type = presetsEnum;
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
    l.mkMerge (
      l.mapAttrsToList (
        name: _:
        if name == "default" then { } else (l.mkIf (cfg.preset == name) (importWithArgs ./${name}.nix))
      ) presets
    );
}
