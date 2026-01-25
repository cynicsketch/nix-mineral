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
    slab-merging = l.mkBoolOption ''
      Set to false to disable slab merging to make it harder to influence
      the slab cache layout and compartmentalize the damage of certain memory
      attacks by limiting influence to individual caches.

      ::: {.note}
      See:
      - https://www.openwall.com/lists/kernel-hardening/2017/06/19/33
      - https://www.openwall.com/lists/kernel-hardening/2017/06/20/10
      :::
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernelParams = [
      "slab_nomerge"
    ];
  };
}
