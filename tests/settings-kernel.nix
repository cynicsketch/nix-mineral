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
  pkgs,
  nixosModule,
}:
# Check for kernel params
pkgs.testers.runNixOSTest {
  name = "mineral-settings-kernel";

  nodes.machine = {
    imports = [ nixosModule ];
    nix-mineral.enable = true;
    nix-mineral.settings.kernel = {
      restrict-bpf = true;
      harden-bpf = true;
      restrict-line-disciplines = true;
      tiocsti = false;
      sysrq = "off";
      kexec = false;
      io-uring = false;
      bdev-write-mount = false;
      vsyscall = false;
      slab-merging = false;
    };
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("sysctl -n kernel.unprivileged_bpf_disabled | grep -qx 1")
    machine.succeed("sysctl -n net.core.bpf_jit_harden | grep -qx 2")
    machine.succeed("sysctl -n dev.tty.ldisc_autoload | grep -qx 0")
    machine.succeed("sysctl -n dev.tty.legacy_tiocsti | grep -qx 0")
    machine.succeed("sysctl -n kernel.sysrq | grep -qx 0")
    machine.succeed("sysctl -n kernel.kexec_load_disabled | grep -qx 1")
    machine.succeed("sysctl -n kernel.io_uring_disabled | grep -qx 2")
    machine.succeed("grep -q bdev_allow_write_mounted=0 /proc/cmdline")
    machine.succeed("grep -q vsyscall=none /proc/cmdline")
    machine.succeed("grep -q slab_nomerge /proc/cmdline")
  '';
}
