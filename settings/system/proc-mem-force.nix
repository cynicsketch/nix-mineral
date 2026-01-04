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
    proc-mem-force = l.mkOption {
      description = ''
        Configure whether processes can modify their own memory mappings or
        not, which could be used for some exploits.

        See:
        https://github.com/Kicksecure/security-misc/pull/332

        `none` - Keep the default configuration of your kernel.
        `ptrace` - Only allow modification of memory mappings using ptrace. Affected by the "yama" option.
        `never` - Do not allow modifying memory mappings at all.
      '';
      default = "ptrace";
      type = l.types.enum [
        "none"
        "ptrace"
        "never"
      ];
    };
  };

  config = l.mkIf (cfg != "none") {
    boot.kernel.sysctl."proc_mem.force_override" = l.mkForce (
      if cfg == "ptrace" then "ptrace" else "never"
    );
  };
}
