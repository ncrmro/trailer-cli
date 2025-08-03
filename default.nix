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
}