{
  config,
  l,
}:

{
  algif-related = {
    # Only enable if `networking.wireless.iwd.enable` exists (avoid failing tests) and is enabled, since iwd uses AF_ALG.
    default = !config.networking.wireless.iwd.enable;
    # Make it clear in the documentation that this option is enabled if `networking.wireless.iwd.enable` is disabled.
    defaultText = l.literalExpression "!networking.wireless.iwd.enable";
    description = ''
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
    '';
    modules = [
      "af_alg"
      "algif_hash"
      "algif_skcipher"
      "algif_rng"
      "algif_aead"
    ];
  };

  intelme-related = {
    description = ''
      Intel ME related kernel modules.

      Disable this to avoid putting trust in the highly privilege ME system,
      but there are potentially other consequences.

      ::: {.tip}
      If you use an AMD system, you can disable this without negative consequence
      and reduce attack surface.
      :::

      ::: {.note}
      Intel users should read more about the issue at the below links:
      - https://www.kernel.org/doc/html/latest/driver-api/mei/mei.html
      - https://en.wikipedia.org/wiki/Intel_Management_Engine#Security_vulnerabilities
      - https://www.kicksecure.com/wiki/Out-of-band_Management_Technology#Intel_ME_Disabling_Disadvantages
      - https://github.com/Kicksecure/security-misc/pull/236#issuecomment-2229092813
      - https://github.com/Kicksecure/security-misc/issues/239
      :::
    '';
    modules = [
      "mei"
      "mei-gsc"
      "mei_gsc_proxy"
      "mei_hdcp"
      "mei-me"
      "mei_phy"
      "mei_pxp"
      "mei-txe"
      "mei-vsc"
      "mei-vsc-hw"
      "mei_wdt"
      "microread_mei"
    ];
  };

  bluetooth-related = {
    modules = [
      "bluetooth"
      "bluetooth_6lowpan"
      "bt3c_cs"
      "btbcm"
      "btintel"
      "btmrvl"
      "btmrvl_sdio"
      "btmtk"
      "btmtksdio"
      "btmtkuart"
      "btnxpuart"
      "btqca"
      "btrsi"
      "btrtl"
      "btsdio"
      "btusb"
      "virtio_bt"
    ];
  };
}
