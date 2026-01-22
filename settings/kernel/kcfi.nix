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
    kcfi = l.mkBoolOption ''
      If set to true, switch (back) to using kCFI as the default Control Flow
      Integrity (CFI) implementation as kCFI mandates hash validation at the
      source making it more difficult to bypass.

      This is in contrast to FineIBT which was made the default in kernel 6.2
      due to its performance benefits as it only performs hash checks at the
      destinations.

      ::: {.note}
      See:
      - https://docs.kernel.org/next/x86/shstk.html
      :::
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernelParams = [ "cfi=kcfi" ];
  };
}
