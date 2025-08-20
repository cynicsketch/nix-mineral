{
  l,
  cfg,
  ...
}:

{
  options = {
    pti = l.mkBoolOption ''
      Enable Page Table Isolation (PTI) to mitigate some KASLR bypasses and
      the Meltdown CPU vulnerability. It may also tax performance.
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernelParams = [
      "pti=on"
    ];
  };
}
