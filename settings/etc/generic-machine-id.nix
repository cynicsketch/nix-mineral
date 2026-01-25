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
    generic-machine-id = l.mkBoolOption ''
      Set machine-id to the Kicksecure machine-id, for privacy reasons.

      ::: {.warning}
      This may have unintended consequences if machine-id needs to be unique,
      e.g for log collection or VM management.
      :::
    '' true;
  };

  config = l.mkIf cfg {
    # /var/lib/dbus/machine-id doesn't exist on dbus enabled NixOS systems,
    # so we don't have to worry about that.
    environment.etc.machine-id.text = ''
      b08dfa6083e7567a1921a715000001fb
    '';
  };
}
