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
    shell-init-hardening = l.mkOption {
      description = "Shell initialization hardening settings.";
      default = { };
      type = l.types.submodule {
        options = {
          tmout = l.mkOption {
            type = l.types.nullOr l.types.int;
            default = null;
            example = 900;
            description = ''
              Set an idle timeout for interactive shells.

              When set, shells will automatically terminate after the specified
              number of seconds of inactivity.
            '';
          };

          umask = l.mkOption {
            type = l.types.nullOr l.types.str;
            default = null;
            example = "027";
            description = ''
              Set a restrictive default umask for shells.
            '';
          };
        };
      };
    };
  };

  config = l.mkMerge [
    (l.mkIf (cfg.tmout != null) {
      environment.shellInit = ''
        TMOUT=${toString cfg.tmout}
        command readonly TMOUT 2>/dev/null || true
        export TMOUT
      '';
    })

    (l.mkIf (cfg.umask != null) {
      environment.shellInit = ''
        umask ${cfg.umask}
      '';
    })
  ];
}
