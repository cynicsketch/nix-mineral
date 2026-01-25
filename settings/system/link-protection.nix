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
    link-protection = l.mkBoolOption ''
      Protect hardlinks and softlinks to prevent TOCTOU attacks.

      Prevent users from hardlinking to files they can't read/write to.

      Allows symlinks to be followed only outside world writable directories,
      when the owner and follower match, or when the directory and symlink
      owner match.

      ::: {.note}
      See:
      - https://en.wikipedia.org/wiki/Time-of-check_to_time-of-use
      :::
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
      "fs.protected_hardlinks" = l.mkDefault "1";
      "fs.protected_symlinks" = l.mkDefault "1";
    };
  };
}
