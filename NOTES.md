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

## Phase 2c notes (f/js/css literals)

- This is the unified grammar's **first real external scanner**
  (`src/scanner.c`, `embedded_text`/`embedded_text_dq`). Every prior
  phase needed none — but an `f`/`js`/`css` literal's body must stop at
  a closing delimiter or an `@{` hole while treating a bare `@` (not
  followed by `{`) as ordinary text, and that lookahead genuinely can't
  be expressed as a plain regex token (tree-sitter's `token()` regex has
  no lookahead). Lifted `scan_embedded_text`/`scan_embedded_text_dq`
  near-verbatim from the pre-existing shipped grammar's scanner — those
  two functions were always self-contained, with no dependency on the
  Go-blob-boundary logic that made the rest of the old scanner obsolete.
- `embedded_f_literal` joins `_expression` (so it works as a bare Go
  value AND automatically inside plain `{ }` holes via 2a's `hole` rule,
  with zero change needed to `hole` itself). `js`/`css` stay
  attribute-context only, matching the original (already-shipped)
  f-literal design — not a new restriction introduced here.
- `css_composed_value` deferred — grepped the full legacy corpus and all
  13 example `.gsx` files: appears in exactly 2 corpus test cases, zero
  real examples. Narrow enough to defer to a dedicated follow-up.
- `@{ }` pipe chains were scoped IN (unlike plain-`{ }`-hole pipe support,
  which stays deferred) — genuinely used in the legacy corpus
  (`holes_attrs.txt:295`: `` f`Item @{ id |> upper }` ``), unlike the
  single-quote/multi-node-hole cases in earlier phases where deferral was
  backed by zero real usage. A pipe stage is syntactically just a real Go
  expression (identifier or call), so `at_hole` needed no filter-resolution
  machinery — only `seq($._expression, repeat(seq('\|>', $._expression)))`.
  Confirmed `'\|>'` needs no external scanner and doesn't collide with
  Go's `\|`/`\|\|` operators — tree-sitter's own longest-match
  tokenization disambiguates it the same way `<-`/`<>` already are.
- Deferred (see the Phase 2c spec for the full list): `css_composed_value`,
  `value_control_flow`, `component` declarations (2d), pipe chains in
  plain `{ }` holes (still 2a/2b's existing deferral).

## Backlog: scanner escape-fidelity gap vs. the real gsx parser (not a 2d prerequisite)

Found by this branch's own adversarial review, **not introduced by any
phase on this branch** — the lifted `scan_embedded_text`/
`scan_embedded_text_dq` are byte-faithful to the *currently-shipped*
scanner, which itself was already not fully faithful to the real gsx
compiler's escape rules (`parser/attrs.go` in the `gsx` repo) on two
edges:

- **`\@{` inside a literal is misparsed as a hole (Important — silent
  misparse, not a visible `ERROR`).** The real parser's
  `embeddedAtBraceEscaped` (`parser/attrs.go:605`) treats `\@{` as a
  literal `@{`, no hole. The scanner has no `\@` handling at all, so
  `` f`lit \@{x} end` `` produces an `at_hole` where real gsx sees text.
  Fix: when the scanner's backslash branch sees `\@`, consume the `@` so
  it can't open a hole (mirroring the real parser's parity logic).
- **Backslash-parity before a delimiter is unhandled (Minor — fails
  safely as a visible `ERROR`, but rejects valid gsx).** The real
  parser's `embeddedDelimEscaped` (`parser/attrs.go:594`) counts
  preceding backslashes and only treats the delimiter as escaped on an
  *odd* count, so `` f`a\\` `` (even = 2) should terminate with text
  `a\\`. The scanner has no parity counting — it always treats a
  backslash-then-delimiter as escaped, so this input runs away to `EOF`
  and `ERROR`s instead of parsing.

Both are pre-existing (present in the currently-shipped grammar too) and
don't touch the surface any Phase 2 sub-phase builds on — independent of
the phase sequence, not a blocker for 2d. Fix in a dedicated pass, with
new corpus cases pinning both the fix and the already-working basic
escape case (`` f`a \`esc\` b` ``, verified working but not yet pinned in
`test/corpus/phase2c_literals.txt`).

## Phase 2d notes (component declarations)

- `component_declaration`'s receiver, parameters, and type parameters
  reuse Go's own `parameter_list`/`type_parameter_list` **verbatim** — no
  custom regex-blob capture (`_paren_go`/`_bracket_go` in the old
  grammar). Now that Go is native, `component (p Page) Content()` gets a
  real `receiver: (parameter_list (parameter_declaration name: … type:
  …))`, and `component List[T any](…)` gets a real
  `type_parameter_list`, with full type-aware structure for free. The
  receiver-as-`parameter_list` shape mirrors Go's own
  `method_declaration`.
- `component_declaration` joins a **redeclared `_top_level_declaration`**
  (package/function/method/import + component) — the same
  rule-names-only redeclaration pattern Phase 1 used for `_expression`,
  and the same maintenance note applies: eyeball this list against
  tree-sitter-go's own `_top_level_declaration` on every upstream version
  bump (a new top-level declaration kind added upstream needs a matching
  addition here). Low-frequency — it's Go's top-level enumeration, rarely
  changed.
- `component_body` is its own named node (not element's inline children)
  so consumers can distinguish a component body from element children by
  node type — matches the old grammar's separate `body` node. Its content
  is 2a's `_child`, so component bodies get text/nested-markup/holes/
  control-flow with no new child-content grammar.
- The `mycomponent` keyword-boundary case (an identifier that starts with
  `component`) parses as a normal `var_declaration`, not a mis-lexed
  keyword — pinned by corpus, as the old grammar also tested.
- No external scanner added — `src/scanner.c` (from 2c) is untouched.
- Deferred (see the Phase 2d spec): `doctype`, `html_comment`,
  `raw_element` (`<script>`/`<style>` raw-text — needs its own scanner),
  `content_comment` — all independent child-content types, to be scoped
  by 2e (full corpus port) or a dedicated follow-up.
- A consumer **cannot rely on the grammar to reject a nested `component`**
  (a `component` declared inside another component's markup body): it's
  silently absorbed as `_child` `(text)`, no ERROR — inherent to `_child`
  including `text` (reviewed in 2a). Benign (gsx's compiler rejects
  nested components semantically; nobody writes them), noted so a
  consumer knows the grammar layer doesn't enforce top-level-only.

## Phase 2d final-review finding: 2e-scoping inputs (real-.gsx-file probe)

The Phase 2d final adversarial review parsed all 13 real
`test/examples-legacy-blob-model/*.gsx` files as the readiness signal for
2e's corpus port. Result: 1 clean, 12 ERROR — but **every failure roots
at a not-yet-ported gsx construct, never at anything Phases 1–2d claim to
support, and every failure is a visible ERROR/MISSING marker (no silent
misparse of a valid construct)**. The Go embedded in cascaded files
(multi-name struct fields, `iota`, `qualified_type`, pointer receivers)
parses correctly inside the outer ERROR. Blockers, by frequency:

- **Composable class/style list value** (`class={ "a", "b": cond, expr }`)
  — the #1 real-file blocker (5 of 13 files), and **not** covered by the
  existing deferral labels. It is neither `value_control_flow`
  (`class={ if … }`) nor `css_composed_value` (composing css segments):
  it's a comma-separated list whose entries may be `"str"`, `"str":
  cond`, or a bare expr. The old blob grammar absorbed it into the opaque
  `_attr_hole_body`/`go_text` blob; the unified `expr_attribute`
  (`{ $._expression }`, 2b) correctly requires a single real Go
  expression and visibly rejects the list. **2e must scope this as its
  own structured rule** — it's a flagship gsx feature, tracked here by
  name so it isn't rediscovered mid-port. (Predates 2d — a 2b-surface
  gap, not a 2d regression.)
- `{{ … }}` explicit Go statement block (1 file) — not yet ported.
- Dotted tag names `<ui.AppShell>`/`<p.Content/>` (1 file) — already
  tracked (see "Capability regressions" at the top of this file).
- `doctype` / `raw_element` / `content_comment` (several files) — the
  already-listed 2d deferrals above.
