{
  l,
  cfg,
  ...
}:

{
  options = {
    load-kernel-modules = l.mkBoolOption ''
      Allow loading of kernel modules not only at boot via kernel commandline.
      if false, very likely to cause breakage unless you can compile a list of every module
      you need and add that to your boot parameters manually.
    '' true;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl."kernel.modules_disabled" = l.mkForce "1";
  };
}
