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
    perf-subsystem = {
      restrict-usage = l.mkBoolOption ''
        Restrict perf subsystem usage (activity) to reduce attack surface.

        ::: {.note}
        See https://www.kernel.org/doc/html/latest/admin-guide/perf-security.html
        for more information.
        :::
      '' true;

      restrict-access = l.mkBoolOption ''
        Restrict perf subsystem access to reduce attack surface.

        ::: {.note}
        See:
        - https://www.kernel.org/doc/html/latest/admin-guide/perf-security.html
        :::
      '' true;
    };
  };

  config = {
    boot.kernel.sysctl = l.mkMerge [
      (l.mkIf cfg.restrict-usage {
        "kernel.perf_cpu_time_max_percent" = l.mkDefault "1";
        "kernel.perf_event_max_sample_rate" = l.mkDefault "1";
      })

      (l.mkIf cfg.restrict-access {
        # Note: This is set to 3 because additional restriction can be made
        # if a specific kernel patch is present. This reverts back to "2" in
        # terms of behavior if the patch isn't present, which is the default
        # behavior of NixOS.
        "kernel.perf_event_paranoid" = l.mkDefault "3";
      })
    ];
  };
}
