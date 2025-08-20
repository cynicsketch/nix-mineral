{
  l,
  cfg,
  ...
}:

{
  options = {
    hardened-malloc = l.mkBoolOption ''
      DO NOT USE THIS OPTION ON ANY PRODUCTION SYSTEM! FOR TESTING PURPOSES ONLY!
      Use hardened-malloc as default memory allocator for all processes.
    '' false;
  };

  config = l.mkIf cfg {
    environment.memoryAllocator.provider = "graphene-hardened";
  };
}
