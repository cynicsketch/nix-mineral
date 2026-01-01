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
    unprivileged-userfaultfd = l.mkBoolOption ''
      If set to false, limit access to userfaultfd() syscall to the
      CAP_SYS_PTRACE capability.

      userfaultfd has been used for use-after-free exploits in the past.

      See:
      https://man7.org/linux/man-pages/man2/userfaultfd.2.html
      https://duasynt.com/blog/linux-kernel-heap-spray
      https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=cefdca0a86be517bc390fc4541e3674b8e7803b0
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      "vm.unprivileged_userfaultfd" = l.mkDefault "0";
    };
  };
}
