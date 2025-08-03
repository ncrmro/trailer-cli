# shell.nix - Development shell
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
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
    echo ""
    echo "Available commands:"
    echo "  swift build           - Build the project"
    echo "  swift run trailer     - Run the CLI tool"
    echo "  swift test            - Run tests (if any)"
    echo "  swift package reset   - Clean build artifacts"
  '';
}