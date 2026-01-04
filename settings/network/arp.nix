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
    arp = {
      announce = l.mkBoolOption ''
        Always use the best local address for announcing local IP via ARP
        Seems to be most restrictive option
      '' true;

      ignore = l.mkBoolOption ''
        Reply only if the target IP address is local address configured on the incoming interface
      '' true;

      drop-gratuitous = l.mkBoolOption ''
        Drop Gratuitous ARP frames to prevent ARP poisoning
        this can cause issues when ARP proxies are used in the network
      '' true;

      filter = l.mkBoolOption ''
        Enable ARP filtering in the kernel to prevent the Linux kernel from
        handling the ARP table globally and mitigate some ARP spoofing and
        ARP cache poisoning attacks.
      '' true;
    };
  };

  config = {
    boot.kernel.sysctl = l.mkMerge [
      (l.mkIf cfg.announce {
        "net.ipv4.conf.default.arp_announce" = l.mkDefault "2";
        "net.ipv4.conf.all.arp_announce" = l.mkDefault "2";
      })

      (l.mkIf cfg.ignore {
        "net.ipv4.conf.default.arp_ignore" = l.mkDefault "1";
        "net.ipv4.conf.all.arp_ignore" = l.mkDefault "1";
      })

      (l.mkIf cfg.drop-gratuitous {
        "net.ipv4.conf.default.drop_gratuitous_arp" = l.mkDefault "1";
        "net.ipv4.conf.all.drop_gratuitous_arp" = l.mkDefault "1";
      })

      (l.mkIf cfg.filter {
        "net.ipv4.conf.default.arp_filter" = l.mkDefault "1";
        "net.ipv4.conf.all.arp_filter" = l.mkDefault "1";
      })
    ];
  };
}
