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
  config,
  ...
}:

{
  options = {
    slab-debug = l.mkOption {
      description = ''
        Set to true to modify the "slab_debug" boot parameter to enable red
        zoning and sanity checks to detect memory corruption.

        Adds significant overhead to memory allocation.

        This option is automatically enabled if the kernel version defined
        in boot.kernelPackages is at least 6.17, to ensure that pointer hashing
        can stay enabled.

        ::: {.warning}
        Because this is a debugging option, it will disable kernel pointer
        hashing and leak kernel memory addresses to root unless the
        "hash_pointers=always" parameter is used, which is only supported on
        kernel version 6.17 and above. Otherwise, "hash_pointers" is silently
        ignored.
        :::

        ::: {.note}
        See:
        - https://gitlab.tails.boum.org/tails/tails/-/issues/19613
        - https://kspp.github.io/Recommended_Settings
        - https://github.com/Kicksecure/security-misc/issues/253
        :::
      '';
      default = (l.versionAtLeast config.boot.kernelPackages.kernel.version "6.17");
      example = false;
      type = l.types.bool;
    };
  };

  config = l.mkIf cfg {
    boot.kernelParams = [
      "slab_debug=FZ"
      "hash_pointers=always"
    ];
  };
}
