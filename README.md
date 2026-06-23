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

v1: highlighting for Neovim/Helix/Zed and GitHub (`queries/highlights.scm` +
`queries/injections.scm`). Deferred: indents/folds/locals, JS/CSS-context
**attribute** injection (`x-data`, `style=`), npm/crate bindings,
nvim-treesitter / Linguist submission, VS Code.

The grammar re-implements gsx's boundary rules independently of the Go parser; the
`test/examples/` corpus (synced from gsx `examples/`) keeps them in agreement.
