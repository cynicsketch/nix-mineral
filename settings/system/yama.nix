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
    yama = l.mkOption {
      description = ''
        Yama restricts ptrace, which allows processes to read and modify the
        memory of other processes. This has obvious security implications.

        - `none`: Keep the default configuration of your kernel.
        - `relaxed`: Only allow parent processes to ptrace child processes.
        - `admin-only`: Only allow processes with with `CAP_SYS_PTRACE` capability or root to ptrace.
        - `restricted`: No processes may be traced with ptrace.

        ::: {.note}
        ptrace may be required for specific debugging or certain video game
        anti cheats. Usually, the `relaxed` option avoids most breakage.

        Additionally, envfs (https://github.com/Mic92/envfs) will fail
        with the `restricted` option. Errors regarding hardcoded paths
        when envfs is enabled should be resolved by setting to `admin-only`
        or below.
        :::
      '';
      default = "restricted";
      type = l.types.enum [
        "none"
        "relaxed"
        "admin-only"
        "restricted"
      ];
    };
  };

  config = l.mkIf (cfg != "none") {
    boot.kernel.sysctl."kernel.yama.ptrace_scope" = l.mkForce (
      if cfg == "relaxed" then
        "1"
      else if cfg == "admin-only" then
        "2"
      else
        "3"
    );
  };
}
