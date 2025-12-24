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
    load-kernel-modules = l.mkBoolOption ''
      Set to true to recursively restrict permissions of /home/$USER so that
      only the owner of the directory can access it (the user).
       
      This may cause recursion/boot speed problems, see https://github.com/cynicsketch/nix-mineral/issues/28
      for more information.

      This may also have unintended side effects, e.g, root owned files being
      unreadable if somehow created in a user home directory.
    '' false;
  };

  config = l.mkIf cfg {
    systemd.tmpfiles.settings."restricthome"."/home/*".Z.mode = l.mkDefault "~0700";
  };
}
