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
  parentCfg,
  l,
  cfg,
  ...
}:

let
  moduleCombos = import ./combos/blacklist.nix { inherit config l; };
  # Attrset of all modules to blacklist by combos
  combosModules = l.mergeAttrsList (
    l.mapAttrsToList (
      name: values:
      if cfg ? ${name} && cfg.${name} == true then
        l.listToAttrs (
          l.map (module: {
            name = module;
            value = true;
          }) values.modules
        )
      else
        { }
    ) moduleCombos
  );
  # Override combos config with user config (removing combos declarations)
  modules = combosModules // (l.removeAttrs cfg (l.attrNames moduleCombos));
in
{
  options = {
    blacklist = l.mkOption {
      description = ''
        Blacklist kernel modules to prevent them from being loaded automatically at boot,
        but it can still be loaded afterwards.
      '';
      default = { };
      example = {
        example-blacklisted-module = true;
      };
      type = l.types.submodule {
        freeformType = l.types.attrsOf l.types.bool;
        # define module combos options
        options = l.mapAttrs (
          name: values:
          (l.mkBoolOption ''
            Blacklist kernel modules related to ${name}.
          '' false)
          // (l.removeAttrs values [ "modules" ])
        ) moduleCombos;
      };
    };
  };

  config = l.mkIf (parentCfg.enable && cfg != { }) {
    environment.etc."modprobe.d/nix-mineral_blacklist-kmodules.conf".text = l.concatStringsSep "\n" (
      l.mapAttrsToList (
        moduleName: moduleValue: if moduleValue == true then "blacklist ${moduleName}" else ""
      ) modules
    );
  };
}
