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

{ pkgs, nixosModule }:

pkgs.testers.runNixOSTest {
  name = "mineral-settings-system";

  nodes.machine = {
    imports = [ nixosModule ];
    nix-mineral.enable = true;
    nix-mineral.settings = {
      system = {
        file-protection = true;
        link-protection = true;
        lower-address-mmap = false;
        yama = "relaxed";
      };
      debug = {
        dmesg-restrict = true;
        kptr-restrict = true;
      };
    };
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("sysctl -n fs.protected_regular | grep -qx 2")
    machine.succeed("sysctl -n fs.protected_fifos | grep -qx 2")
    machine.succeed("sysctl -n fs.protected_hardlinks | grep -qx 1")
    machine.succeed("sysctl -n fs.protected_symlinks | grep -qx 1")
    machine.succeed("sysctl -n vm.mmap_min_addr | grep -qx 65536")
    machine.succeed("sysctl -n kernel.yama.ptrace_scope | grep -qx 1")
    machine.succeed("sysctl -n kernel.dmesg_restrict | grep -qx 1")
    machine.succeed("sysctl -n kernel.kptr_restrict | grep -qx 2")
  '';
}
