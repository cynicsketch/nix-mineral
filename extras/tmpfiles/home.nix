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
    home = l.mkBoolOption ''
      Set to true to recursively restrict permissions of `/home/$USER` so that
      only the owner of the directory can access it (the user).

      ::: {.note}
      Existing user masks are left untouched. The "~" option means provides
      masking, so that the permissions are only changed if it the existing value
      is greater than the masked value.

      E.G, a file with the permissions denoted "0644" changes to "0600," because
      the user permission mask "6" is less than "7" but the "4" for the group
      and world file mode masks are more than "0"

      This may have side effects like obliterating existing executable access
      mask bits for groups and world.
      :::

      ::: {.warning}
      This may also have unintended side effects, e.g, root owned files being
      unreadable if somehow created in a user home directory.
      :::

      ::: {.warning}
      This may cause recursion/boot speed problems.
      See:
      - https://github.com/cynicsketch/nix-mineral/issues/28
      :::
    '' false;
  };

  config = l.mkIf cfg {
    systemd.tmpfiles.settings."restricthome"."/home/*".Z.mode = l.mkDefault "~0700";
  };
}
