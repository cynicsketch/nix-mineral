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
  mkPresets,
  ...
}:

{
  nix-mineral = mkPresets {
    settings = {
      kernel = {
        # if false, may prevent low resource systems from booting.
        busmaster-bit = true;

        # Enable symmetric multithreading and just use default CPU mitigations,
        # to potentially improve performance.
        # DO NOT disable all cpu mitigations,
        cpu-mitigations = "smt-on";

        # Could increase I/O performance on ARM64 systems, with risk.
        iommu-passthrough = true;

        # PTI (Page Table Isolation) may tax performance.
        pti = false;

        # Don't use kcfi as the control flow implementation in the kernel,
        # since it performs worse than FineIBT, which is the current Linux
        # kenrel (not nix-mineral) default.
        kcfi = false;

        # Do not enable red zoning and sanity checking with slab debug, since
        # it adds significant memory allocation overhead.
        slab-debug = false;
      };

    };
  };
}
