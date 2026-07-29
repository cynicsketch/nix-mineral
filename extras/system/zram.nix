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
    zram = l.mkBoolOption ''
      THIS OPTION IS NOW DEPRECATED. INFORMATION BELOW IS RETAINED FOR
      FUTURE REFERENCE, AND THIS OPTION IS SCHEDULED TO BE REMOVED PENDING THE
      NEXT RELEASE.

      Enable zram so that memory is more likely to be compressed instead of
      written to disk, which may include sensitive information.

      Improves storage lifespan and overall performance when swapping as a
      side effect.

      ::: {.note}
      Not enabled by default due to interfering with zswap. Additionally, the
      task of limiting swapping of sensitive data depends highly on the user's
      individual swapping setup which can't be reliably inferred.
      :::
    '' false;
  };

  config = l.mkIf cfg {
    warnings = l.optional cfg ''
      The option `nix-mineral.extras.system.zram` is deprecated due to not
      aligning with current project scope and will be removed in a future release.

      Replace with `zramSwap.enable` instead.
    '';
    zramSwap.enable = true;
  };
}
