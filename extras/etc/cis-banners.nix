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
}: {
  options = {
    cis-banners =
      l.mkBoolOption ''
        Set CIS-compliant login warning banners.

        Configures `/etc/motd` (CIS 1.7.1.1) and `/etc/issue.net` (CIS 1.7.1.3)
        with warnings.
      ''
      false;
  };

  config = l.mkIf cfg {
    environment.etc = {
      # CIS 1.7.1.1 - message of the day
      "motd".text = ''
        Authorized uses only. All activity may be monitored and reported.
      '';

      # CIS 1.7.1.3 - remote login warning banner
      "issue.net".text = ''
        Authorized uses only. All activity may be monitored and reported.
      '';
    };
  };
}
