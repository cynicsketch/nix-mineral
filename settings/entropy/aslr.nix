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
    aslr = l.mkBoolOption ''
      Ensure ASLR is enabled. This should normally be the default on modern
      kernel versions but is set directly for explicitness.

      Randomize the locations of the stack, VDSO page, mmap base, as well as
      randomizing the heap to make it harder to guess the addresses of key
      locations in memory for the purpose of exploitation.

      Should be unlikely to cause breakage according to upstream documentation,
      unless using "ancient" applications.

      ::: {.note}
      Read more about ASLR at the following links:
      - https://docs.kernel.org/admin-guide/sysctl/kernel.html#randomize-va-space
      - https://en.wikipedia.org/wiki/Address_space_layout_randomization
      :::
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl."kernel.randomize_va_space" = l.mkDefault "2";
  };
}
