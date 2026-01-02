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
    kexec = l.mkBoolOption ''
      Prevent replacing the running kernel with kexec for security reasons.

      On other distributions, kexec is most notably used for updating the
      Linux kernel without rebooting, however, NixOS does not support this.

      A comprehensive list of usecases is not feasible, but consider consulting
      the following references as well as upstream documentation where
      necessary:

      https://docs.kernel.org/admin-guide/mm/kho.html
      https://github.com/NixOS/nixpkgs/issues/10726
      https://docs.kernel.org/admin-guide/kdump/kdump.html

    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      "kernel.kexec_load_disabled" = l.mkOverride 900 "1";
    };
  };
}
