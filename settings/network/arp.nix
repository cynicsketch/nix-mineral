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

      ignore = l.mkOption {
        description = ''
          Ignore/don't reply to specific ARP requests to limit scope of ARP
          spoofing.

          This may break certain VM networking configurations if set
          to 'link,' which can be fixed by setting to 'local' or 'none.'

          However, such a regression has been intentionally excluded from the
          compatibility preset unless new information or usecases are made
          apparent, given that this issue appears to be isolated to niche
          setups which NixOS is not known or advisable to be used for.

          See:
          https://github.com/Kicksecure/security-misc/pull/279
          https://github.com/Kicksecure/security-misc/pull/290
          https://github.com/QubesOS/qubes-issues/issues/9990
          https://github.com/mullvad/mullvadvpn-app/blob/main/audits/2024-12-10-X41-D-Sec.md#mllvd-cr-24-03-virtual-ip-address-of-tunnel-device-leaks-to-network-adjacent-participant-severity-medium
          https://github.com/mullvad/mullvadvpn-app/pull/7141

          `none` - Keep the default configuration of your kernel.
          `local` - Reply only if the target IP address is within the local
                    address range configured on the incoming interface
          `link` - Reply only if the target IP is on the same link.
        '';
        default = "link";
        type = l.types.enum [
          "none"
          "local"
          "link"
        ];
      };

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

      (l.mkIf (cfg.ignore != "none") {
        "net.ipv4.conf.default.arp_ignore" = l.mkDefault (if cfg == "local" then "1" else "2");
        "net.ipv4.conf.all.arp_ignore" = l.mkDefault (if cfg == "local" then "1" else "2");
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
