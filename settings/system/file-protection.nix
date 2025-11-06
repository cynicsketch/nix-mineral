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
    file-protection = l.mkBoolOption ''
      Prevent creation of files in world writable directories under certain
      circumstances to limit spoofing attacks.

      ::: {.note}
      See https://github.com/torvalds/linux/commit/30aba6656f61ed44cba445a3c0d38b296fa9e8f5
      :::
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
      "fs.protected_regular" = l.mkDefault "2";
      "fs.protected_fifos" = l.mkDefault "2";
    };
  };
}
