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
    ipv6-tempaddr = l.mkBoolOption ''
      Enable IPv6 Privacy Extensions (RFC3041) and prefer the temporary address
      https://grapheneos.org/features#wifi-privacy
      GrapheneOS devs seem to believe it is relevant to use IPV6 privacy
      extensions alongside MAC randomization, so consider doing both where
      applicable.

      Inclusive a "kitchen sink" config to enable privacy extensions in
      relevant daemons. If you do not use these, nothing will happen.

      If you use alternative daemons or replacements, considering looking at
      upstream documentation or filing a PR to add their configurations here.
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
      "net.ipv6.conf.default.use_tempaddr" = l.mkDefault "2";
      "net.ipv6.conf.all.use_tempaddr" = l.mkDefault "2";
    };

    networking.networkmanager.connectionConfig."ipv6.ip6-privacy" = l.mkDefault 2;
    systemd.network.config.networkConfig.IPv6PrivacyExtensions = l.mkDefault "kernel";
  };
}
