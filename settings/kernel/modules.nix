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
  l,
  cfg,
  pkgs,
  ...
}:

let
  disabledModuleAlert = pkgs.writers.writeBashBin "nm-disabled-module-alert" ''
    echo "$0: ALERT: This kernel module is disabled by your nix-mineral configuration. You can override this behavior using the 'nix-mineral.settings.kernel.modules' option. | args: $@" >&2

    exit 1
  '';
in
{
  options = {
    modules = l.mkOption {
      description = ''
        Disable or blacklist kernel modules to prevent them from being loaded.

        - `true`: Do nothing and use NixOS defaults.
        - `"blacklist"`: Prevent the module from being loaded automatically at boot,
        but it can still be loaded afterwards.
        - `false`: Prevents the module from being loaded at all.

        ::: {.note}
        The `false` method does not register as a regular
        blacklist, this might cause issues with kernel module auditing e.g
        using Lynis. If so, you'll need to generate a whitelist.
        :::
      '';
      default = { };
      example = {
        example-disabled-module = false;
        example-blacklisted-module = "blacklist";
      };
      type = l.types.attrsOf (l.types.either l.types.bool (l.types.enum [ "blacklist" ]));
    };
  };

  config = l.mkIf (cfg != { }) {
    environment.etc."modprobe.d/nm-disable-kmodules.conf".text = l.concatStringsSep "\n" (
      l.mapAttrsToList (
        moduleName: moduleValue:
        if moduleValue == "blacklist" then
          "blacklist ${moduleName}"
        else if moduleValue == false then
          "install ${moduleName} ${l.getExe disabledModuleAlert}"
        else
          ""
      ) cfg
    );
  };
}
