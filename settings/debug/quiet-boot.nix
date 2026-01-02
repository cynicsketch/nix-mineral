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
    quiet-boot = l.mkBoolOption ''
      If set to true, minimize information displayed during boot to reduce
      information available to an attacker.
    '' true;
  };

  config = l.mkIf cfg {
    boot.consoleLogLevel = l.mkDefault 0;
    boot.initrd.verbose = l.mkDefault false;
    boot.kernelParams = [
      "quiet"
      "udev.log_level=3"
    ];
  };
}
