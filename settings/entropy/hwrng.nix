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
    hwrng = l.mkBoolOption ''
      Disable "trusting" both the CPU's hardware random number generator and any
      entropy seed passed to the bootloader.

      We assume the hardware random number generation could be flawed or buggy,
      but that the firmware is not actively malicious, since that is outside
      scope and you'd have bigger problems at that point.

      ::: {.note}
      Setting to false may slow down boot times because boot will not proceed
      until adequate entropy has been acquired, and the process cannot be
      expedited by the CPU directly.

      See:
      - https://github.com/secureblue/secureblue/issues/173
      - https://gitlab.alpinelinux.org/alpine/aports/-/work_items/9960
      :::

      ::: {.note}
      The use of RDRAND is *not disabled* by setting this option to false.

      Trust, in this context, refers to whether a source is credited as being
      completely reliable *by itself*.

      RDRAND is still used to supplement `/dev/random` but refusing to credit it
      means that it cannot unblock the use of `/dev/random` when used alone.

      This means that we do not allow RDRAND to be the only entropy source (which
      would only be the case in very early boot) before allowing cryptographic
      operations to occur.

      Injecting even very bad entropy sources into an otherwise good pool isn't
      supposed to be harmful, given that entropy mixing works as expected and
      there is at least one other "good" source available. There's a reason why
      `/dev/random` is read-write to world.

      See:
      - https://privsec.dev/posts/linux/desktop-linux-hardening/#entropy-generation
      - https://madaidans-insecurities.github.io/guides/linux-hardening.html#rdrand
      - https://github.com/NixOS/nixpkgs/pull/165355
      - https://github.com/QubesOS/qubes-issues/issues/6941
      - https://cateee.net/lkddb/web-lkddb/RANDOM_TRUST_CPU.html
      - https://arxiv.org/abs/2312.03369
      :::
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernelParams = [
      "random.trust_cpu=off"
      "random.trust_bootloader=off"
    ];
  };
}
