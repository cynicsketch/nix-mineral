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
    pti = l.mkBoolOption ''
      Enable Page Table Isolation (PTI) to mitigate some KASLR bypasses and
      the Meltdown CPU vulnerability. It may also tax performance.

      ::: {.note}
      While AMD processors and newer Intel processors are not affected by
      Meltdown, keeping PTI anyways is still helpful as defense in depth against
      known and unknown side channel attacks upon KASLR.

      See:
      - https://en.wikipedia.org/wiki/Kernel_page-table_isolation
      - https://www.ieee-security.org/TC/SP2013/papers/4977a191.pdf
      :::
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernelParams = [
      "pti=on"
    ];
  };
}
