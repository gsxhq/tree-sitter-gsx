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
- Still no external scanner: `text` is a plain regex token (see below for
  its exact, twice-revised regex).
- Deferred (see the Phase 2a spec for the full list): attributes (2b),
  `f`/`js`/`css` literals (2c), `component` declarations (2d), `doctype`/
  `html_comment`/`content_comment`/`raw_element` (`raw_element` likely
  needs the first real external scanner of Phase 2), the `\|>` pipeline
  operator inside holes, `value_control_flow`.
- `text` now also excludes `}` (`/[^<{}]+/`, not just `/[^<{]+/`) — without
  it, a control-flow block whose last child is plain text let `text`
  swallow the block's own closing `}`, desyncing the parse (found by
  adversarial review, not the corpus, since every corpus `control_flow`
  case happened to be element-terminated). This matches the pre-existing
  shipped grammar's own text token (`/[^<{}>]+/`) more closely. Accepted
  tradeoff: a bare `}` inside plain element text now ERRORs where it
  previously parsed by accident — the old grammar has this same
  limitation, so it's not a new regression.
- `switch` with an init-clause (`switch x := f(); x { ... }`) ERRORs —
  `control_flow`'s shared `condition: choice($._expression, $.for_clause,
  $.range_clause)` doesn't cover Go's switch-with-initializer condition
  shape. Localized, non-cascading `ERROR`, deferred rather than silently
  accepted as correct.

## Phase 2b notes (attributes)

- `element` gained a real attribute list: `static_attribute` (reuses
  Go's own `_string_literal` — dropped the old grammar's custom
  single-quote-supporting `quoted_string`; confirmed via grep across the
  full legacy corpus and all 13 example `.gsx` files that single-quoted
  attribute values were never actually used), `expr_attribute` (reuses
  2a's `hole` unchanged — `name={ expr }`), `bool_attribute`,
  `spread_attribute` (`{ expr... }`), and `conditional_attribute`
  (`if`/`for`+optional `else`, reusing the same `for_clause`/
  `range_clause` condition-clause approach as 2a's `control_flow`, but
  wrapping a repeated attribute list instead of a repeated child list).
- Key disambiguation verified by inspecting the actual tree, not just
  absence of an `ERROR`: a variadic Go call inside an `expr_attribute`'s
  hole (`data={fn(args...)}`) correctly parses as
  `hole(call_expression(argument_list(variadic_argument)))`, not confused
  with `spread_attribute`'s own top-level `{ expr... }` shape, even
  though both involve `...`.
- `content_comment` (inline attribute comments, e.g. `<div /* note */
  class="x">`) is deferred alongside its child-position form from 2a —
  one rule, implemented once later, not split across two sub-phases.
- `conditional_attribute` now supports `else if`/multi-`else` chains via
  a new `attribute_else_clause` rule, mirroring 2a's `else_clause`
  (`repeat($.attribute_else_clause)` instead of a single `optional`
  else) — fixes a real gap vs. the old grammar (which only had a single
  optional else on attributes) that the canonical gsx corpus actually
  exercises (`internal/corpus/testdata/cases/attrs/cond_attr_else_if_two.txtar`,
  `cases/fallthrough/cond_attr_else_if_override.txtar`). Found by this
  branch's own adversarial review process, not by the original corpus.
- `conditional_attribute` supports `if`/`for` only (no `switch`) —
  matches the old grammar's own scope, not a new limitation. That
  reasoning applies to the missing `switch` support specifically, not to
  the else-chain gap above: the old grammar's attribute conditional was
  also single-else-only, so `else if`/multi-`else` chaining is a genuine
  improvement beyond old-grammar parity, not just matching prior scope.
- Still no external scanner.
- Deferred (see the Phase 2b spec for the full list): `f`/`js`/`css`
  literal attribute values (2c), `css_composed_value`,
  `value_control_flow` (if/switch as an attribute *value* — distinct from
  `conditional_attribute`, which wraps whole attributes), `component`
  declarations (2d), the `\|>` pipeline operator inside holes (inherited
  from 2a, `expr_attribute` reuses `hole` as-is).
