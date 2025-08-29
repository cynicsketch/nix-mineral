{
  l,
  cfg,
  ...
}:

{
  options = {
    minimize-swapping = l.mkBoolOption ''
      Reduce swappiness to bare minimum. May reduce risk of writing sensitive
      information to disk, but hampers zram performance. Also useless if you do
      not even use a swap file/partition, i.e zram only setup.
    '' false;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl."vm.swappiness" = l.mkForce "1";
  };
}
