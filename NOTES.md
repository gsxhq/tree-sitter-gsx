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
