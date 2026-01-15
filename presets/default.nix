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
          The preset (or presets) to use for the nix-mineral module.
          (all presets are applied on top of the default preset)

          To select multiple presets, provide a list of preset names.
          The order of presets matters, the top ones will have more priority.

          - default: only default settings.
          ${l.concatStringsSep "\n" (
            l.mapAttrsToList (name: description: "- ${name}: ${description}.") presets
          )}
        '';
        default = "default";
        example = [
          "performance"
          "compatibility"
        ];
        # Convert strings to single-element lists for easier processing later
        apply = value: if l.typeOf value == "string" then [ value ] else value;
        type = l.types.either presetsEnum (l.types.listOf presetsEnum);
      };
    };
  };

  config =
    let
      defaultOverride = 800;

      # Generate a set of overrides with all the presets inside cfg.preset
      # Each preset will have a different priority based on its position
      # Example:
      # if cfg.preset == [ "performance" "compatibility" "other-preset" ]
      # then presetOverrides = {
      #   performance = 800
      #   compatibility = 799
      #   other-preset = 798
      # }
      presetOverrides = (
        l.mergeAttrsList (
          l.imap0 (index: presetName: {
            "${presetName}" = defaultOverride - index;
          }) cfg.preset
        )
      );
    in
    # Any other way of doing this causes infinite recursion for some reason
    # i tried using a hashtable, if elses, but the only one that worked was mkIf
    l.mkMerge (
      l.mapAttrsToList (
        name: _:
        if name == "default" then
          { }
        else
          (
            let
              # For each preset, create a different mkPreset function that applies
              # the correct override based on the preset priority
              mkPreset = l.mkOverride (presetOverrides.${name});

              mkPresets = l.mapAttrsRecursive (name: value: mkPreset value);

              importWithArgs =
                filePath:
                import filePath {
                  inherit
                    config
                    pkgs
                    l
                    mkPreset
                    mkPresets
                    ;
                };
            in
            # Automatically import the preset file if a element with the preset name
            # exists in the cfg.preset list
            (l.mkIf (l.elem name cfg.preset) (importWithArgs ./${name}.nix))
          )
      ) presets
    );
}
