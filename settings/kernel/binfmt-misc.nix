{
  l,
  cfg,
  ...
}:

{
  options = {
    binfmt-misc = l.mkBoolOption ''
      Enable binfmt_misc, (https://en.wikipedia.org/wiki/Binfmt_misc).
      if false, breaks Roseta, among other applications.
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      "fs.binfmt_misc.status" = l.mkDefault "0";
    };
  };
}
