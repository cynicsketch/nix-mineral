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
  ...
}:

{
  options = {
    cpu-mitigations = l.mkOption {
      description = ''
        Apply relevant CPU exploit mitigations, May harm performance.

        - `smt-off`: Enable CPU mitigations and disables symmetric multithreading.
        - `smt-on`: Enable symmetric multithreading and just use default CPU mitigations, to potentially improve performance.
        - `unspecified`: Do nothing and use NixOS defaults.

        ::: {.warning}
        Turning all CPU mitigations off completely is a TERRIBLE idea. Even the most robustly sandboxed
        and restricted code in the world can instantly rootkit your computer.
        One web page is all it takes for all your keys to be someone else's: https://leaky.page/

        The "off" option is deprecated and instead has the same effect has "unspecified,"
        and is scheduled to be removed in a later release.
        :::
      '';
      default = "smt-off";
      type = l.types.enum [
        "smt-off"
        "smt-on"
        "unspecified"
        "off"
      ];
    };
  };

  config = {
    warnings = l.optional (cfg == "off") ''
      The option `nix-mineral.settings.kernel.cpu-mitigations = "off"` is deprecated
      because it results in a marked decrease in security that is unmitigatable
      by any other means, and does not align with the project's vision.

      See: https://github.com/cynicsketch/nix-mineral/issues/140

      This option is now equivalent to "unspecified" which inherits the NixOS
      defaults instead.
    '';
    boot.kernelParams =
      if cfg == "smt-off" then
        [ "mitigations=auto,nosmt" ]
      else if cfg == "smt-on" then
        [ "mitigations=auto" ]
      else
        [ ];
  };
}
