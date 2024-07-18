({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.security.hardened-malloc.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Use hardened-malloc as the default memory allocator for all running
    processes.
    '';
  };

  config = mkIf config.nm-overrides.security.hardened-malloc.enable {
    environment.memoryAllocator = { provider = "graphene-hardened"; };
  };
})