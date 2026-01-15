# Non-specific omissions
- Most "replacement" software is omitted due to causing breakage or interfering
with user freedom.

- Examples include most rust replacements for common utilities, such as sudo-rs
or ntpd-rs. 

- There may be exceptions for software which does not interfere with existing
user software preferences. For example, `apparmor` is whitelisted from this due to being the only usable
MAC system on NixOS.

- Future reference for potentially useful software which is still omitted under
this rule may be added to [ADDITIONAL-RESOURCES.md](ADDITIONAL-RESOURCES.md)

- Remember that this is supposed to be a drop-in NixOS module and not a Linux distribution. Common sense constraints on scope have to apply.

# Specific omissions
Features in sources of research for `nix-mineral` which have been intentionally omitted due to irrelevancy or logistical issues.

`linux-hardened` is not used because it breaks unpriviliged userns and has
historically failed to receive regular updates in nixpkgs.

## sysctl omitted from K4YT3X config that are out of scope of nix-mineral and hardening but may be useful anyways to some, see their repo for details:
kernel.pid_max = 4194304 \
kernel.panic = 10 \
fs.file-max = 9223372036854775807 \
fs.inotify.max_user_watches = 524288 \
net.core.netdev_max_backlog = 250000 \
net.core.rmem_default = 8388608 \
net.core.wmem_default = 8388608 \
net.core.rmem_max = 536870912 \
net.core.wmem_max = 536870912 \
net.core.optmem_max = 40960 \
net.ipv4.tcp_congestion_control = bbr \
net.ipv4.tcp_synack_retries = 5 \
net.ipv4.ip_local_port_range = 1024 65535 \
net.ipv4.tcp_slow_start_after_idle = 0 \
net.ipv4.tcp_mtu_probing = 1 \
net.ipv4.tcp_base_mss = 1024 \
net.ipv4.tcp_rmem = 8192 262144 536870912 \
net.ipv4.tcp_wmem = 4096 16384 536870912 \
net.ipv4.tcp_adv_win_scale = -2 \
net.ipv4.tcp_notsent_lowat = 131072

## Sections from madaidan's guide that are IRRELEVANT/NON-APPLICABLE:
1 (Advice) \
2.1 (Advice) \
2.3.3 (Advice) \
2.5.1 (Advice) \
2.5.3 (Advice) \
2.6 (Advice) \
2.10 (Package is broken) \
7 (Advice) \
10.5.4 (The problem of NTP being unencrypted is fixed by using NTS instead.
Note that this means using chrony, as in "Software Choice" in the overrides,
which is not default behavior!) \
11 (Partially, there seems to be no way to edit the permissions of /boot
whether with mount options or through tmpfiles) \
15 (Implemented by default) \
19 (Advice) \
20 (Not relevant) \
21.7 (Advice, not in threat model) \
22 (Advice)

## Sections from madaidan's guide requiring manual user intervention:
2.7 (systemd service hardening must be done manually) \
2.9 (Paid software) \
2.11 (Unique for all hardware, inconvenient) \
4 (Sandboxing must be done manually) \
6 (Compiling everything is inconvenient) \
8.6 (No option, not for all systems) \
8.7 (Inconvenient, depends on specific user behavior) \
10.1 (Up to user to determine hostname and username) \
10.2 (Up to user to determine timezone, locale, and keymap) \
10.5.3 (Not packaged) \
10.6 (Not packaged, inconvenient and not within threat model) \
11.1 (Manual removal of SUID/SGID is manual) \
11.2 (No known way to set umask declaratively systemwide, use your shellrc
or home manager to do so) \
14 (Rather than enforce password quality with PAM, expect user
to enforce their own password quality; faildelay is, however,
implemented here) \
21.1 (Out of scope) \
21.2 (See above) \
21.3 (User's job to set passwords) \
21.3.1 (See above) \
21.3.2 (See above) \
21.3.3 (See above) \
21.4 (Non-declarative setup, experimental)

## sysctl omitted due to already being used by default on NixOS:
"vm.max_map_count=1048576" (Due to its relevance in reducing crashes for memory intensive applications, despite a secondary need to be used in order to have enough guard pages for hardened_malloc)
