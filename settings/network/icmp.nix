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
    icmp = {
      cast = l.mkBoolOption ''
        Set to false to ignore all ICMPv6 and ICMPv4 echo and timestamp requests
        sent to broadcast/multicast/anycast.

        Makes system slightly harder to enumerate on a network.

        ::: {.note}
        Redundant with {option}`nix-mineral.settings.network.icmp.ignore-all` enabled.
        :::
      '' false;

      ignore-all = l.mkBoolOption ''
        Set to true to ignore all ICMPv6 and ICMPv4 echo and timestamp requests.

        Makes system slightly harder to enumerate on a network.

        You will not be able to ping this computer with ICMP packets if this is
        enabled.
      '' true;

      ignore-bogus = l.mkBoolOption ''
        Ignore bogus ICMP error responses to reduce potential system impact
        caused by spammed error responses.
      '' true;

      redirect = l.mkBoolOption ''
        Set to false to disable ICMP redirects to prevent some MITM attacks.

        ::: {.note}
        See https://askubuntu.com/questions/118273/what-are-icmp-redirects-and-should-they-be-blocked
        :::
      '' false;

      secure-redirect = l.mkBoolOption ''
        Use secure ICMP redirects by default.

        ::: {.note}
        Helpful only if {option}`nix-mineral.settings.network.icmp.redirect` is enabled, otherwise this does nothing.
        Not harmful to leave enabled even if unnecessary.
        :::
      '' true;
    };
  };

  config = {
    # NOTE: `mkOverride 900` is used when a default value is already defined in NixOS.
    boot.kernel.sysctl = l.mkMerge [
      (l.mkIf (!cfg.cast) {
        "net.ipv4.icmp_echo_ignore_broadcasts" = l.mkOverride 900 "1";
        "net.ipv6.icmp.echo_ignore_anycast" = l.mkDefault "1";
        "net.ipv6.icmp.echo_ignore_multicast" = l.mkDefault "1";
      })

      (l.mkIf cfg.ignore-all {
        "net.ipv6.icmp.echo_ignore_all" = l.mkDefault "1";
        "net.ipv4.icmp_echo_ignore_all" = l.mkDefault "1";
      })

      (l.mkIf cfg.ignore-bogus {
        "net.ipv4.icmp_ignore_bogus_error_responses" = l.mkDefault "1";
      })

      (l.mkIf (!cfg.redirect) {
        "net.ipv4.conf.all.accept_redirects" = l.mkOverride 900 "0";
        "net.ipv4.conf.default.accept_redirects" = l.mkOverride 900 "0";
        "net.ipv4.conf.all.send_redirects" = l.mkOverride 900 "0";
        "net.ipv4.conf.default.send_redirects" = l.mkOverride 900 "0";
        "net.ipv6.conf.all.accept_redirects" = l.mkOverride 900 "0";
        "net.ipv6.conf.default.accept_redirects" = l.mkOverride 900 "0";
      })

      (l.mkIf cfg.secure-redirect {
        "net.ipv4.conf.all.secure_redirects" = l.mkOverride 900 "1";
        "net.ipv4.conf.default.secure_redirects" = l.mkOverride 900 "1";
      })
    ];
  };
}
