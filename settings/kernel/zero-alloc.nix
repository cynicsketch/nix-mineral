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
    zero-alloc = l.mkBoolOption ''
      Zero memory during both allocation and free time to help mitigate
      use-after-free exploits.

      ::: {.note}
      See:
      - https://en.wikipedia.org/wiki/Dangling_pointer
      - https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=6471384af2a6530696fc0203bafe4de41a23c9ef
      :::
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernelParams = [
      "init_on_alloc=1"
      "init_on_free=1"
    ];
  };
}
