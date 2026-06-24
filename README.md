# tree-sitter-gsx

A [tree-sitter](https://tree-sitter.github.io) grammar for the
[gsx](https://github.com/gsxhq/gsx) templating language — syntax highlighting across
Go, HTML, JavaScript, and CSS in `.gsx` files, including gsx's `{ }` Go holes,
`@{ }` JS/CSS interpolation holes, and the `|>` pipeline.

## How it works

gsx structure is parsed natively; the base languages are delegated via tree-sitter
**injection**: `go` (file-level Go + every `{ }`/`@{ }` hole, each `|>` segment
separately), `javascript` (combined, over `<script>` bodies), `css` (combined, over
`<style>` bodies). See `queries/injections.scm`.

## Install in Neovim

> `nvim-treesitter` was archived (April 2026); Neovim 0.10+ has built-in
> tree-sitter, so gsx is installed the **native** way — a compiled parser on
> `runtimepath` plus query files. No `nvim-treesitter` dependency.

**Prerequisites:** Neovim ≥ 0.10 (tested on 0.12), a C compiler, and the
[`tree-sitter` CLI](https://github.com/tree-sitter/tree-sitter) (`npm i -g tree-sitter-cli`
or `cargo install tree-sitter-cli`).

Embedded **Go / JavaScript / CSS** highlight via injection, so those parsers must
also be installed (most configs already have them; otherwise build them the same
way or use a parser manager such as
[tree-sitter-manager.nvim](https://github.com/romus204/tree-sitter-manager.nvim)).

### lazy.nvim

```lua
{
  "gsxhq/tree-sitter-gsx",
  lazy = false,
  -- compile the parser and expose queries where Neovim looks for them
  -- (queries/<lang>/), inside the plugin dir which lazy adds to runtimepath:
  build = "tree-sitter build -o parser/gsx.so . && mkdir -p queries/gsx && cp queries/highlights.scm queries/injections.scm queries/gsx/",
  init = function()
    vim.filetype.add({ extension = { gsx = "gsx" } })
  end,
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "gsx",
      callback = function(ev)
        pcall(vim.treesitter.start, ev.buf, "gsx")
        vim.bo[ev.buf].commentstring = "// %s"
      end,
    })
  end,
}
```

Run `:Lazy build tree-sitter-gsx` after a grammar update.

### Manual (any/no plugin manager)

```bash
git clone https://github.com/gsxhq/tree-sitter-gsx
cd tree-sitter-gsx
tree-sitter build -o ~/.config/nvim/parser/gsx.so .
mkdir -p ~/.config/nvim/queries/gsx
cp queries/highlights.scm queries/injections.scm ~/.config/nvim/queries/gsx/
```

Then in your config:

```lua
vim.filetype.add({ extension = { gsx = "gsx" } })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gsx",
  callback = function(ev) vim.treesitter.start(ev.buf, "gsx") end,
})
```

(`~/.config/nvim` is on `runtimepath`, so `parser/gsx.so` and `queries/gsx/*.scm`
are discovered automatically. Alternatively register the parser from an explicit
path with `vim.treesitter.language.add("gsx", { path = "/abs/path/gsx.so" })`.)

Other editors that consume tree-sitter grammars (Helix, Zed) and GitHub use the
same `queries/` — point them at this repo per their docs.

## Develop

```bash
npm install
npx tree-sitter generate
npx tree-sitter test
```

Parse all examples (expect exit 0 for each):

```bash
for f in test/examples/*.gsx; do npx tree-sitter parse -q "$f"; done
```

## Status

v1: highlighting for Neovim (native; see above), Helix/Zed, and GitHub
(`queries/highlights.scm` + `queries/injections.scm`). Deferred:
indents/folds/locals, JS/CSS-context **attribute** injection (`x-data`, `style=`),
npm/crate bindings, GitHub Linguist submission, VS Code.

The grammar re-implements gsx's boundary rules independently of the Go parser; the
`test/examples/` corpus (synced from gsx `examples/`) keeps them in agreement.
