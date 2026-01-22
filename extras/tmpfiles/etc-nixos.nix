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
    etc-nixos = l.mkBoolOption ''
      Set to true to recursively make all files in `/etc/nixos` owned and readable
      only by root.

      `/etc/nixos` is not owned by root by default, which can be hazardous as
      files that are included in the rebuild may be editable by unprivileged
      users.

      ::: {.note}
      This may have unintended side effects if user state is intentionally
      stored in `/etc/nixos`, and is therefore no longer enabled by default.
      :::
    '' false;
  };

  config = l.mkIf cfg {
    systemd.tmpfiles.settings."restrictetcnixos"."/etc/nixos/*".Z = {
      mode = l.mkDefault "0000";
      user = l.mkDefault "root";
      group = l.mkDefault "root";
    };
  };
}
