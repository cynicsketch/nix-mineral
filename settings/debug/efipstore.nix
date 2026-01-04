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
    efipstore = l.mkBoolOption ''
      If set to false, Disable both the EFI persistent storage feature and
      Error Record Serialization Table (ERST) support as a form of
      defense-in-depth. This prevents the kernel from writing crash logs
      and other persistent data to the storage backend.

      See:
      https://blogs.oracle.com/linux/pstore-linux-kernel-persistent-storage-file-system
      https://uefi.org/htmlspecs/ACPI_Spec_6_4_html/18_ACPI_Platform_Error_Interfaces/error-serialization.html
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernelParams = [
      "efi_pstore.pstore_disable=1"
      "erst_disable"
    ];
  };
}
