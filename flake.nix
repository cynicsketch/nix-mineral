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
  description = "Conveniently and reasonably harden NixOS.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";

    ndg.url = "github:feel-co/ndg";
  };

  outputs =
    inputs:

    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./lib
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt-rfc-style;

          packages.docs = pkgs.callPackage ./docs/package.nix {
            inherit inputs pkgs;
          };
        };

      flake.nixosModules = {
        nix-mineral = inputs.self.lib.importModule ./nix-mineral.nix { };
      };
    };
}
