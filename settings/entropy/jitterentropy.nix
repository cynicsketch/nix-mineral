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
  config,
  ...
}:

{
  options = {
    jitterentropy = l.mkBoolOption ''
      Enable jitterentropy with both the daemon and the kernel module to
      provide additional entropy and compensate for disabled hardware
      entropy sources.

      Read more about why at:
      https://github.com/smuellerDD/jitterentropy-rngd/issues/27
      https://blogs.oracle.com/linux/post/rngd1
      https://github.com/Kicksecure/security-misc/commit/fe1f1b73a77d11c136cedcdb3efcb57f4c68c6af
    '' true;
  };

  config = l.mkIf {
    services.jitterentropy-rngd.enable = l.mkDefault (!config.boot.isContainer);
    boot.kernelModules = l.mkDefault [ "jitterentropy_rng" ];
  };
}
