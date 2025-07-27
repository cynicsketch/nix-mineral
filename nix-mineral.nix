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

# Primarily sourced was madaidan's Linux Hardening Guide. See for details:
# URL: https://madaidans-insecurities.github.io/guides/linux-hardening.html
# Archive: https://web.archive.org/web/20220320000126/https://madaidans-insecurities.github.io/guides/linux-hardening.html

# Additionally sourced is privsec's Desktop Linux Hardening:
# URL: https://privsec.dev/posts/linux/desktop-linux-hardening/
# Archive: https://web.archive.org/web/20240629135847/https://privsec.dev/posts/linux/desktop-linux-hardening/#kernel

# Bluetooth configuration and module blacklist, and many more config files were
# borrowed from Kicksecure's security-misc:
# URL: https://github.com/Kicksecure/security-misc

# Supplement to sysctl configuration borrowed from Tommy's Linux-Setup-Scripts:
# URL: https://github.com/TommyTran732/Linux-Setup-Scripts/blob/main/etc/sysctl.d/99-workstation.conf

# Chrony configuration was borrowed from GrapheneOS server infrastructure:
# URL: https://github.com/GrapheneOS/infrastructure

# Original idea to restrict nix to wheel user from Xe Iaso:
# URL: https://xeiaso.net/blog/paranoid-nixos-2021-07-18/

# NixOS snippet for hiding process information from anon* (obviously throwaway
# Reddit account)
# URL: https://www.reddit.com/r/NixOS/comments/1aqfuxq/bootloaderkernel_hardening_for_nixos/

# More relevant sysctl configuration from K4YT3X's sysctl:
# URL: https://github.com/k4yt3x/sysctl/blob/master/sysctl.conf

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
#
# USBGuard is also *enabled* by default, which may inconvenience some users.
#
# All of this can, and should be addressed using the overrides file.
# "nm-overrides.nix"

{
  options,
  config,
  pkgs,
  lib,
  ...
}:

let
  l = lib // builtins;

  cfg = config.nix-mineral;

  mkBoolOption =
    desc: bool:
    l.mkOption {
      default = bool;
      example = !bool;
      description = desc;
      type = l.types.bool;
    };
in
{
  options = {
    nix-mineral = {
      enable = l.mkEnableOption "the nix-mineral module";

      settings = {
        kernel = l.mkOption {
          description = ''
            Settings meant to harden the linux kernel.
          '';
          default = { };
          type = l.types.submodule {
            options = {
              only-signed-modules = mkBoolOption ''
                Requires all kernel modules to be signed. This prevents out-of-tree
                kernel modules from working unless signed.

                (if false, `${options.nix-mineral.settings.kernel.lockdown}` must also be false)
              '' true;

              lockdown = mkBoolOption ''
                Enable linux kernel lockdown, this blocks loading of unsigned kernel modules
                and breaks hibernation.
              '' true;

              busmaster-bit = mkBoolOption ''
                Enable busmaster bit at boot.
                if false, this may prevent low resource systems from booting.
              '' false;

              iommu-passthrough = mkBoolOption ''
                Enable bypassing the IOMMU for direct memory access. Could increase I/O
                performance on ARM64 systems, with risk.
                if false, forces DMA to go through IOMMU to mitigate some DMA attacks.
              '' false;

              cpu-mitigations = l.mkOption {
                description = ''
                  Apply relevant CPU exploit mitigations, May harm performance.

                  `smt-off` - Enable CPU mitigations and disables symmetric multithreading.
                  `smt-on` - Enable symmetric multithreading and just use default CPU mitigations,
                  to potentially improve performance.
                  `off` - Disables all CPU mitigations. May improve performance further,
                  but is even more dangerous!
                '';
                default = "smt-off";
                type = l.types.enum {
                  values = [
                    "smt-off"
                    "smt-on"
                    "off"
                  ];
                };
              };

              pti = mkBoolOption ''
                Enable Page Table Isolation (PTI) to mitigate some KASLR bypasses and
                the Meltdown CPU vulnerability. It may also tax performance.
              '' true;

              binfmt-misc = mkBoolOption ''
                Enable binfmt_misc, (https://en.wikipedia.org/wiki/Binfmt_misc).
                if false, breaks Roseta, among other applications.
              '' false;

              io-uring = mkBoolOption ''
                Enable io_uring, is the cause of many vulnerabilities,
                and is disabled on Android + ChromeOS.
                This may be desired for specific environments concerning Proxmox.
              '' false;
            };
          };
        };

        system = l.mkOption {
          description = ''
            Settings for the system.
          '';
          default = { };
          type = l.types.submodule {
            options = {
              multilib = mkBoolOption ''
                Enable multilib support, allowing 32-bit libraries and applications to run.
                if false, this may cause issues with certain games that still require 32-bit libraries.
              '' false;

              unprivileged-userns = mkBoolOption ''
                Enable unprivileged user namespaces, is a large attack surface
                and has been the cause of many privilege escalation vulnerabilities,
                but can cause breakage. It is used in the Chromium sandbox, unprivileged containers,
                and bubblewrap among many other applications.
                if false, this may break some applications that rely on user namespaces.
              '' false;

              nix-allow-only-wheel = mkBoolOption ''
                Limit access to nix commands to users with the "wheel" group. ("sudoers")
                if false, may be useful for allowing a non-wheel user to, for example, use devshell.
              '' true;
            };
          };
        };

        network = l.mkOption {
          description = ''
            Settings for the network.
          '';
          default = { };
          type = l.types.submodule {
            options = {
              ip-forwarding = mkBoolOption ''
                Enable or disable IP forwarding.
                if false, this may cause issues with certain VM networking,
                and must be true if the system is meant to function as a router.
              '' false;
            };
          };
        };

        programs = l.mkOption {
          description = ''
            Options to add (or remove) opinionated software replacements by nix-mineral.
          '';
          default = { };
          type = l.types.submodule {
            options = {
              replace-sudo-with-doas = mkBoolOption ''
                Replace sudo with doas, doas has a lower attack surface, but is less audited.
              '' false;

              doas-sudo-wrapper = mkBoolOption ''
                Creates a wrapper for doas to simulate sudo, with nano to utilize rnano as
                editor for editing as root.
              '' false;
            };
          };
        };
      };
    };
  };

  config = l.mkIf cfg.enable (
    l.mkMerge [
      # Kernel configurations
      (l.mkIf cfg.settings.kernel.only-signed-modules {
        boot.kernelParams = [
          "module.sig_enforce=1"
        ];
      })

      (l.mkIf cfg.settings.kernel.only-signed-modules {
        boot.kernelParams = [
          "lockdown=confidentiality"
        ];
      })

      (l.mkIf (!cfg.settings.kernel.busmaster-bit) {
        boot.kernelParams = [
          "efi=disable_early_pci_dma"
        ];
      })

      (l.mkIf (!cfg.settings.kernel.iommu-passthrough) {
        boot.kernelParams = [
          "iommu.passthrough=0"
        ];
      })

      {
        boot.kernelParams = [
          "${
            if (cfg.settigs.kernel.cpu-mitigations == "smt-off") then
              "mitigations=auto,nosmt"
            else if (cfg.settigs.kernel.cpu-mitigations == "smt-on") then
              "mitigations=auto"
            else
              "mitigations=off"
          }"
        ];
      }

      (l.mkIf cfg.settings.kernel.pti {
        boot.kernelParams = [
          "pti=on"
        ];
      })

      (l.mkIf (!cfg.settings.kernel.binfmt-misc) {
        boot.kernel.sysctl = {
          "fs.binfmt_misc.status" = l.mkDefault "0";
        };
      })

      (l.mkIf (!cfg.settings.kernel.io-uring) {
        boot.kernel.sysctl = {
          "kernel.io_uring_disabled" = l.mkDefault "2";
        };
      })

      # System configurations
      (l.mkIf (!cfg.settings.system.multilib) {
        boot.kernelParams = [
          "ia32_emulation=0"
        ];
      })

      (l.mkIf (!cfg.settings.system.unprivileged-userns) {
        boot.kernel.sysctl = {
          "kernel.unprivileged_userns_clone" = l.mkDefault "0";
        };
      })

      (l.mkIf cfg.settings.system.nix-allow-only-wheel {
        nix.settings.allowed-users = l.mkDefault [ "@wheel" ];
      })

      # Network configurations
      (l.mkIf (!cfg.settings.network.ip-forwarding) {
        boot.kernel.sysctl = {
          # NOTE: `mkOverride 900` is used when a default value is already defined in NixOS.
          "net.ipv4.ip_forward" = l.mkDefault "0";
          "net.ipv4.conf.all.forwarding" = l.mkOverride 900 "0";
          "net.ipv4.conf.default.forwarding" = l.mkDefault "0";
          "net.ipv6.conf.all.forwarding" = l.mkDefault "0";
          "net.ipv6.conf.default.forwarding" = l.mkDefault "0";
        };
      })

      # Programs configurations
      (l.mkIf cfg.settings.programs.replace-sudo-with-doas {
        security.sudo.enable = l.mkDefault false;
        security.doas = {
          enable = l.mkDefault true;
          extraRules = [
            {
              keepEnv = l.mkDefault true;
              persist = l.mkDefault true;
              users = l.mkDefault [ "user" ];
            }
          ];
        };
      })

      (l.mkIf cfg.settings.programs.doas-sudo-wrapper {
        environment.systemPackages = with pkgs; [
          (writeScriptBin "sudo" ''exec ${l.getExe doas} "$@"'')
          (writeScriptBin "sudoedit" ''exec ${l.getExe doas} ${l.getExe' nano "rnano"} "$@"'')
          (writeScriptBin "doasedit" ''exec ${l.getExe doas} ${l.getExe' nano "rnano"} "$@"'')
        ];
      })
    ]
  );
}
