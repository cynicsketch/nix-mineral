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
    busmaster-bit = l.mkBoolOption ''
      Enable busmaster bit at boot, which may prevent some DMA attacks in
      the period where there the firmware IOMMU is no longer active and
      the kernel IOMMU has not yet fully initialized.

      ::: {.warning}
      If `false`, this may prevent systems with low resource OR specific
      firmware configurations from booting.

      May worsen performance as a side effect.

      See:
      - https://kspp.github.io/Recommended_Settings
      - https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
      - https://en.wikipedia.org/wiki/Bus_mastering
      - https://cateee.net/lkddb/web-lkddb/EFI_DISABLE_PCI_DMA.html
      - https://github.com/FrameworkComputer/SoftwareFirmwareIssueTracker/issues/8
      :::
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernelParams = [
      "efi=disable_early_pci_dma"
    ];
  };
}
