# Scope

By default, `nix-mineral` provides a configuration baseline for existing software
to reduce attack surface.

It is intended to be used for defense-in-depth purposes only. It is not, and will not
ever be intended as a substitute to the implementation of core security practices such
as strong OPSEC (operations security), sandboxing, privilege separation, or any other
primary guiding principle or framework.

For development simplicity, target systems are assumed to be running `nixos-unstable`.
Incompatibility may occur with renamed options, which should be manually overridden if necessary.

`nix-mineral` aims to serve as a drop-in addition to any NixOS system.

Because of this, complete overhauls of system UX or architecture is infeasible compared
to dedicated security focused operating systems with complete executive control over design.

`nix-mineral`'s threat model assumes non-state adversaries, and anonymity is
not considered.
