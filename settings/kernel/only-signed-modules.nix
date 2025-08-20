{
  options,
  l,
  cfg,
  ...
}:

{
  options = {
    only-signed-modules = l.mkBoolOption ''
      Requires all kernel modules to be signed. This prevents out-of-tree
      kernel modules from working unless signed.

      (if false, `${options.nix-mineral.settings.kernel.lockdown}` must also be false)
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernelParams = [
      "module.sig_enforce=1"
    ];
  };
}
