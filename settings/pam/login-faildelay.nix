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
    login-faildelay = l.mkOption {
      description = ''
        Add/increase the delay to failed logins into the system.

        The default for nix-mineral is 4 seconds, or 4000000 microseconds.
      '';
      default = 4000000;
      example = false;
      type = l.types.either l.types.bool l.types.int;
    };
  };

  config = l.mkIf (l.typeOf cfg == "int") {
    security.pam.services = {
      system-login.failDelay.delay = l.mkDefault (toString cfg);
    };
  };
}
