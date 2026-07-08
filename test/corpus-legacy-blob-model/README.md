# Legacy blob-model corpus (temporarily relocated)

These are the `test/corpus/*.txt` files as they existed on `main` before the
`unified-go-grammar` branch replaced `grammar.js` with a Go-superset
architecture (see
`docs/superpowers/specs/2026-07-08-unified-go-grammar-phase1-design.md`).

They test the "Go as opaque blob + tree-sitter-go injection" grammar
(`go_chunk`/`go_text`/`component_declaration`/attributes/`{ }` holes/etc.)
that this branch does not implement yet — Phase 1 only adds `element`/
`fragment` as native Go expressions, with no `component` syntax or
attributes at all.

Moved here — not deleted, not modified — so `tree-sitter test` on this
branch validates only what Phase 1 actually claims to support, instead of
failing on assertions about syntax this branch hasn't built yet.

**Phase 2** ports/reconciles these against the new unified grammar and
restores them to `test/corpus/`.
