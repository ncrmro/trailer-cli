{
  description = "Command-line Trailer - A GitHub PR/Issue management tool for the command line";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "trailer-cli";
          version = "1.0.0";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            swift
            swiftPackages.swiftpm
            swiftPackages.Foundation
            pkg-config
          ];

          buildInputs = with pkgs; lib.optionals stdenv.isLinux [
            glibc
            openssl
            zlib
          ] ++ lib.optionals stdenv.isDarwin [
            darwin.apple_sdk.frameworks.Foundation
            darwin.apple_sdk.frameworks.Security
          ];

          configurePhase = ''
            export SWIFTPM_FLAGS_OVERRIDE="--disable-sandbox --disable-prefetching"
          '';

          buildPhase = ''
            swift build -c release \
              --disable-sandbox \
              --disable-prefetching \
              -Xswiftc -O \
              -Xswiftc -whole-module-optimization
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp $(swift build -c release --show-bin-path)/trailer $out/bin/
          '';

          meta = with pkgs.lib; {
            description = "A command-line version of Trailer for managing GitHub PRs and Issues";
            longDescription = ''
              A version of Trailer that runs on the macOS & Linux command-line, can integrate 
              into scripts, be used on remote servers, or simply used because consoles are cool. 
              This version does not aim for feature parity with the mainstream Trailer project 
              although it shares common ideas and concepts.
            '';
            homepage = "https://github.com/ncrmro/trailer-cli";
            license = licenses.mit;
            maintainers = [ ];
            platforms = platforms.unix;
            mainProgram = "trailer";
          };
        };

        packages.trailer-cli = self.packages.${system}.default;

        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            swift
            swiftPackages.swiftpm
            swiftPackages.Foundation
            pkg-config
          ];

          shellHook = ''
            echo "trailer-cli development environment"
            echo "Run 'swift build' to build the project"
            echo "Run 'swift run trailer' to run the CLI tool"
          '';
        };
      }
    );
}