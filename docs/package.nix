# This file Includes code from https://github.com/feel-co/hjem, licensed under the MPL-2.0.
#
# This file Includes code from https://github.com/snugnug/hjem-rum, licensed under the GPL-3.0.
#
# See:
# <licenses/HJEM.mpl20> or https://github.com/feel-co/hjem/blob/main/LICENSE
# <LICENSE> or https://github.com/snugnug/hjem-rum/blob/main/LICENSE
#
# The code in this file is based on the way the `hjem` and `hjem-rum` projects create their documentation

{
  inputs,
  pkgs,
}:

let
  inherit (inputs.nixpkgs) lib;

  # Configuration reference:
  # https://github.com/feel-co/ndg/blob/a6bd3c1ce2668d096e4fdaaa03ad7f03ba1fbca8/ndg/README.md#configuration-reference
  ndgConfig = {
    title = "nix-mineral";
    highlight_code = true;
    generate_anchors = true;

    search = {
      enable = true;
      max_heading_level = 3;
    };

    tab_style = "normalize"; # converts tabs to spaces

    meta_tags = {
      description = "nix-mineral automatic option documentation";
      keywords = "documentation,nix,tutorial,nix-mineral";
      author = "cynicsketch";
    };
  };

  # Based on:
  # https://github.com/feel-co/hjem/blob/8539013044624a257e8da370069107aea148e985/docs/package.nix#L24
  # https://github.com/snugnug/hjem-rum/blob/edac54b7d57ad72cc4b124da2f44e7b2e584f3c6/docs/package.nix#L17
  evalModules = (
    lib.evalModules {
      modules = [
        inputs.self.nixosModules.nix-mineral

        (
          let
            # From nixpkgs:
            #
            # Recursively replace each derivation in the given attribute set
            # with the same derivation but with the `outPath` attribute set to
            # the string `"\${pkgs.attribute.path}"`. This allows the
            # documentation to refer to derivations through their values without
            # establishing an actual dependency on the derivation output.
            #
            # This is not perfect, but it seems to cover a vast majority of use cases.
            #
            # Caveat: even if the package is reached by a different means, the
            # path above will be shown and not e.g.
            # `${config.services.foo.package}`.
            scrubDerivations =
              namePrefix: pkgSet:
              lib.mapAttrs (
                name: value:
                let
                  wholeName = "${namePrefix}.${name}";
                in
                if lib.isAttrs value then
                  scrubDerivations wholeName value
                  // lib.optionalAttrs (lib.isDerivation value) {
                    inherit (value) drvPath;
                    outPath = "\${${wholeName}}";
                  }
                else
                  value
              ) pkgSet;
          in
          {
            _module = {
              check = false;
              args.pkgs = lib.mkForce (scrubDerivations "pkgs" pkgs);
            };
          }
        )
        # avoid having `_module.args` in the documentation
        {
          options = {
            _module.args = lib.mkOption {
              internal = true;
            };
          };
        }
      ];
    }
  );

  configJSON =
    (pkgs.nixosOptionsDoc {
      inherit (evalModules) options;

      variablelistId = "nix-mineral-options";
      warningsAreErrors = true;

      # Based on: https://github.com/feel-co/hjem/blob/8539013044624a257e8da370069107aea148e985/docs/package.nix#L89
      transformOptions =
        opt:
        opt
        // {
          declarations = map (
            decl:
            if lib.hasPrefix (toString ../.) (toString decl) then
              let
                splitedLocation = lib.splitString "." (
                  lib.head (
                    lib.splitString ".<" (
                      if lib.hasSuffix ".enable" opt.name then lib.removeSuffix ".enable" opt.name else opt.name
                    )
                  )
                );

                # nix-mineral repository structure is quite different from a standard module,
                # so this function transforms the options into valid paths in the nix-mineral repository.
                fileLocation =
                  if (lib.length splitedLocation == 1) then
                    lib.elemAt splitedLocation 0
                  else if (lib.length splitedLocation == 2) then
                    if (lib.elemAt splitedLocation 1 == "preset") then
                      "presets/default"
                    else
                      lib.elemAt splitedLocation 0
                  else
                    let
                      parts = "${lib.elemAt splitedLocation 1}/${lib.elemAt splitedLocation 2}";
                    in
                    (
                      if (lib.length splitedLocation == 3) then
                        if (lib.elemAt splitedLocation 1 == "filesystems") then parts else "${parts}/default"
                      else
                        "${parts}/${lib.elemAt splitedLocation 3}"
                    );
              in
              {
                url = "https://github.com/cynicsketch/nix-mineral/blob/main/${fileLocation}.nix";
                name = "<nix-mineral/${fileLocation}.nix>";
              }
            else if decl == "lib/modules.nix" then
              {
                url = "https://github.com/NixOS/nixpkgs/blob/master/${decl}";
                name = "<nixpkgs/${decl}>";
              }
            else
              decl
          ) opt.declarations;
        };
    }).optionsJSON;
in
rec {
  docs =
    # based on: https://github.com/feel-co/hjem/blob/6e144632e3d8cfa7d7cfcc9504e10a032837f22a/docs/package.nix#L116
    # default configuration from: https://github.com/feel-co/ndg/blob/a6bd3c1ce2668d096e4fdaaa03ad7f03ba1fbca8/ndg/README.md?plain=1#L309
    pkgs.runCommand "nix-mineral-docs"
      {
        nativeBuildInputs = [ inputs.ndg.packages.${pkgs.hostPlatform.system}.ndg ];
      }
      ''
        mkdir -p $out/share/doc

        # Copy the markdown sources to be processed by ndg
        cp -rf ${./.} ./inputs
        chmod -R u+w ./inputs
        cp -f ${../README.md} ./inputs/index.md

        # Create NDG toml config file
        cp ${pkgs.writers.writeTOML "ndg-config.toml" ndgConfig} $out/share/doc/ndg-config.toml

        ndg --config-file $out/share/doc/ndg-config.toml \
          --config input_dir=./inputs \
          --config output_dir=$out/share/doc \
          --config jobs=$NIX_BUILD_CORES \
          html --module-options ${configJSON}/share/doc/nixos/options.json
      '';

  html =
    pkgs.runCommand "nix-mineral-docs-html"
      {
        nativeBuildInputs = [ docs ];
      }
      ''
        mkdir -p $out/bin

        cp ${pkgs.writeShellScript "nix-mineral-docs-html" ''
          cp -r ${docs}/share/doc ./nix-mineral-docs
          chown -R $(whoami) ./nix-mineral-docs
          chmod -R u+w ./nix-mineral-docs
        ''} $out/bin/nix-mineral-docs-html
      '';

  server =
    pkgs.runCommand "nix-mineral-docs-server"
      {
        nativeBuildInputs = [
          docs
          pkgs.http-server
        ];
      }
      ''
        mkdir -p $out/bin

        cp ${pkgs.writeShellScript "nix-mineral-docs-server" ''
          exec ${lib.getExe pkgs.http-server} ${docs}/share/doc
        ''} $out/bin/nix-mineral-docs-server
      '';
}
