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
      packages = forAllSystems ({ pkgs, ... }: {
        default = pkgs.terraform;
      });

      formatter = forAllSystems ({ pkgs }: pkgs.nixfmt);

      devShells = forAllSystems ({ pkgs }: pkgs.mkShell {
        name = "terraform-shell";  
        nativeBuildInputs = [ pkgs.jq pkgs.terraform pkgs.ssm-session-manager-plugin pkgs.cowsay ];
        LANG = "C";
        NIXPKGS_ALLOW_UNFREE = 1;
        shellHook = ''
          cowsay "Welcome to My Dev Shell"
        '';
      });
    };
}

