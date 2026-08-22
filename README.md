# nvim

Single-file Neovim config (kickstart-derived), managed with
[lazy.nvim](https://github.com/folke/lazy.nvim). Requires Neovim 0.11+
(developed on 0.12).

## Install on a new machine

```sh
git clone https://github.com/shahab5191/nvim ~/.config/nvim
~/.config/nvim/bootstrap.sh
nvim                # lazy.nvim installs plugins; treesitter compiles parsers
```

`lazy-lock.json` is committed, so every machine gets the same plugin revisions.
Run `:Lazy update` to move forward, then commit the updated lockfile.

## Layout

| Path                   | Purpose                                              |
| ---------------------- | ---------------------------------------------------- |
| `init.lua`             | Everything: options, plugin specs, LSP, DAP, keymaps  |
| `lazy-lock.json`       | Pinned plugin revisions                              |
| `bin/godot-nvim-open`  | Godot "external editor" → running nvim bridge        |
| `bootstrap.sh`         | Per-machine symlinks + setup reminders                |

## Machine-specific bits

Deliberately kept out of the repo, or resolved at runtime:

- **Godot binary** — resolved in this order: `$GODOT`, then `godot`/`godot4`/`Godot`
  on `$PATH`, then the highest-versioned `~/Programs/Godot/Godot_v*`. Export
  `$GODOT` if yours lives elsewhere.
- **Python debugger interpreter** — `$VIRTUAL_ENV`, then `./.venv`, then
  `python3`.
- **Godot editor settings** — stored in `~/.config/godot/`, per machine. See below.

## Godot / GDScript

`<leader>G*` keymaps: `Ge` open editor, `Gr` run project, `Gs` run current scene,
`Gl` restart the GDScript LSP.

Three things to know, because Godot is unusual here:

1. **Godot *is* the language server.** There is no separate binary to install —
   the editor serves LSP on `127.0.0.1:6005`, and only while it is open on the
   project. So the config attaches on a `project.godot` root marker only (no
   `.git` fallback), and is set up outside the Mason-driven `servers` table,
   since Mason has no `gdscript` package. If completion is dead, the editor is
   probably closed: open it and hit `<leader>Gl`.

2. **The DAP port is 6006.** Not 6007 — that is
   `network/debug/remote_port`, the game→editor channel. Verify with
   `ss -ltnp | grep -i godot` while the editor runs; you should see 6005 and 6006.

3. **Jump-to-script needs a socket.** Godot's "external editor" launches a
   command instead of talking to a running nvim, so the config starts a listener
   at `<project>/server.pipe` on entering a Godot project, and
   `bin/godot-nvim-open` forwards jumps to it (falling back to a new terminal if
   nothing is listening).

   Godot's `{line}` base has shifted between versions, so the script has a
   `LINE_OFFSET` (default `1`, i.e. treat Godot's value as 0-based) and writes
   the raw arguments it received to `~/.local/state/godot-nvim-open.log`. If a
   jump lands one line off, compare that log against where you clicked and set
   `LINE_OFFSET=0`.

   Add `server.pipe` to each Godot project's `.gitignore`.

   Set these once per machine — Godot rewrites its settings file on exit, so use
   the GUI rather than editing the file (Editor → Editor Settings → Text Editor
   → External):

   | Setting             | Value                                  |
   | ------------------- | -------------------------------------- |
   | Use External Editor | on                                     |
   | Exec Path           | `$HOME/.local/bin/godot-nvim-open`     |
   | Exec Flags          | `{project} {file} {line} {col}`        |

## Gotchas

- The nvim-dap setup (adapters and configurations, including Godot's) lives
  inside the **fzf-lua** spec's `config` function, which loads on `VimEnter`.
  `require("dap").adapters` is therefore empty until then — surprising when
  probing from `nvim --headless -c ...`, which runs before `VimEnter`.
- Treesitter parser names and filetypes differ for Godot resources: parser
  `godot_resource`, filetype `gdresource`. The `FileType` autocmd uses a separate
  list (`highlight_fts`) for this reason.
