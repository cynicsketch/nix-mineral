# Rationale

`nix-mineral` tries to address as many system level risks as possible, but there are some things which could improve security but are not feasible to implement.

This is most apparent when there are "switches" which can't necessarily be turned "on" and "off," or when setup can't be declarative.

Useful resources which could improve security, but can't be directly implemented in `nix-mineral` are listed here for individual reference.

# Resources

https://wiki.nixos.org/wiki/Encrypted_DNS
https://github.com/DNSCrypt/dnscrypt-proxy
Encrypted DNS. It's not that important, but you might as well. Not included due to significant disagreement on what the ideal DNS server to choose is. Encrypted DNS is easily rendered useless due to [adjacent information leaks](https://madaidans-insecurities.github.io/encrypted-dns.html). This is at no fault to encrypted DNS itself; it's encrypted just fine, but there's simply too many other ways to see or otherwise interfere with a user's browsing regardless. 

https://search.nixos.org/options?channel=25.05&from=0&size=50&sort=relevance&type=packages&query=services.resolved.
systemd-resolved can also provide encrypted DNS through DNS over TLS. Refer to the above entry for why this also isn't included by default.

https://github.com/infinisil/sanix
https://grahamc.com/blog/erase-your-darlings/
https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/
https://github.com/nix-community/impermanence
Statelessness, through whatever implementation, *may* result in malware being cleared on reboot. Not included, since it's easy to bypass if known about, and most solutions are highly dependent on other components of the user's configuration (requiring btrfs, zfs, high amounts of ram, and differing opinions on what to persist and what not to). There are many more implementations than listed.

https://github.com/nix-community/lanzaboote
Secure boot on NixOS, which is a highly impactful mitigation of "evil maid" attacks. Can't be set declaratively, although it's planned to mainlined at some point; when this happens, this will be integrated into `nix-mineral.`

https://madaidans-insecurities.github.io/security-privacy-advice.html
Basic OPSEC. Decent, concise advice. Many will disagree with, or just disregard a lot here, but the "General" advice here is applicable and useful to most people.

https://github.com/arkenfox/user.js
https://github.com/dwarfmaster/arkenfox-nixos
Most desktop NixOS users use Firefox. Locking it down a bit is commonsense.

https://codeberg.org/celenity/Phoenix
An arkenfox alternative featuring a NixOS module. This may make you stand out due to a smaller userbase, though.

https://github.com/ryantm/agenix
https://github.com/Mic92/sops-nix
Secrets management lets you more safely declaratively set password on NixOS, along with managing other sensitive info. Not included by default because people have different passwords (obviously) and if you imperatively set your password, you don't have to worry about this. There are many, many more implementations than listed.

https://github.com/nixpak/nixpak
https://github.com/Naxdy/nix-bwrapper
Bubblewrap is arguably the best sandboxing solution for desktop Linux. There's many projects to make using bubblewrap easier to use for nix, and these are just some examples. Convenient hardening is better than no hardening, though for fine grained control power users can manually sandbox their stuff or use something else. 

https://github.com/e-tho/ucodenix
TLDR; amd-ucode targets server CPUs mostly. BIOS updates update microcode consumer AMD CPUs, but if your OEM no longer provides updates your microcode will probably never be updated by a standard Linux setup. Luckily, someone made a tool to do so automatically. Unfortunately, your BIOS not being updated means that your microcode may also be prevented from updating... but harm reduction is better than nothing.

Rust replacements, for example:
https://github.com/trifectatechfoundation/sudo-rs
https://github.com/pendulum-project/ntpd-rs
All other rust replacements for common Linux services and applications fall under this catagory unless they do something "novel." You need to ask yourself whether guaranteed memory safety is worth the risk of less audited, and an often larger codebase. Do you trust the programming language architecture or the programmer more? Is it really a good idea to replace a C app which has worked just fine and has been written by a likely more experienced programmer for decades?

https://datatracker.ietf.org/doc/rfc8915/
Consider using NTP implementations that support NTS. There are many out there that exist. Encrypting NTP means red team can't mess with your system time, which can interfere with some forms of online authentication.

https://wiki.nixos.org/wiki/Automatic_system_upgrades
Regular updates keep your system patched from many known vulnerabilities. Not included by default because most people will schedule their auto-updates differently (or object to automatic updates entirely for a variety of non-security related reasons, e.g avoiding unwanted feature changes).

https://wiki.nixos.org/wiki/Chromium
Tangentially related. For some reason, Chromium doesn't use Wayland by default on NixOS. This means no window isolation, and it comes with the added effect that Chromium is a blurry mess if you use display scaling. 

https://github.com/lkrg-org/lkrg
Supposedly kills several classes of vulnerabilities in the Linux kernel. Excluded due to apparent breakage on NixOS. Pending any additional testing or workarounds, this may be reconsidered.
See https://github.com/cynicsketch/nix-mineral/issues/48 and https://www.kicksecure.com/wiki/Linux_Kernel_Runtime_Guard_LKRG#Deprecation_in_Kicksecure
