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
    shell-init =
      l.mkBoolOption ''
        Set restrictive shell defaults for umask and idle timeout.

        Sets umask to 027 and shell timeout to 900 seconds.
      ''
      false;
  };

  config = l.mkIf cfg {
    environment.shellInit = ''
      umask 027
      TMOUT=900
      readonly TMOUT
      export TMOUT
    '';
  };
}
