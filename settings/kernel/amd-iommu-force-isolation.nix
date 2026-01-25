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
    amd-iommu-force-isolation = l.mkBoolOption ''
      Set amd_iommu=force_isolation kernel parameter.

      If you're not using an AMD CPU, this does nothing and can be safely
      ignored.

      ::: {.warning}
      You may need to set this to false as a workaround for a boot hanging
      issue on Linux kernel 6.13.
      :::
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernelParams = [
      "amd_iommu=force_isolation"
    ];
  };
}
