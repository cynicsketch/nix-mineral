{
  options,
  l,
  cfg,
  ...
}:

{
  options = {
    lockdown = l.mkBoolOption ''
      Enable linux kernel lockdown, this blocks loading of unsigned kernel modules
      and breaks hibernation.

      (if false, you probably want to disable `${options.nix-mineral.settings.kernel.only-signed-modules}`)
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernelParams = [
      "lockdown=confidentiality"
    ];
  };
}
