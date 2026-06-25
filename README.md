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

The config below is **self-healing**: it rebuilds the parser automatically
whenever the compiled `parser/gsx.so` is missing or older than the grammar
source (`src/parser.c`). You never need to run `:Lazy build` by hand — a plugin
update (or a local grammar edit) is picked up the next time you open a `.gsx`
buffer.

```lua
-- Compile parser/gsx.so and expose queries at queries/gsx/ (where Neovim's
-- native tree-sitter looks; the plugin dir is on runtimepath).
local function gsx_build(dir)
  vim.fn.mkdir(dir .. "/parser", "p")
  local out = vim.fn.system({ "tree-sitter", "build", "-o", dir .. "/parser/gsx.so", dir })
  if vim.v.shell_error ~= 0 then
    vim.notify("tree-sitter-gsx: parser build failed:\n" .. out, vim.log.levels.ERROR)
    return
  end
  vim.fn.mkdir(dir .. "/queries/gsx", "p")
  for _, q in ipairs({ "highlights", "injections" }) do
    vim.uv.fs_copyfile(dir .. "/queries/" .. q .. ".scm", dir .. "/queries/gsx/" .. q .. ".scm")
  end
end

-- True when the compiled parser is absent or older than the generated grammar.
local function gsx_stale(dir)
  local so = vim.uv.fs_stat(dir .. "/parser/gsx.so")
  if not so then return true end
  local src = vim.uv.fs_stat(dir .. "/src/parser.c")
  return src ~= nil and src.mtime.sec > so.mtime.sec
end

return {
  {
    "gsxhq/tree-sitter-gsx",
    lazy = false,
    build = function(plugin) gsx_build(plugin.dir) end, -- on install / :Lazy update
    init = function()
      vim.filetype.add({ extension = { gsx = "gsx" } })
    end,
    config = function(plugin)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "gsx",
        callback = function(ev)
          if gsx_stale(plugin.dir) then gsx_build(plugin.dir) end -- safety net
          pcall(vim.treesitter.start, ev.buf, "gsx")
          vim.bo[ev.buf].commentstring = "// %s"
        end,
      })
    end,
  },
}
```

> Why the safety net? lazy.nvim only runs `build` on install and `:Lazy update`.
> If that build is ever skipped or fails (or you edit the grammar locally), the
> `gsx_stale` check rebuilds on the next `.gsx` open, so a stale `parser/gsx.so`
> can never silently break highlighting. `vim.uv` is `vim.loop` on Neovim < 0.10.

### Manual (any/no plugin manager)

```bash
git clone https://github.com/gsxhq/tree-sitter-gsx
cd tree-sitter-gsx
tree-sitter build -o ~/.config/nvim/parser/gsx.so .
mkdir -p ~/.config/nvim/queries/gsx
cp queries/highlights.scm queries/injections.scm ~/.config/nvim/queries/gsx/
```

Then in your config (point `repo` at your clone so it self-heals on grammar
updates — `git pull` in the clone is picked up on the next `.gsx` open):

```lua
local repo = vim.fn.expand("~/src/tree-sitter-gsx") -- your clone
vim.filetype.add({ extension = { gsx = "gsx" } })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gsx",
  callback = function(ev)
    local so = vim.fn.stdpath("config") .. "/parser/gsx.so"
    local s, src = vim.uv.fs_stat(so), vim.uv.fs_stat(repo .. "/src/parser.c")
    if not s or (src and src.mtime.sec > s.mtime.sec) then
      vim.fn.system({ "tree-sitter", "build", "-o", so, repo })
      local qd = vim.fn.stdpath("config") .. "/queries/gsx"
      vim.fn.mkdir(qd, "p")
      for _, q in ipairs({ "highlights", "injections" }) do
        vim.uv.fs_copyfile(repo .. "/queries/" .. q .. ".scm", qd .. "/" .. q .. ".scm")
      end
    end
    vim.treesitter.start(ev.buf, "gsx")
  end,
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
