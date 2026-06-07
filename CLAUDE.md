# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim configuration, forked from `dam9000/kickstart-modular.nvim`. There is no build/test step — changes take effect when Neovim is restarted. Use `:Lazy` to inspect plugin state and `:Lazy sync` after editing plugin specs. Run `:checkhealth` for diagnostics.

## Formatting

Lua files are formatted with `stylua` (config in `.stylua.toml`: 160 col width, 2-space indent, single quotes, no call parens). Format-on-save runs `stylua` for Lua via conform.nvim; the format command is `<leader>f`.

## Architecture

Entry point is `init.lua`, which sequentially loads:

1. `lua/options.lua` — vim options
2. `lua/keymaps.lua` — keymaps and autocmds (leader is `<space>`)
3. `lua/lazy-bootstrap.lua` — installs lazy.nvim if missing
4. `lua/lazy-plugins.lua` — **the central plugin manifest**. Each kickstart plugin is `require`d explicitly; user plugins are pulled in two ways: via the `require 'custom/plugins'` line (loads `lua/custom/plugins/init.lua`) and the `{ import = 'custom.plugins' }` directive (auto-imports every other `lua/custom/plugins/*.lua`). When adding a new user plugin, drop a file in `lua/custom/plugins/` — do not touch `lazy-plugins.lua`.

`init.lua` also wires the user commands `:ShouldAttachTsLs`, `:DetachTsLs`, and `:CloseAllButCurrent` (their implementations live in `lua/custom/`).

### Plugin layout

- `lua/kickstart/plugins/` — upstream kickstart defaults. Generally leave these alone unless intentionally diverging from upstream.
- `lua/custom/plugins/` — user plugin specs. This is where new plugins go.
- `lua/custom/` (non-`plugins/`) — helper Lua modules consumed by plugin specs and `init.lua` (e.g. `env.lua`, `ts_attach_checker.lua`, `closeAllBuffButCurrent.lua`).

### LSP (`lua/kickstart/plugins/lspconfig.lua`)

Uses Neovim's **native LSP API** (Nvim 0.11+): each entry in the `servers` table is registered with `vim.lsp.config(name, server)` and turned on with `vim.lsp.enable(name)` (the loop at the bottom of the `config` function), while `mason-tool-installer` installs the tools from the same table's keys. Currently configured: `gopls`, `pyright`, `buf_ls` (proto), `rust_analyzer`, `biome`, `ts_ls`, `denols`, `lua_ls`. To add a server, add a new key to `servers` — it's installed, configured, and enabled automatically. Each server's `cmd`/`filetypes`/`root_dir` defaults come from nvim-lspconfig's shipped `lsp/<name>.lua` and are merged with your overrides; completion `capabilities` are advertised globally via `vim.lsp.config('*', …)` (blink.cmp). Note there is **no** `mason-lspconfig` `handlers` block and no `require('lspconfig')[name].setup()` — those are the removed/deprecated patterns. Buffer-local keymaps plus document-highlight, inlay-hint, and document-color (native `vim.lsp.document_color`, `'■'` virtual-text swatch) are wired in the `LspAttach` autocmd. `:LspInfo` is re-aliased to `:checkhealth vim.lsp` since Nvim 0.12 stops nvim-lspconfig from defining it.

`ts_ls` and `denols` deliberately do not coexist, and this is now done with **native `root_dir` callbacks** (signature `function(bufnr, on_dir)`), not the old `on_new_config` hook: `ts_ls`'s `root_dir` calls `require('custom.ts_attach_checker').should_attach_ts_ls`, which walks from the buffer's directory up to the git root (detected via `.git/index`) looking for `deno.json[c]`; if found it returns *without* calling `on_dir`, so `ts_ls` never attaches and `denols` — whose own `root_dir` matches `deno.json[c]` — wins. The `:ShouldAttachTsLs` / `:DetachTsLs` helper commands (wired in `init.lua`) remain. Keep this dual-LSP arrangement in mind when touching either server's config.

### Formatter selection (`lua/kickstart/plugins/conform.lua`)

For `javascript`, `typescript`, and `svelte`, the formatter is chosen per-buffer: walk from the file to cwd looking for a prettier config (`.prettierrc*`, `prettier.config.js`). If found → `prettierd`/`prettier`; otherwise → `biome`. This is why `biome` and `prettier` can both be present without conflict, and it's why a project's formatter behavior depends on whether a prettier config exists *anywhere* between the file and cwd.

JS/TS/JSX/TSX files also get a `BufWritePre` autocmd that runs `conform.format { lsp_fallback = true }` in addition to conform's own `format_on_save`.

### Custom `.env` loader (`lua/custom/env.lua`)

`require('custom.env').get('KEY')` reads `<nvim config>/.env` (gitignored) first, falling back to the process environment. Used e.g. by `lua/custom/plugins/copilot.lua` to load `LITE_LLM_KEY` for the custom `openwebui` CopilotChat provider pointing at `litellm.kolchurin.dev`. Do not commit `.env` — `.gitignore` covers `.env*`.

## Conventions

- Single-quote strings in Lua (enforced by stylua).
- 2-space indent everywhere (Lua, and global vim defaults in `options.lua`).
- Leader is space; `jj` is the insert-mode escape.
- The kickstart files retain their verbose teaching comments — preserve them when editing kickstart plugin specs to keep diffs against upstream small. User code in `lua/custom/` does not need that style.
