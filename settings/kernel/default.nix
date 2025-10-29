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
  options,
  config,
  pkgs,
  lib,
  l,
  cfg,
  ...
}:

let
  categoryModules =
    l.mkCategoryModules cfg
      [
        ./only-signed-modules.nix
        ./lockdown.nix
        ./busmaster-bit.nix
        ./iommu-passthrough.nix
        ./cpu-mitigations.nix
        ./pti.nix
        ./binfmt-misc.nix
        ./io-uring.nix
        ./amd-iommu-force-isolation.nix
        ./restrict-perf-subsystem-usage.nix
        ./paranoid-perf-subsystem.nix
        ./sysrq.nix
        ./tcp-timestamps.nix
      ]
      {
        inherit
          options
          config
          pkgs
          lib
          ;
      };
in
{
  options = {
    kernel = l.mkOption {
      description = ''
        Settings meant to harden the linux kernel.
      '';
      default = { };
      type = l.mkCategorySubmodule categoryModules;
    };
  };

  config = l.mkCategoryConfig categoryModules;
}
