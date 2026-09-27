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

{ pkgs, nixosModule }:

let
  mkTest = path: import path { inherit pkgs nixosModule; };
in
{
  mineral-settings-kernel = mkTest ./settings-kernel.nix;
  mineral-settings-network = mkTest ./settings-network.nix;
  mineral-settings-system = mkTest ./settings-system.nix;
  mineral-extras-chrony = mkTest ./extras-chrony.nix;
  mineral-extras-usbguard = mkTest ./extras-usbguard.nix;
  mineral-preset-default = mkTest ./preset-default.nix;
  mineral-preset-maximum = mkTest ./preset-maximum.nix;
}
