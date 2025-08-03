# default.nix - For use without flakes
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
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

  configurePhase = ''
    runHook preConfigure
    
    export SWIFTPM_FLAGS_OVERRIDE="--disable-sandbox --disable-prefetching"
    export HOME=$TMPDIR
    
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    
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
}