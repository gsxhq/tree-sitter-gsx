# Unified Go+gsx Grammar — Phase 2c: `f`/`js`/`css` Literals

> **For agentic workers:** this is a design spec, not a plan. Implementation
> follows superpowers:writing-plans → superpowers:subagent-driven-development
> once this spec is approved. Continues on the same `unified-go-grammar`
> branch as Phases 1, 2a, and 2b.

**Goal:** Add gsx's interpolating literal syntax — `f`/`js`/`css` prefix
before a `` `…` ``/`"…"` string, with `@{ }` holes (including `\|>` pipe
chains) — as a Go value (`f` only), an attribute value (all three), and
inside `{ }`/hole positions (via `_expression`, `f` only — automatic once
`embedded_f_literal` is added to `_expression`, no special-casing needed).
Fourth of five Phase 2 sub-phases (2a children → 2b attributes → **2c
literals** → 2d `component` declarations → 2e full corpus port).

**Architecture:** `embedded_f_literal`/`embedded_js_literal`/
`embedded_css_literal` and `at_hole` are ported from the pre-existing
shipped grammar largely unchanged (they were never part of the Go-blob
problem — an `f`/`js`/`css` literal's *body* was always its own
mini-language, scanner-based, independent of Go-boundary detection).
`embedded_f_literal` joins `_expression`'s choice list (`js`/`css` stay
attribute-context only, matching the original f-literal design).
`embedded_attribute` joins `attribute`'s choice list. This phase
introduces the unified grammar's **first real external scanner** — a new,
minimal `src/scanner.c` containing only `scan_embedded_text`/
`scan_embedded_text_dq`, lifted near-verbatim from the pre-existing
shipped grammar's scanner (self-contained, no dependency on the
now-obsolete Go-blob-boundary logic). `at_hole`'s pipe-chain support
(`@{ x \|> f() }`) is scoped into this phase (see Decision 2) as a plain
`token('\|>')` sequence — no scanner needed for the pipe operator itself,
disambiguated by tree-sitter's own longest-match tokenization the same
way `<-`/`<>` already are.

**Tech stack:** `tree-sitter-cli`, `tree-sitter-go` (already pinned
devDependency), Node.js, a C compiler (for the new `scanner.c` — already
a build-time requirement per this repo's README, unchanged by this phase).

## Global Constraints

- Builds on 2a's `hole`/`_expression`, 2b's `attribute`/`attribute_name`.
- `css_composed_value` (composing multiple `css` literal segments with Go
  text between them for `style` attribute values) is **out of scope** —
  confirmed narrow usage (2 corpus tests, zero real `.gsx` examples);
  deferred to a dedicated follow-up, not silently dropped.
- `value_control_flow` (if/switch as an attribute *value*, distinct from
  2b's `conditional_attribute` which wraps whole attributes) is **out of
  scope**.
- `component` declarations remain out of scope (2d) — this phase's tests
  stay `.go`-shaped, same as 2a/2b.
- `js`/`css` literals are attribute-context only, never a standalone Go
  value — only `f` joins `_expression`'s choice list. This matches the
  original (already-shipped) f-literal design, not a new restriction.
- Every new rule ships `test/corpus/*.txt` coverage.
- The new `src/scanner.c` is genuinely minimal — only what
  `embedded_text`/`embedded_text_dq` require. Do not port any other
  function from the pre-existing shipped scanner (the Go-blob-boundary
  functions are obsolete and must not be reintroduced).

---

## Decisions (both evidence-backed)

**1. `css_composed_value` deferred.** Grepped the full legacy corpus and
all 13 example `.gsx` files: `css_composed_value` appears in exactly 2
corpus test cases (`holes_attrs.txt`) and zero real examples. Narrow
enough to defer to a dedicated follow-up without blocking this phase's
core ask (f/js/css literals as values).

**2. `@{ }` pipe chains scoped INTO this phase (user decision, reversing
my initial recommendation).** Unlike `css_composed_value` or the 2b
single-quote case, pipe-in-`@{ }` is genuinely used:
`` f`Item @{ id |> upper }` `` appears in `holes_attrs.txt:295`. 2a/2b
defer pipe support in *plain* `{ }` holes (a separate, larger,
dedicated-sub-phase-worthy feature — filter resolution, the `std`
package, etc.) — but `@{ }` pipe chains are syntactically much narrower:
a pipe stage is just a real Go expression (typically a bare identifier or
a call), so the grammar only needs `seq($._expression, repeat(seq('|>',
$._expression)))` — no filter-resolution semantics live at the tree-sitter
layer (that's the real gsx compiler's job, same seed-first
forward-application model the project already uses elsewhere). Verified
empirically that a plain `token('|>')` needs no external scanner and
doesn't collide with Go's `|`/`||` operators (tree-sitter's longest-match
tokenization disambiguates automatically, the same mechanism that already
separates `<-`/`<>` from `<`).

## Prototype findings (verified, not assumed)

Extended the Phase 2b scratch grammar in a throwaway scratch directory,
adding a real (not stubbed) `src/scanner.c`. All cases produced **zero
`ERROR` nodes**, `tree-sitter generate` reported **zero unresolved
conflicts**, and `tree-sitter build` compiled the new scanner cleanly:

1. `` var x = f`hi @{name}` `` — bare `f`-literal as a Go value with a
   hole (backtick delimiter).
2. `` var x = f"hi @{name}" `` — double-quote delimiter variant.
3. `` var x = <div class=js`track(@{count})`/> `` — `js` literal as an
   attribute value.
4. `` var x = <div style=css`--n:@{count}`/> `` — `css` literal as an
   attribute value.
5. `` var x = <div>{f`hi @{name}!`}</div> `` — `f`-literal used *inside a
   plain `{ }` hole* — works automatically because `embedded_f_literal`
   is now just another `_expression` alternative; no special-casing
   needed in `hole`'s own rule.
6. `` var x = <div title=`literal @{not-a-hole}`/> `` — **the "one rule,
   no exceptions" regression check**: a *bare* backtick attribute value
   (no `f`/`js`/`css` prefix) stays a plain `static_attribute` with
   `raw_string_literal`, and `@{not-a-hole}` is captured as literal
   string content, not interpolated. Confirmed by inspecting the actual
   tree, not just absence of an `ERROR`.
7. `` var x = <button @click=js"emit(`@{variant}`)">Quoted</button> `` —
   `js` double-quote variant containing literal backticks.
8. `` var x = f`a @member b` `` — **the key scanner-lookahead check**: a
   bare `@` not followed by `{` (e.g. `@member`) stays part of the text
   run, not misread as a hole start. Confirmed by inspecting the tree:
   one `embedded_text` node spanning the whole `"a @member b"`, not split.
9. `` var x = <span title=f`Item @{ id |> upper }`>y</span> `` — pipe
   chain inside an attribute-value `f`-literal's hole, the exact
   `holes_attrs.txt:295` pattern.
10. `` var x = f`@{ id |> truncate(10) |> upper }` `` — a two-stage pipe
    chain, confirmed by tree inspection: `at_hole` containing an
    `identifier`, a `call_expression`, and another `identifier` in
    sequence.
11. `return a | b` / `return a || b` — Go's bitwise-or and logical-or
    operators, confirmed untouched by the new `'|>'` token.

The full existing 36-case corpus (Phase 1's 13 + 2a's 12 + 2b's 11) was
re-run against this scanner-extended grammar and passed **unchanged** —
purely additive, no existing tree shape affected.

## Grammar (verified shape)

```js
// grammar.js — additions on top of Phase 2b's grammar.js.

// externals now non-empty for the first time in the unified grammar.
externals: $ => [$.embedded_text, $.embedded_text_dq],

_expression: $ => choice(
  // ...all existing Phase 1/2a/2b alternatives, unchanged...
  $.embedded_f_literal, // js/css stay attribute-context only — see below
),

// f`…`/f"…": generic interpolating literal. js/css embed their
// sublanguage; f does not — all three take @{ } holes and support both
// delimiters (embedded_text stops at a backtick; embedded_text_dq stops
// at a double-quote — external scanner, lifted from the pre-existing
// shipped grammar's scan_embedded_text/scan_embedded_text_dq).
embedded_f_literal: $ => choice(
  seq(alias('f', $.embedded_language), '`', repeat(choice($.embedded_text, $.at_hole)), '`'),
  seq(alias('f', $.embedded_language), '"', repeat(choice($.embedded_text_dq, $.at_hole)), '"'),
),
embedded_js_literal: $ => choice(
  seq(alias('js', $.embedded_language), '`', repeat(choice($.embedded_text, $.at_hole)), '`'),
  seq(alias('js', $.embedded_language), '"', repeat(choice($.embedded_text_dq, $.at_hole)), '"'),
),
embedded_css_literal: $ => choice(
  seq(alias('css', $.embedded_language), '`', repeat(choice($.embedded_text, $.at_hole)), '`'),
  seq(alias('css', $.embedded_language), '"', repeat(choice($.embedded_text_dq, $.at_hole)), '"'),
),

// @{ expr } / @{ expr |> stage |> stage } hole inside f/js/css literal
// text. A pipe stage is syntactically just a real Go expression
// (typically identifier or call_expression) — codegen handles seed-first
// forward-application, the grammar only needs the shape.
at_hole: $ => seq('@{', $._expression, repeat(seq('|>', $._expression)), '}'),

embedded_attribute: $ => prec(1, seq(
  field('name', $.attribute_name),
  '=',
  choice(
    field('value', $.embedded_f_literal),
    field('value', $.embedded_js_literal),
    field('value', $.embedded_css_literal),
  ),
)),

attribute: $ => choice(
  $.embedded_attribute, // new — first in the list, matching the old grammar's own ordering
  $.static_attribute,
  $.expr_attribute,
  $.bool_attribute,
  $.spread_attribute,
  $.conditional_attribute,
),
```

```c
// src/scanner.c — new file (Phase 2c is the first sub-phase to need one).
#include "tree_sitter/parser.h"
#include <stdbool.h>

enum TokenType {
  EMBEDDED_TEXT,
  EMBEDDED_TEXT_DQ,
};

void *tree_sitter_gsx_external_scanner_create(void) { return NULL; }
void tree_sitter_gsx_external_scanner_destroy(void *p) {}
unsigned tree_sitter_gsx_external_scanner_serialize(void *p, char *b) { return 0; }
void tree_sitter_gsx_external_scanner_deserialize(void *p, const char *b, unsigned n) {}

static void advance(TSLexer *l) { l->advance(l, false); }

// Lifted near-verbatim from the pre-existing shipped grammar's scanner.c
// (scan_embedded_text) — self-contained, no dependency on Go-blob-boundary
// logic (which is obsolete in the unified grammar).
static bool scan_embedded_text(TSLexer *l) {
  bool consumed = false;
  while (!l->eof(l)) {
    if (l->lookahead == '`') { l->mark_end(l); return consumed; }
    if (l->lookahead == '@') {
      l->mark_end(l);
      advance(l);
      if (l->lookahead == '{') return consumed;
      consumed = true;
      continue;
    }
    if (l->lookahead == '\\') {
      advance(l);
      if (!l->eof(l) && l->lookahead == '`') advance(l);
      consumed = true;
      l->mark_end(l);
      continue;
    }
    advance(l);
    consumed = true;
    l->mark_end(l);
  }
  l->mark_end(l);
  return consumed;
}

static bool scan_embedded_text_dq(TSLexer *l) {
  bool consumed = false;
  while (!l->eof(l)) {
    if (l->lookahead == '"') { l->mark_end(l); return consumed; }
    if (l->lookahead == '@') {
      l->mark_end(l);
      advance(l);
      if (l->lookahead == '{') return consumed;
      consumed = true;
      continue;
    }
    if (l->lookahead == '\\') {
      advance(l);
      if (!l->eof(l) && l->lookahead == '"') advance(l);
      consumed = true;
      l->mark_end(l);
      continue;
    }
    advance(l);
    consumed = true;
    l->mark_end(l);
  }
  l->mark_end(l);
  return consumed;
}

bool tree_sitter_gsx_external_scanner_scan(void *payload, TSLexer *l, const bool *valid) {
  if (valid[EMBEDDED_TEXT]) {
    if (scan_embedded_text(l)) { l->result_symbol = EMBEDDED_TEXT; return true; }
  }
  if (valid[EMBEDDED_TEXT_DQ]) {
    if (scan_embedded_text_dq(l)) { l->result_symbol = EMBEDDED_TEXT_DQ; return true; }
  }
  return false;
}
```

Function names in the real implementation must use whatever
`tree_sitter_<grammar_name>_external_scanner_*` prefix `tree-sitter
generate` actually emits for this repo's grammar name (`gsx`) — the
prototype above used a scratch grammar name (`gsxgo_phase2c`) for its own
throwaway `tree-sitter.json`; the plan's implementer must use the real
generated prefix, not copy the prototype's literally.

## Scope

**In scope:**
- `embedded_f_literal` (both delimiters) added to `_expression`.
- `embedded_js_literal`/`embedded_css_literal` (both delimiters),
  attribute-context only.
- `at_hole` with pipe-chain support.
- `embedded_attribute`, added to `attribute`'s choice list.
- The new minimal `src/scanner.c` (`embedded_text`/`embedded_text_dq`
  only).
- `test/corpus/` coverage for all 11 verified cases above.

**Explicitly out of scope (deferred):**
- `css_composed_value` — dedicated follow-up.
- `value_control_flow` (attribute-*value* if/switch) — dedicated
  follow-up or 2d.
- `component` declarations — 2d.
- Pipe chains in *plain* `{ }` holes (still 2a/2b's existing deferral —
  unaffected by this phase scoping in `@{ }` pipe support specifically).
- Any porting of the pre-existing shipped scanner's other functions
  (`scan_go_text_impl`, `scan_raw_text`, `scan_pipe`, `scan_style_text`)
  — all either obsolete (Go-blob-boundary) or not yet needed
  (`scan_raw_text`/`scan_style_text` are `raw_element`/2d concerns;
  `scan_pipe` isn't needed at all — this phase's `'|>'` is a plain
  literal token, no scanner required for it).

## Testing strategy

- New `test/corpus/*.txt` coverage for all 11 verified cases (controller's
  call at plan time on filename).
- Full existing 36-case suite must still pass — verified above to need
  zero regeneration (purely additive, like 2b's transition, unlike 2a's).
- `tree-sitter generate`: zero unresolved conflicts. `tree-sitter build`:
  the new `scanner.c` compiles cleanly (first phase where a C compilation
  failure is even possible — prior phases had no scanner to compile).
  `tree-sitter test`: clean exit, full corpus passing, no warnings.
- Verified from a fresh clone, same as Phases 1/2a/2b — this is
  especially important for this phase since it's the first to introduce
  a C build step; a fresh clone with no cached build artifacts is the
  real test of whether the scanner builds correctly for a new
  contributor/CI, not just in a sandbox that already has stale `.o`
  files lying around.

## Done criteria

1. `embedded_f_literal`/`embedded_js_literal`/`embedded_css_literal` parse
   correctly in Go-value (`f` only), attribute-value (all three), and
   plain-hole (`f` only, via `_expression`) positions, with zero `ERROR`
   nodes on the corpus.
2. `at_hole` supports both plain expressions and `\|>` pipe chains, with
   the bare-`@`-vs-`@{`-hole scanner lookahead verified (case 8 above).
3. Full existing 36-case corpus still parses with zero `ERROR` nodes
   (regenerate only if a real diff is found — not assumed clean).
4. `tree-sitter generate`: zero unresolved conflicts. `tree-sitter build`:
   scanner compiles cleanly. `tree-sitter test`: clean exit, no warnings.
5. Verified from a fresh clone.
6. NOTES.md gets a "Phase 2c notes" section recording: this is the first
   real external scanner in the unified grammar (and why — the `@{`-hole
   lookahead genuinely can't be expressed as a plain regex token, unlike
   every prior phase's boundary logic); the `css_composed_value` deferral
   (with the grep evidence); the pipe-chain scoping decision (with the
   `holes_attrs.txt:295` citation and why it differs from the plain-`{ }`
   pipe deferral); confirmation that `'|>'` needed no scanner.

## Risks / open questions

- **The scanner function-name prefix must match this repo's real grammar
  name (`gsx`), not the prototype's scratch name** — flagged explicitly
  in the Grammar section above so the plan's implementer doesn't
  copy-paste a broken prefix.
- **`css_composed_value` and `value_control_flow` are two distinct
  deferred style/attribute-value features that a future sub-phase will
  need to disentangle** — not conflated here, but worth flagging that
  neither has its own spec yet; whichever sub-phase picks them up should
  scope them explicitly rather than assume they're the same piece of work.
- **This phase's `embedded_attribute` ordering** (`prec(1)`, first in
  `attribute`'s choice list) is carried forward from the old grammar
  unchanged and was not itself stress-tested for necessity (the prototype
  never hit an actual conflict requiring it) — kept for fidelity with the
  proven-working old design rather than removed speculatively; if a
  future sub-phase's `tree-sitter generate` reports it's now genuinely
  unnecessary, that's fine to simplify then, with evidence.
