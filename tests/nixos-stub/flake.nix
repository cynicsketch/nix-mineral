{
  description = "Test NixOS flake for using nix-mineral";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-mineral.url = "path:../../";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      nixosConfigurations.test-system = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs;
        };

        modules = [
          {
            imports = [
              inputs.nix-mineral.nixosModules.nix-mineral
            ];

            nix-mineral = {
              enable = true;
            };

            # Everything below is required to make this configuration "bootable" and
            # evaluate properly.
            #
            # Do not remove anything unless there is a good reason.

            boot.loader.systemd-boot.enable = true;

            # Stub filesystems
            fileSystems."/" = {
              device = "/dev/disk/by-uuid/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee";
              fsType = "ext4";
            };
            fileSystems."/boot" = {
              device = "/dev/disk/by-uuid/ABCD-EFGH";
              fsType = "vfat";
            };
          }
        ];
      };
    };
}
