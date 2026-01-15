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
    tcp-timestamps = l.mkBoolOption ''
      Enables TCP timestamps.
      Disabling prevents leaking system time, enabling protects against
      wrapped sequence numbers and improves performance.

      Disabling implicitly disables reuse of TIME_WAIT sockets, as they depend
      on TCP timestamps which may lead to corruption and an inability to detect
      duplicate packets. It may also result in port exhaustion as ports may not
      be immediately reused.

      There are possible information leaks when timestamps are enabled.
      Offset randomization used by default prevents uptime prediction, but
      the rate of incrementing timestamps can be used in some advanced attacks
      to predict the current clock speed of a running system.

      Because nix-mineral has different priorities to Whonix, which influences
      Kicksecure's development, we choose not to disable timestamps by default
      since clock speed fingerprinting is not a useful threat to most people;
      if it is important, it is probably smarter to use another Linux
      distribution entirely.

      In favor of disabling:
      https://madaidans-insecurities.github.io/guides/linux-hardening.html#tcp-timestamps
      https://forums.whonix.org/t/do-ntp-and-tcp-timestamps-really-leak-your-local-time/7824/6

      In favor of enabling:
      https://access.redhat.com/sites/default/files/attachments/20150325_network_performance_tuning.pdf
      https://gitlab.tails.boum.org/tails/tails/-/issues/17491
    '' true;
  };

  config = l.mkMerge [
    (l.mkIf cfg {
      boot.kernel.sysctl = {
        "net.ipv4.tcp_timestamps" = l.mkDefault "1";
      };
    })
    (l.mkIf (!cfg) {
      boot.kernel.sysctl = {
        "net.ipv4.tcp_timestamps" = l.mkDefault "0";
        "net.ipv4.tcp_tw_reuse" = l.mkDefault "0";
      };
    })
  ];
}
