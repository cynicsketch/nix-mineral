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
    lockdown = l.mkBoolOption ''
      Enable linux kernel lockdown, this blocks loading of unsigned kernel modules
      and breaks hibernation.

      ::: {.note}
      This currently does nothing as the default NixOS kernel config does not
      enable Linux kernel lockdown as of 16/03/26.

      It will remain implemented by default in the event that circumstances
      change, since adding the corresponding boot parameter anyways is harmless.]

      See:
      https://github.com/NixOS/nixpkgs/blob/baeac6edff1b03f0ecd063b8fe48e9742d0527e7/pkgs/os-specific/linux/kernel/common-config.nix#L830
      https://github.com/cynicsketch/nix-mineral/issues/125

      If `false`, you probably want to disable {option}`nix-mineral.settings.kernel.only-signed-modules`.
      :::
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernelParams = [
      "lockdown=confidentiality"
    ];
  };
}
