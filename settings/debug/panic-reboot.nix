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
    panic-reboot = l.mkBoolOption ''
      Force the system to automatically reboot upon kernel panic instead of
      freezing.

      This helps to mitigate denial of service attacks by automatically
      recovering and preventing the capture of information presented by a
      kernel panic screen.

      This may inhibit debugging kernel panics, since the immediate reboot
      prevents immediate analysis of error messages which may be displayed.
    '' true;
  };

  config = l.mkIf cfg {
    # Both sysctl and boot parameter are included for future reference and
    # redundancy.
    boot.kernelParams = [ "panic=-1" ];
    boot.kernel.sysctl = {
      "kernel.panic" = l.mkDefault "-1";
    };
  };
}
