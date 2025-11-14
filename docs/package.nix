# The code in this file is VERY based on the way the `hjem` and `hjem-rum` projects create their documentation
# (sometimes even shamelessly copied and pasted).
# https://github.com/feel-co/hjem
# https://github.com/snugnug/hjem-rum

{
  inputs,
  pkgs,
}:

let
  inherit (inputs.nixpkgs) lib;

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
                if builtins.isAttrs value then
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

                fileLocation =
                  if (builtins.length splitedLocation == 1) then
                    builtins.elemAt splitedLocation 0
                  else if (builtins.length splitedLocation == 2) then
                    if (builtins.elemAt splitedLocation 1 == "preset") then
                      "presets/default"
                    else
                      builtins.elemAt splitedLocation 0
                  else
                    let
                      parts = "${builtins.elemAt splitedLocation 1}/${builtins.elemAt splitedLocation 2}";
                    in
                    (
                      if (builtins.length splitedLocation == 3) then
                        if (builtins.elemAt splitedLocation 1 == "filesystems") then parts else "${parts}/default"
                      else
                        "${parts}/${builtins.elemAt splitedLocation 3}"
                    );
              in
              {
                url = "https://github.com/cynicsketch/nix-mineral/blob/seikm-refactor/${fileLocation}.nix";
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
pkgs.runCommandNoCC "nix-mineral-docs" # based on: https://github.com/feel-co/hjem/blob/6e144632e3d8cfa7d7cfcc9504e10a032837f22a/docs/package.nix#L116
  {
    nativeBuildInputs = [ inputs.ndg.packages.${pkgs.hostPlatform.system}.ndg ];
  }
  ''
    mkdir -p $out/share/doc

    # Copy the markdown sources to be processed by ndg
    cp -rf ${./.} ./inputs

    ndg html \
      --jobs $NIX_BUILD_CORES \
      --title "nix-mineral" \
      --module-options ${configJSON}/share/doc/nixos/options.json \
      --options-depth 3 \
      --generate-search \
      --highlight-code \
      --input-dir ./inputs \
      --output-dir "$out/share/doc"

    mkdir -p $out/bin

    cp ${pkgs.writeShellScript "nix-mineral-docs" ''
      cp -r outfile/share/doc ./nix-mineral-docs
      chown -R $(whoami) ./nix-mineral-docs
      chmod -R u+w ./nix-mineral-docs
    ''} $out/bin/nix-mineral-docs

    substituteInPlace $out/bin/nix-mineral-docs --replace-fail "outfile" "$out"
  ''
