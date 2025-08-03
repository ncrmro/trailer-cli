# NixOS Package Documentation

This document provides detailed information about installing and using trailer-cli on NixOS and other systems with the Nix package manager.

## Installation Methods

### Using Flakes (Recommended)

If you have Nix flakes enabled, you can install trailer-cli in several ways:

#### Install to your profile
```bash
nix profile install github:ncrmro/trailer-cli
```

#### Run directly without installing
```bash
nix run github:ncrmro/trailer-cli
```

#### Add to your NixOS configuration
Add to your `configuration.nix`:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    trailer-cli.url = "github:ncrmro/trailer-cli";
  };

  outputs = { self, nixpkgs, trailer-cli }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [ trailer-cli.packages.x86_64-linux.default ];
        }
      ];
    };
  };
}
```

#### Add to Home Manager
In your `home.nix`:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    trailer-cli.url = "github:ncrmro/trailer-cli";
  };

  outputs = { nixpkgs, home-manager, trailer-cli, ... }: {
    homeConfigurations.yourusername = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        {
          home.packages = [ trailer-cli.packages.x86_64-linux.default ];
        }
      ];
    };
  };
}
```

### Traditional Nix (without flakes)

#### Install using nix-env
```bash
nix-env -i -f https://github.com/ncrmro/trailer-cli/archive/main.tar.gz
```

#### Build from source
```bash
git clone https://github.com/ncrmro/trailer-cli.git
cd trailer-cli
nix-build
./result/bin/trailer
```

## Development Environment

### Using Flakes
```bash
git clone https://github.com/ncrmro/trailer-cli.git
cd trailer-cli
nix develop
```

### Using shell.nix
```bash
git clone https://github.com/ncrmro/trailer-cli.git
cd trailer-cli
nix-shell
```

### Using direnv (automatic)
If you have direnv installed:
```bash
git clone https://github.com/ncrmro/trailer-cli.git
cd trailer-cli
direnv allow
```

The development environment includes:
- Swift compiler
- Swift Package Manager
- Foundation frameworks
- Required system dependencies

## Building the Package

The Nix package is configured to:
- Use Swift Package Manager to resolve and build dependencies
- Apply appropriate compiler optimizations
- Handle platform-specific dependencies (Linux vs macOS)
- Install the binary to the correct location

## Requirements

- Nix package manager
- For flakes: Nix with flakes enabled (`experimental-features = nix-command flakes`)
- Swift 6.0+ (provided by Nix)

## Supported Platforms

- x86_64-linux
- aarch64-linux  
- x86_64-darwin
- aarch64-darwin

## Troubleshooting

### Flakes not working
Ensure flakes are enabled in your Nix configuration:
```bash
# Add to ~/.config/nix/nix.conf or /etc/nix/nix.conf
experimental-features = nix-command flakes
```

### Build failures
If you encounter build issues, try:
```bash
nix build --no-sandbox --impure
```

### Swift dependency issues
The package is configured to disable sandbox and prefetching for Swift Package Manager, which should resolve most dependency-related build issues.

## Contributing

When making changes to the Nix packaging:
1. Test both flake and non-flake builds
2. Ensure cross-platform compatibility 
3. Update documentation as needed
4. Test in clean environments

## Support

For Nix-specific issues, please check:
1. This documentation
2. The project's GitHub issues
3. NixOS Discourse for general Nix questions