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
    hardened-usercopy = l.mkBoolOption ''
      Ensure hardened usercopy checking is enabled at boot, to proactively check
      and protect against exploits involving abuse of the `copy_to_user()` and
      `copy_from_user()` functions in the kernel to read and write memory beyond
      intended boundaries.

      ::: {.note}
      See:
      - https://www.kernelconfig.io/config_hardened_usercopy
      - https://kspp.github.io/Recommended_Settings
      - https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
      :::
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernelParams = [ "hardened_usercopy=1" ];
  };
}
