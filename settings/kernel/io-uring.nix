{
  l,
  cfg,
  ...
}:

{
  options = {
    io-uring = l.mkBoolOption ''
      Enable io_uring, is the cause of many vulnerabilities,
      and is disabled on Android + ChromeOS.
      This may be desired for specific environments concerning Proxmox.
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      "kernel.io_uring_disabled" = l.mkDefault "2";
    };
  };
}
