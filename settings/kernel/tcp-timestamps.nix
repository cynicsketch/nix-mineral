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
      Enables tcp_timestamps.
      Disabling prevents leaking system time, enabling protects against
      wrapped sequence numbers and improves performance.

      In favor of disabling:
      https://madaidans-insecurities.github.io/guides/linux-hardening.html#tcp-timestamps
      https://forums.whonix.org/t/do-ntp-and-tcp-timestamps-really-leak-your-local-time/7824/6

      In favor of enabling:
      https://access.redhat.com/sites/default/files/attachments/20150325_network_performance_tuning.pdf
      https://gitlab.tails.boum.org/tails/tails/-/issues/17491
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
      "net.ipv4.tcp_timestamps" = l.mkDefault "1";
    };
  };
}
