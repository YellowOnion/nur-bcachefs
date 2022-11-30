#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-git
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

nix-prefetch-git --rev refs/heads/nix-flake-cleanup https://github.com/YellowOnion/bcachefs-tools.git > woob-tools-version.json
