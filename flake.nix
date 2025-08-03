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
          ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            git  # Required for SPM to fetch dependencies
          ];

          buildInputs = with pkgs; lib.optionals stdenv.isLinux [
            openssl
            zlib
            curl
            libxml2
          ] ++ lib.optionals stdenv.isDarwin [
            darwin.apple_sdk.frameworks.Foundation
            darwin.apple_sdk.frameworks.Security
            darwin.apple_sdk.frameworks.CoreFoundation
          ];

          # Prevent Swift Package Manager from trying to access network during build
          configurePhase = ''
            runHook preConfigure
            
            export SWIFTPM_FLAGS_OVERRIDE="--disable-sandbox --disable-prefetching"
            export HOME=$TMPDIR
            
            # Pre-resolve dependencies if Package.resolved exists
            if [ -f Package.resolved ]; then
              echo "Using existing Package.resolved"
            fi
            
            runHook postConfigure
          '';

          buildPhase = ''
            runHook preBuild
            
            echo "Building trailer-cli with Swift Package Manager..."
            swift build -c release \
              --disable-sandbox \
              --disable-prefetching \
              --skip-update \
              -Xswiftc -O \
              -Xswiftc -whole-module-optimization \
              -Xswiftc -enforce-exclusivity=unchecked
              
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            
            mkdir -p $out/bin
            install -m755 $(swift build -c release --show-bin-path)/trailer $out/bin/
            
            runHook postInstall
          '';

          # Swift Package Manager requires network access to fetch dependencies
          # In Nix, we typically handle this differently, but for now we'll allow it
          __impure = true;

          meta = with pkgs.lib; {
            description = "A command-line version of Trailer for managing GitHub PRs and Issues";
            longDescription = ''
              A version of Trailer that runs on the macOS & Linux command-line, can integrate 
              into scripts, be used on remote servers, or simply used because consoles are cool. 
              This version does not aim for feature parity with the mainstream Trailer project 
              although it shares common ideas and concepts.
              
              Features:
              - GitHub PR and Issue management from the command line
              - GraphQL API v4 for fast syncs
              - JSON data storage for integration with other tools
              - Support for GitHub Enterprise servers
              - Filtering, sorting, and search capabilities
              - Full detail view of PRs/Issues including comments and reviews
            '';
            homepage = "https://github.com/ncrmro/trailer-cli";
            changelog = "https://github.com/ncrmro/trailer-cli/releases";
            license = licenses.mit;
            maintainers = with maintainers; [ ];
            platforms = platforms.unix;
            mainProgram = "trailer";
            broken = false;
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
            git
          ] ++ lib.optionals stdenv.isLinux [
            openssl
            zlib
            curl
            libxml2
          ] ++ lib.optionals stdenv.isDarwin [
            darwin.apple_sdk.frameworks.Foundation
            darwin.apple_sdk.frameworks.Security
            darwin.apple_sdk.frameworks.CoreFoundation
          ];

          shellHook = ''
            echo "🚀 trailer-cli development environment"
            echo ""
            echo "Available commands:"
            echo "  swift build           - Build the project"
            echo "  swift run trailer     - Run the CLI tool"
            echo "  swift test            - Run tests (if any)"
            echo "  swift package reset   - Clean build artifacts"
            echo "  swift package resolve - Resolve dependencies"
            echo ""
            echo "Swift version: $(swift --version | head -n1)"
            echo "Build path: $(swift build --show-bin-path 2>/dev/null || echo 'Run swift build first')"
          '';
        };
      }
    );
}