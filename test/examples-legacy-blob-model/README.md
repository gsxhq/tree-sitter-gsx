# Legacy blob-model examples (temporarily relocated)

`.gsx` example files as they existed on `main` before the
`unified-go-grammar` branch replaced `grammar.js` with a Go-superset
architecture (see
`docs/superpowers/specs/2026-07-08-unified-go-grammar-phase1-design.md`).
Every file here uses `component` syntax and/or attributes, neither of
which exist in this branch's Phase 1 grammar.

Moved here — not deleted, not modified — so CI's "Parse examples" step on
this branch doesn't fail on syntax this branch hasn't built yet.

**Phase 2** ports/reconciles these against the new unified grammar and
restores them to `test/examples/`.
