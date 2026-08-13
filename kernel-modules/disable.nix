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
  pkgs,
  ...
}:

let
  disabledModuleAlert = pkgs.writers.writeBashBin "nm-disabled-module-alert" ''
    echo "$0: ALERT: This kernel module is disabled by your nix-mineral configuration. You can override this behavior using the 'nix-mineral.kernel-modules.disable' option. | args: $@" >&2

    exit 1
  '';

  moduleCombos = import ./combos/disable.nix { inherit config l; };
  # Attrset of all modules to disable by combos
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
  # We use mkChangedOptionModule instead of mkRenamedOptionModule because the
  # new options have the values inverted (true = disable, false = enable)
  imports = [
    (l.mkChangedOptionModule
      [ "nix-mineral" "settings" "kernel" "algif-kmodules" ]
      [ "nix-mineral" "kernel-modules" "disable" "algif-related" ]
      (config: !(l.getAttrFromPath [ "nix-mineral" "settings" "kernel" "algif-kmodules" ] config))
    )
    (l.mkChangedOptionModule
      [ "nix-mineral" "extras" "kernel" "intelme-kmodules" ]
      [ "nix-mineral" "kernel-modules" "disable" "intelme-related" ]
      (config: !(l.getAttrFromPath [ "nix-mineral" "extras" "kernel" "intelme-kmodules" ] config))
    )
    (l.mkChangedOptionModule
      [ "nix-mineral" "extras" "network" "bluetooth-kmodules" ]
      [ "nix-mineral" "kernel-modules" "disable" "bluetooth-related" ]
      (config: !(l.getAttrFromPath [ "nix-mineral" "extras" "network" "bluetooth-kmodules" ] config))
    )
  ];

  options = {
    disable = l.mkOption {
      description = ''
        Disable kernel modules to prevent them from being loaded at all.

        ::: {.note}
        This method does not register as a regular
        blacklist, this might cause issues with kernel module auditing e.g
        using Lynis. If so, you'll need to generate a whitelist.
        :::
      '';
      default = { };
      example = {
        example-disabled-module = true;
      };
      type = l.types.submodule {
        freeformType = l.types.attrsOf l.types.bool;
        # define module combos options
        options = l.mapAttrs (
          name: values:
          (l.mkBoolOption ''
            Disable kernel modules related to ${name}.
          '' false)
          // (l.removeAttrs values [ "modules" ])
        ) moduleCombos;
      };
    };
  };

  config = l.mkIf (parentCfg.enable && cfg != { }) {
    environment.etc."modprobe.d/nix-mineral_disable-kmodules.conf".text = l.concatStringsSep "\n" (
      l.mapAttrsToList (
        moduleName: moduleValue:
        if moduleValue == true then "install ${moduleName} ${l.getExe disabledModuleAlert}" else ""
      ) modules
    );
  };
}
