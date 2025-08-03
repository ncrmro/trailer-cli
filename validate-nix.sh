#!/usr/bin/env bash

# validate-nix.sh - Validation script for Nix packaging
# This script performs basic validation of the Nix files

set -euo pipefail

echo "🔍 Validating NixOS package files..."

# Check if required files exist
required_files=("flake.nix" "default.nix" "shell.nix" ".envrc")
for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "❌ Missing required file: $file"
        exit 1
    else
        echo "✅ Found: $file"
    fi
done

# Check flake.nix structure
echo ""
echo "🔍 Checking flake.nix structure..."

required_sections=("description" "inputs" "outputs" "nixpkgs.url" "flake-utils.url")
for section in "${required_sections[@]}"; do
    if grep -q "$section" flake.nix; then
        echo "✅ Found required section: $section"
    else
        echo "❌ Missing required section: $section"
        exit 1
    fi
done

# Check for proper Swift package attributes
echo ""
echo "🔍 Checking Swift package attributes..."

swift_attributes=("swift" "swiftPackages.swiftpm" "swift build" "mainProgram.*trailer")
for attr in "${swift_attributes[@]}"; do
    if grep -q "$attr" flake.nix; then
        echo "✅ Found Swift attribute: $attr"
    else
        echo "❌ Missing Swift attribute: $attr"
        exit 1
    fi
done

# Check that both default.nix and flake.nix define the same package
echo ""
echo "🔍 Checking consistency between default.nix and flake.nix..."

if grep -q "trailer-cli" default.nix && grep -q "trailer-cli" flake.nix; then
    echo "✅ Package name consistent"
else
    echo "❌ Package name inconsistent"
    exit 1
fi

# Check documentation
echo ""
echo "🔍 Checking documentation..."

if [[ -f "NIX.md" ]] && [[ -f "README.md" ]]; then
    if grep -q "NixOS" README.md && grep -q "nix profile install" README.md; then
        echo "✅ NixOS installation documented in README.md"
    else
        echo "❌ NixOS installation not properly documented in README.md"
        exit 1
    fi
    
    if grep -q "Installation Methods" NIX.md; then
        echo "✅ Detailed documentation found in NIX.md"
    else
        echo "❌ Detailed documentation missing in NIX.md"
        exit 1
    fi
else
    echo "❌ Missing documentation files"
    exit 1
fi

# Check .gitignore
echo ""
echo "🔍 Checking .gitignore..."

gitignore_entries=("result" ".direnv")
for entry in "${gitignore_entries[@]}"; do
    if grep -q "$entry" .gitignore; then
        echo "✅ .gitignore contains: $entry"
    else
        echo "❌ .gitignore missing: $entry"
        exit 1
    fi
done

echo ""
echo "🎉 All validation checks passed!"
echo ""
echo "📦 Your NixOS package is ready!"
echo ""
echo "Next steps:"
echo "  • Test with 'nix build' (requires Nix with flakes enabled)"
echo "  • Test with 'nix-shell' for development"
echo "  • Submit to nixpkgs if desired"
echo ""