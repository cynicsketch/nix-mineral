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
    bdev-write-mount = l.mkBoolOption ''
      If set to false, prevent runaway privileged processes from writing to
      block devices to protect against runaway privileged processes causing
      filesystem corruption and kernel crashes.

      ::: {.note}
      See:
      - https://github.com/Kicksecure/security-misc/pull/334
      - https://github.com/a13xp0p0v/kernel-hardening-checker
      :::
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernelParams = [ "bdev_allow_write_mounted=0" ];
  };
}
