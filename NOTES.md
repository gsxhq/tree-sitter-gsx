# Phase 1 notes (unified-go-grammar branch)

- No external scanner was needed. `grammar.js` declares no `externals:`
  field; `src/scanner.c` (the old blob-model scanner) is left in place,
  untouched, and confirmed harmless — `tree-sitter generate`/`build`/
  `parse` all succeed with zero `ERROR` nodes with it physically present
  alongside a zero-`externals` grammar.
- The naive `fragment` rule (`seq('<', '>', ...)`, two separate literals)
  does not work — it conflicts with `element`'s `'<' + identifier` path.
  Fixed with an atomic token: `token(seq('<', '>'))`.
- `_expression` is extended by fully redeclaring its alternative list
  (rule names only), not by programmatically spreading the base grammar's
  existing alternatives — `require('tree-sitter-go/grammar.js')` returns
  an opaque `{ grammar: ... }` wrapper once evaluated inside tree-sitter's
  `grammar()` runtime; only `grammar()` itself can unwrap it as a *base*
  argument, our code can't introspect `.rules` on it directly.
- See `docs/superpowers/specs/2026-07-08-unified-go-grammar-phase1-design.md`
  for full rationale.
- `queries/highlights.scm`/`injections.scm` and `test/highlight/tags.gsx`
  also reference the old grammar's node types and needed relocating
  (`queries-legacy-blob-model/`, `test/highlight-legacy-blob-model/`) for
  `tree-sitter test` to exit cleanly — Task 1's plan only anticipated
  `test/corpus/`/`test/examples/`. See `queries-legacy-blob-model/README.md`.

## Capability regressions found during adversarial review (Phase 2 inputs)

Both are visible `ERROR` nodes, never silent misparses — safe, but worth
deciding early in Phase 2 rather than rediscovering:

- **Qualified/dotted tag names** (`<ui.Icon/>`) now ERROR. Phase 1's
  `element`'s `name` field is a bare Go `identifier`; the old blob grammar's
  `tag_name` allowed dots for package-qualified components. Phase 2 needs to
  decide whether `name` becomes a `selector_expression`/`qualified_type`.
- **Whitespace after `<`** (`< Icon/>`) is accepted as markup — harmless in
  Phase 1 (no real Go expression starts with a prefix `<`), but looser than
  JSX-style adjacency if that's wanted later.
