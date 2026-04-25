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
    aslr-max-bits = l.mkBoolOption ''
      Use the maximum number of bits of entropy to address space layout
      randomization, a widely used mitigation against memory exploits.

      ::: {.note}
      THIS OPTION IS NOW DEPRECATED. INFORMATION BELOW IS RETAINED FOR
      FUTURE REFERENCE, AND THIS OPTION IS SCHEDULED TO BE REMOVED PENDING THE
      NEXT RELEASE.

      The values used here are currently only valid for x86_64.

      Other CPU architectures may require different numbers here, consult
      upstream documentation as necessary.
      :::

      ::: {.note}
      See:
      - https://en.wikipedia.org/wiki/Address_space_layout_randomization
      :::
    '' false;
  };

  config = l.mkIf cfg {
    warnings = l.optional cfg ''
      The option `nix-mineral.settings.entropy.aslr-max-bits` is deprecated
      due to being integrated upstream and will be removed in a future release.

      See: https://github.com/NixOS/nixpkgs/commit/4971c9331a72deeda85ba8d8018a5b07ee6f1635

      This option no longer does anything in order to avoid evaluation
      conflicts on NixOS unstable as of 4/24/26.

      Use `boot.kernel.sysctl."vm.mmap_rnd_bits"` instead.
    '';
    # boot.kernel.sysctl = {
    #   "vm.mmap_rnd_bits" = l.mkDefault "32";
    #   "vm.mmap_rnd_compat_bits" = l.mkDefault "16";
    # };
  };
}
