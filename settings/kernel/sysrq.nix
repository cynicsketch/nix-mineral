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
    sysrq = l.mkOption {
      description = ''
        Control the magic SysRq key functionality of the Linux kernel.

        It is a 'magical' key combo you can hit which the kernel will respond to regardless of whatever else it is doing,
        unless it is completely locked up.

        - `none`: Keep the default configuration of your kernel.
        - `off`: Disables sysrq completely.
        - `sak`: Enable SAK (Secure Attention Key).

        ::: {.note}
        SAK prevents keylogging, if used correctly. See:
        - https://madaidans-insecurities.github.io/guides/linux-hardening.html#accessing-root-securely
        - https://www.kicksecure.com/wiki/Login_spoofing
        :::
      '';
      default = "off";
      type = l.types.enum [
        "none"
        "off"
        "sak"
      ];
    };
  };

  config = l.mkIf (cfg != "none") {
    boot.kernel.sysctl."kernel.sysrq" = l.mkForce (if cfg == "off" then "0" else "4");
  };
}
