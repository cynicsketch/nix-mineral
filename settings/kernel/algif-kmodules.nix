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
  config,
  ...
}:

let
  # Only enable if `networking.wireless.iwd.enable` exists (avoid failing tests) and is enabled, since iwd uses AF_ALG.
  iwdEnabled =
    config ? networking
    && config.networking ? wireless
    && config.networking.wireless ? iwd
    && config.networking.wireless.iwd ? enable
    && config.networking.wireless.iwd.enable;
in
{
  options = {
    algif-kmodules =
      l.mkBoolOption ''
        Algif related kernel modules.

        The existence of AF_ALG has been criticized for a long time,
        and has been the source of multiple vulnerabilities such as [CVE-2026-31431](https://github.com/advisories/GHSA-2274-3hgr-wxv6).

        With the exception of iwd, AF_ALG is practically only used in some unspecified rare
        and bespoke applications meant for embedded systems, so normally you can disable this
        without any consequences.

        By default, this will prevent AF_ALG related kernel modules from loading if iwd
        is not enabled.

        ::: {.note}
        Read more:
        - https://lore.kernel.org/all/20260430021042.GA51782@sol/
        - https://www.chronox.de/libkcapi/html/ch01s02.html
        - https://lore.kernel.org/all/CAMj1kXGxxRs6Rkhevm9NSY6TaJUsOmF3UqdHUo=NRg9kQKtSBA@mail.gmail.com/
        - https://news.ycombinator.com/item?id=47956312
        :::
      '' iwdEnabled
      // {
        # Make it clear in the documentation that this option is enabled if `networking.wireless.iwd.enable` is enabled.
        defaultText = l.literalExpression "networking.wireless.iwd.enable";
      };
  };

  config = {
    nix-mineral.settings.kernel.modules = l.mkIf (!cfg) {
      af_alg = l.mkDefault false;
      algif_hash = l.mkDefault false;
      algif_skcipher = l.mkDefault false;
      algif_rng = l.mkDefault false;
      algif_aead = l.mkDefault false;
    };
  };
}
