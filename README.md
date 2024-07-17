# nix-mineral
NixOS module for convenient system hardening.
Rather than be named after a mineral, it's named after the word "mineral."

# Scope
Reasonably harden NixOS in a way that can be quickly deployed by the end user. Threat model assumes non-governmental adversaries, anonymity is not considered.

# Usage
Import "nix-mineral.nix" into your NixOS config, and add "nm-overrides.nix" to the same folder. Edit "nm-overrides.nix" to weaken restrictions accordingly to user needs. Read carefully, because it is highly likely that the defaults will obstruct your usecase without overrides.

