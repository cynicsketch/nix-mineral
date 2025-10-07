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
  pkgs,
  cfg,
  ...
}:

{
  options = {
    secure-chrony = l.mkBoolOption ''
      Replace systemd-timesyncd with chrony for NTP, and configure chrony for NTS
      and to use the seccomp filter for security.
    '' false;
  };

  config = l.mkIf cfg {
    services.timesyncd = {
      enable = l.mkDefault false;
    };
    services.chrony = {
      enable = l.mkDefault true;

      extraFlags = l.mkDefault [
        "-F 1"
        "-r"
      ];
      # Enable seccomp filter for chronyd (-F 1) and reload server history on
      # restart (-r). The -r flag is added to match GrapheneOS's original
      # chronyd configuration.

      enableRTCTrimming = l.mkDefault false;
      # Disable 'rtcautotrim' so that 'rtcsync' can be used instead. Either
      # this or 'rtcsync' must be disabled to complete a successful rebuild,
      # or an error will be thrown due to these options conflicting with
      # eachother.

      servers = l.mkDefault [ ];
      # Since servers are declared by the fetched chrony config, set the
      # NixOS option to [ ] to prevent the default values from interfering.

      initstepslew.enabled = l.mkDefault false;
      # Initstepslew "is deprecated in favour of the makestep directive"
      # according to:
      # https://chrony-project.org/doc/4.6/chrony.conf.html#initstepslew.
      # The fetched chrony config already has makestep enabled, so
      # initstepslew is disabled (it is enabled by default).

      # The below config is borrowed from GrapheneOS server infrastructure.
      # It enables NTS to secure NTP requests, among some other useful
      # settings.

      extraConfig = ''
        ${l.readFile (l.fetchGhFile l.sources.chrony)}
        leapseclist ${pkgs.tzdata}/share/zoneinfo/leap-seconds.list
      '';
      # Override the leapseclist path with the NixOS-compatible path to
      # leap-seconds.list using the tzdata package. This is necessary because
      # NixOS doesn't use standard FHS paths like /usr/share/zoneinfo.
    };
  };
}
