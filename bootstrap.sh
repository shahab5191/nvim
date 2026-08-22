#!/usr/bin/env bash
# Per-machine setup after cloning this repo to ~/.config/nvim.
# Idempotent: safe to re-run.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.local/bin"
ln -sfn "$repo/bin/godot-nvim-open" "$HOME/.local/bin/godot-nvim-open"
echo "linked ~/.local/bin/godot-nvim-open -> $repo/bin/godot-nvim-open"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) echo "warning: ~/.local/bin is not on \$PATH" >&2 ;;
esac

echo
echo "Next: launch nvim once to let lazy.nvim install plugins and treesitter parsers."
echo
echo "For Godot, set these once in the editor GUI"
echo "(Editor > Editor Settings > Text Editor > External) -- they live in Godot's"
echo "per-machine editor settings, not in this repo:"
echo "  Use External Editor : on"
echo "  Exec Path           : $HOME/.local/bin/godot-nvim-open"
echo "  Exec Flags          : {project} {file} {line} {col}"
echo
echo "If the Godot binary is not on \$PATH and not under ~/Programs/Godot,"
echo "export GODOT=/path/to/godot in your shell profile."
