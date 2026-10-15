# Neovim

Requires Neovim 0.12 or newer for native automatic completion and completion
popup options. Plugin versions are tracked in `.config/nvim/lazy-lock.json`;
use `:Lazy restore` to install those versions on another machine.

Completion uses Neovim's built-in LSP and snippet support. Picker prompts are
excluded from automatic completion so typing filters the picker results.

Ada Language Server loads `.als.json` from the detected project root and
discovers a single `.gpr` file there. For projects with no `.als.json` or root
`.gpr` files, the config also supports a single `gnat/*.gpr` file. If there are
multiple project files, select one with `projectFile` in `.als.json`.
