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
    max-map = l.mkBoolOption ''
      Increase the number memory map areas a process can use.

      Primarily for future proofing potential use of hardened-malloc in the
      future, which requires more map areas in order to support its guard
      pages.

      This feature is usually safe, and has been enabled by default on Arch
      Linux specifically to increase stability and reduce crashing.

      See:
      https://archlinux.org/news/increasing-the-default-vmmax_map_count-value/
      https://github.com/GrapheneOS/hardened_malloc#traditional-linux-based-operating-systems
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
      "vm.max_map_count" = l.mkDefault "1048576";
    };
  };
}
