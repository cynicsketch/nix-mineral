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
    replace-sudo-with-doas = l.mkBoolOption ''
      Replace sudo with doas, doas has a lower attack surface, but is less audited.
    '' false;
  };

  config = l.mkIf cfg {
    security.sudo.enable = l.mkDefault false;
    security.doas = {
      enable = l.mkDefault true;
      extraRules = [
        {
          keepEnv = l.mkDefault true;
          persist = l.mkDefault true;
          users = l.mkDefault [ "user" ];
        }
      ];
    };
  };
}
