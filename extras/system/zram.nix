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
  imports = [
    (l.mkDeprecatedOptionModule [ "nix-mineral" "extras" "system" "zram" ] ''
      This option does not align with the current project scope

      Replace with `zramSwap.enable`.
    '')
  ];

  options = {
    zram = l.mkDeprecatedOption ''
      Enable zram so that memory is more likely to be compressed instead of
      written to disk, which may include sensitive information.

      Improves storage lifespan and overall performance when swapping as a
      side effect.

      ::: {.note}
      Not enabled by default due to interfering with zswap. Additionally, the
      task of limiting swapping of sensitive data depends highly on the user's
      individual swapping setup which can't be reliably inferred.
      :::
    '';
  };

  config = l.mkIf (cfg == true) {
    zramSwap.enable = true;
  };
}
