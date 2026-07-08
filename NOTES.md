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

## Phase 2a notes (element children)

- `element`/`fragment` bodies are now `repeat($._child)` (`_child` =
  element/fragment/hole/control_flow/text) instead of Phase 1's flat
  `element_text` — the old grammar's separate `_hole_body:
  choice($.pipeline, repeat1($._node))` machinery is not needed: every
  real standalone-hole usage in the legacy corpus/examples is a single
  node, and elements/fragments are already Go `_expression`s (Phase 1),
  so `hole: '{' _expression '}'` covers it.
- `for` loops needed Go's own `for_clause`/`range_clause` rules reused
  verbatim for the condition (`_, it := range items` isn't a valid Go
  `_expression` on its own) — `if`/`switch` conditions are plain
  `_expression`. Found by testing, not assumed.
- `switch`'s `case`/`default` clauses are **not** parsed as real Go
  switch-clause structure — they fall through to `text`, same as the
  pre-existing shipped (blob-model) grammar's own
  `test/corpus-legacy-blob-model/control_flow.txt` (`switch v { case "a":
  }` → `(block (text))` there too). Confirmed parity, not a regression,
  by checking the old grammar's own corpus before assuming either way.
- Still no external scanner: `text: token(prec(-1, /[^<{]+/))` is a plain
  regex token.
- Deferred (see the Phase 2a spec for the full list): attributes (2b),
  `f`/`js`/`css` literals (2c), `component` declarations (2d), `doctype`/
  `html_comment`/`content_comment`/`raw_element` (`raw_element` likely
  needs the first real external scanner of Phase 2), the `\|>` pipeline
  operator inside holes, `value_control_flow`.
