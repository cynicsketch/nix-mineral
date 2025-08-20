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

# This is the main module for nix-mineral, containing the default configuration.

### CREDITS ###
# Please, see the README and give your thanks and support to the people and projects
# which have helped this project's development!

# sysctl omitted from K4YT3X config that are out of scope of nix-mineral and
# hardening  but may be useful anyways to some, see their repo for details:
# kernel.core_uses_pid = 1
# kernel.pid_max = 4194304
# kernel.panic = 10
# fs.file-max = 9223372036854775807
# fs.inotify.max_user_watches = 524288
# net.core.netdev_max_backlog = 250000
# net.core.rmem_default = 8388608
# net.core.wmem_default = 8388608
# net.core.rmem_max = 536870912
# net.core.wmem_max = 536870912
# net.core.optmem_max = 40960
# net.ipv4.tcp_congestion_control = bbr
# net.ipv4.tcp_synack_retries = 5
# net.ipv4.ip_local_port_range = 1024 65535
# net.ipv4.tcp_slow_start_after_idle = 0
# net.ipv4.tcp_mtu_probing = 1
# net.ipv4.tcp_base_mss = 1024
# net.ipv4.tcp_rmem = 8192 262144 536870912
# net.ipv4.tcp_wmem = 4096 16384 536870912
# net.ipv4.tcp_adv_win_scale = -2
# net.ipv4.tcp_notsent_lowat = 131072

# Sections from madaidan's guide that are IRRELEVANT/NON-APPLICABLE:
# 1. (Advice)
# 2.1 (Advice)
# 2.3.3 (Advice)
# 2.5.1 (Advice)
# 2.5.3 (Advice)
# 2.6 (Advice)
# 2.10 (Package is broken)
# 7 (Advice)
# 10.5.4 (The problem of NTP being unencrypted is fixed by using NTS instead.
# Note that this means using chrony, as in "Software Choice" in the overrides,
# which is not default behavior!)
# 11 (Partially, there seems to be no way to edit the permissions of /boot
# whether with mount options or through tmpfiles)
# 15 (Implemented by default)
# 19 (Advice)
# 20 (Not relevant)
# 21.7 (Advice, not in threat model)
# 22 (Advice)

# Sections from madaidan's guide requiring manual user intervention:
# 2.7 (systemd service hardening must be done manually)
# 2.9 (Paid software)
# 2.11 (Unique for all hardware, inconvenient)
# 4 (Sandboxing must be done manually)
# 6 (Compiling everything is inconvenient)
# 8.6 (No option, not for all systems)
# 8.7 (Inconvenient, depends on specific user behavior)
# 10.1 (Up to user to determine hostname and username)
# 10.2 (Up to user to determine timezone, locale, and keymap)
# 10.5.3 (Not packaged)
# 10.6 (Not packaged, inconvenient and not within threat model)
# 11.1 (Manual removal of SUID/SGID is manual)
# 11.2 (No known way to set umask declaratively systemwide, use your shellrc
# or home manager to do so)
# 14 (Rather than enforce password quality with PAM, expect user
# to enforce their own password quality; faildelay is, however,
# implemented here)
# 21.1 (Out of scope)
# 21.2 (See above)
# 21.3 (User's job to set passwords)
# 21.3.1 (See above)
# 21.3.2 (See above)
# 21.3.3 (See above)
# 21.4 (Non-declarative setup, experimental)

# ABOUT THE DEFAULTS:
# The default config harms performance and usability in many ways, focusing
# almost entirely on hardening alone.
#
# There are also some optional software substitutions and additions in the
# overrides that are recommended but *not enabled* by default:
#
# sudo ---> doas (For reduced attack surface; although less audited)
# systemd-timesyncd ---> chrony (For NTS support)
# linux_hardened kernel*
#
# As of Decemeber 26, 2024, linux_hardened is up to date with mainline linux in
# unstable NixOS. However, it is cautioned that users regularly check the
# status of the linux_hardened package in NixOS, because it has been left
# unupdated for long periods of time in the past, which would be a severe
# security risk since an outdated kernel means the existence of many known
# vulnerabilities in the most privileged component of the operating system.

{
  options,
  config,
  pkgs,
  lib,
  l,
  ...
}:

let
  cfg = config.nix-mineral;

  settingsModules =
    l.mkCategoryModules cfg.settings
      [
        ./settings/kernel
        ./settings/system
        ./settings/network
      ]
      {
        inherit
          options
          config
          pkgs
          lib
          ;
      };

  extrasModules =
    l.mkCategoryModules cfg.extras
      [
        ./extras/replace-sudo-with-doas.nix
        ./extras/doas-sudo-wrapper.nix
        ./extras/secure-chrony.nix
        ./extras/usbguard.nix
      ]
      {
        inherit
          options
          config
          pkgs
          lib
          ;
      };
in
{
  options = {
    nix-mineral = {
      enable = l.mkEnableOption "the nix-mineral module";

      settings = l.mkOption {
        description = ''
          nix-mineral settings.
        '';
        default = { };
        type = l.mkCategorySubmodule settingsModules;
      };

      extras = l.mkOption {
        description = ''
          Extra options that are not part of the main configuration.
          Most of those are relatively opinionated additional software.
        '';
        default = { };
        type = l.mkCategorySubmodule extrasModules;
      };
    };
  };

  config = l.mkIf cfg.enable (
    l.mkMerge [
      (l.mkCategoryConfig settingsModules)
      (l.mkCategoryConfig extrasModules)
    ]
  );
}
