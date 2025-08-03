# shell.nix - Development shell
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
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
}