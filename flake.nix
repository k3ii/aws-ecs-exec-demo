{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs, flake-utils }:
    let
      allSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      forAllSystems = fn:
        nixpkgs.lib.genAttrs allSystems (system:
          fn {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          });

    in {
      formatter = forAllSystems ({ pkgs }: pkgs.nixfmt);
      devShells = forAllSystems ({ pkgs }: {
        blue = pkgs.mkShell {
          name = "aws-tf";
          nativeBuildInputs = [ pkgs.jq pkgs.terraform ];
          LANG = "C";
          AWESOME_TEAM = "blue";
          NIXPKGS_ALLOW_UNFREE = 1;
          shellHook = ''
            echo "blue shell!"
            cowsay "team $AWESOME_TEAM rocks!"
          '';
        };
      });
    };
}

