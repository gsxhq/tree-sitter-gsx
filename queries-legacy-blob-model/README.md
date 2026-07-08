# Legacy blob-model queries (temporarily relocated)

`queries/highlights.scm` and `queries/injections.scm` as they existed on
`main` before the `unified-go-grammar` branch replaced `grammar.js` with a
Go-superset architecture (see
`docs/superpowers/specs/2026-07-08-unified-go-grammar-phase1-design.md`).

Both reference node types from the old blob-model grammar (e.g.
`component_declaration`, `go_chunk`) that don't exist in this branch's
Phase 1 grammar, so leaving them in `queries/` makes `tree-sitter test`
fail with a hard query-load error ("Invalid node type") — not a normal
test failure, a query file that can't even parse against the new grammar.

Moved here — not deleted, not modified — so `tree-sitter test` on this
branch exits cleanly instead of hard-erroring on queries that don't apply
to Phase 1's grammar yet.

Relocating the queries alone is not sufficient: `tree-sitter test` still
tries to run a highlight test whenever `test/highlight/` is non-empty, and
with `queries/highlights.scm` missing that attempt itself hard-errors
("No such file or directory", exit 1) — confirmed empirically, not the
benign warning it might look like at a glance. `test/highlight/tags.gsx`
is also written in the old blob-model syntax (`component Card(x int) {
... }`, attributes, `{ }` holes, `|>` pipes) that doesn't parse under
Phase 1's grammar either, so it was relocated alongside these queries to
`test/highlight-legacy-blob-model/` (see that directory) using the same
naming convention as Task 1's `test/corpus-legacy-blob-model/` and
`test/examples-legacy-blob-model/`. With both `queries/` and
`test/highlight/` empty, `tree-sitter test` exits 0 cleanly with no
warning at all.

**Phase 3** ("query rewrite + editor rollout" per the design spec) rewrites
these against the new grammar's node types and restores queries/highlights
here and test/highlight-legacy-blob-model/tags.gsx to their original
locations.
