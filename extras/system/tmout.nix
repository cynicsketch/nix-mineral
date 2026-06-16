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
    tmout = l.mkOption {
      description = ''
        Set an idle timeout for interactive shells.

        When enabled, shells will automatically terminate after the specified
        number of seconds of inactivity.
      '';
      default = { };
      type = l.types.submodule {
        options = {
          enable = l.mkEnableOption "shell idle timeout";

          value = l.mkOption {
            type = l.types.int;
            default = 900;
            example = 300;
            description = ''
              The number of seconds of inactivity before the shell times out.
            '';
          };
        };
      };
    };
  };

  config = l.mkIf cfg.enable {
    environment.shellInit = ''
      TMOUT=${toString cfg.value}
      command readonly TMOUT 2>/dev/null || true
      export TMOUT
    '';
  };
}
