{
  l,
  cfg,
  ...
}:

{
  options = {
    multilib = l.mkBoolOption ''
      Enable multilib support, allowing 32-bit libraries and applications to run.
      if false, this may cause issues with certain games that still require 32-bit libraries.
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernelParams = [
      "ia32_emulation=0"
    ];
  };
}
