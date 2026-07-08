# Unified Go+gsx Grammar — Phase 2a: Element Children

> **For agentic workers:** this is a design spec, not a plan. Implementation
> follows superpowers:writing-plans → superpowers:subagent-driven-development
> once this spec is approved. Continues on the same `unified-go-grammar`
> branch as Phase 1 (per Phase 1's own spec: the branch stays unmerged until
> Phase 2/3 reach full parity, landing as a sequence of sub-phases, not a
> fresh branch each time).

**Goal:** Give `element`/`fragment` real mixed-content bodies — text, nested
elements/fragments, `{ }` holes, and `if`/`for`/`switch` control-flow — where
Phase 1 has only a flat, un-nestable `element_text` regex. This is the
second of five Phase 2 sub-phases (2a children → 2b attributes → 2c
`f`/`js`/`css` literals → 2d `component` declarations → 2e full corpus
port), each with its own spec/plan.

**Architecture:** `element`/`fragment` bodies become `repeat($._child)`,
where `_child` is a choice of `element`, `fragment`, `hole` (`{ expr }`),
`control_flow` (`{ if/for/switch ... { child* } }`), and `text`. Holes and
control-flow conditions are real Go `_expression`s (with `for` reusing Go's
own `for_clause`/`range_clause`) — no scanner-based condition/hole-boundary
text needed, continuing Phase 1's "Go is native now" simplification.

**Tech stack:** same as Phase 1 — `tree-sitter-cli`, `tree-sitter-go`
(already a pinned devDependency), Node.js.

## Global Constraints

- Builds directly on Phase 1's `element`/`fragment`/`_expression` — no
  change to how elements/fragments are reached as Go values, only to what
  can appear *inside* them.
- Attributes are explicitly **out of scope** — 2b's job. Self-closing and
  open-tag forms stay attribute-free in this phase.
- `f`/`js`/`css` literals are explicitly **out of scope** — 2c's job.
- `component` declarations are explicitly **out of scope** — 2d's job.
  This phase's grammar is still exercised through `.go`-shaped fixtures
  (plain Go functions containing element values), same as Phase 1 — not
  real `.gsx` files, which need `component` (2d) to parse at all.
- `doctype`, `html_comment`, `content_comment`, and `raw_element`
  (`<script>`/`<style>` raw-text bodies) are explicitly **out of scope**
  for this spec — see "Scope > Explicitly out of scope" below.
- Every new rule ships `test/corpus/*.txt` coverage, same convention as
  Phase 1.
- No external scanner unless empirically proven necessary — Phase 1 needed
  none; this spec's own prototyping (below) confirms 2a needs none either.

---

## Background

Phase 1 gave `element`/`fragment` a body of exactly one flat token:
`element_text: $ => token(prec(-1, /[^<]+/))`. This can't represent the
actual shape of markup — `<div>Hello <b>world</b>, you have {count}
items</div>` has text, a nested element, and a hole, all sequential.
Phase 1's own adversarial review flagged this gap explicitly (nested
elements and `{` produce a visible `ERROR`, by design, deferred to Phase 2).

A second, separate question folded into this same spec (per discussion):
the *old* blob-model grammar's standalone `{ }` hole (used e.g. as an
attribute value, `<Panel header={ <h1>hi</h1> }/>`) had its own
`_hole_body: choice($.pipeline, repeat1($._node))` — a hole was either a
pipeline or a **sequence** of markup nodes. Searching the full legacy
corpus and all 13 example `.gsx` files for a genuine multi-node hole
(text directly adjacent to a tag inside a bare `{ }`, not wrapped in
`if`/`for`) found none — every real usage is a single node (one element,
fragment, or expression). Since Phase 1 already made elements/fragments
real Go `_expression`s, a hole can now just be "a Go expression" and the
single-node case falls out for free, with no separate node-sequence
grammar needed for *that* narrower position. (Element/fragment/component
**children** — where multiple sequential nodes are the normal, load-bearing
case — are unaffected by this and are exactly what this spec's `_child`
grammar exists to handle.)

## Prototype findings (verified, not assumed)

Built by extending the same `tree-sitter-go@0.25.0`-composed base as
Phase 1, in a throwaway scratch directory (not part of this repo). All
cases below produced **zero `ERROR` nodes** and `tree-sitter generate`
reported **zero unresolved conflicts** at every step:

1. `var x = <div>Hello <b>world</b>, you have {count} items</div>` —
   mixed text/nested-element/hole in one body.
2. `var x = <div></div>` — empty children.
3. `var x = <div>{x}</div>` — a hole containing a plain identifier.
4. `var x = <div><></></div>` — a nested fragment.
5. `var x = <div>{<Icon/>}</div>` — a hole containing an element (proves
   the "hole = Go expression" simplification: no separate markup-node
   alternative needed for this case).
6. `var x = <Icon/>` — Phase 1's bare self-closing form, confirmed
   unaffected by adding children to the open/close form.
7. `var x = <div>{ if cond { <span/> } }</div>` — `if`-control-flow with
   a plain Go expression condition (no `go_cond_text` scanner).
8. `var x = <div>{ for _, it := range items { <li>{it.Name}</li> } }</div>`
   — **initially failed** (`_, it := range items` isn't a valid Go
   `_expression` — it's a `for`-clause construct). Fixed by reusing Go's
   own `for_statement` condition shape verbatim:
   `choice($._expression, $.for_clause, $.range_clause)` (Go's
   `for_clause`/`range_clause` rules, inherited unmodified from the base
   grammar — not reimplemented). Re-verified clean after the fix.
9. `var x = <div>{ if cond { <span/> } else { <div/> } }</div>` —
   `else`.
10. `var x = <div>{ if a { <span/> } else if b { <div/> } else { <p/> }
    }</div>` — `else if` chains.

All 10 cases pass together in the same grammar; the `for` fix (case 8)
caused no regression in cases 1-7, 9-10.

## Grammar (verified shape)

```js
// Extends Phase 1's grammar.js — only the changed/added rules shown.

element: $ => choice(
  seq('<', field('name', $.identifier), '/>'),
  seq(
    '<', field('open_name', $.identifier), '>',
    repeat($._child),
    '</', field('close_name', $.identifier), '>',
  ),
),

fragment: $ => seq(
  token(seq('<', '>')),
  repeat($._child),
  token(seq('<', '/', '>')),
),

_child: $ => choice(
  $.element,
  $.fragment,
  $.hole,
  $.control_flow,
  $.text,
),

// Hole body is a real Go expression — element/fragment already included
// via _expression (Phase 1). No separate node-sequence alternative; see
// "Background" for why that's not needed.
hole: $ => seq('{', $._expression, '}'),

// Condition reuses Go's own for_statement condition shape (plain expr, or
// a real for_clause/range_clause for `for`) — inherited from the base
// grammar unmodified, not reimplemented. The block body is markup
// children, not Go statements, so control_flow can't reuse Go's native
// if_statement/for_statement wholesale (their block holds $._statement).
control_flow: $ => seq(
  '{',
  alias(choice('if', 'for', 'switch'), $.keyword),
  field('condition', choice($._expression, $.for_clause, $.range_clause)),
  '{', repeat($._child), '}',
  repeat($.else_clause),
  '}',
),

else_clause: $ => seq(
  alias('else', $.keyword),
  optional(seq(alias('if', $.keyword), field('condition', $._expression))),
  '{', repeat($._child), '}',
),

text: $ => token(prec(-1, /[^<{]+/)),
```

Note the `text` token's negated class is `/[^<{]+/` (stops at `<` for a
nested tag/close-tag, and `{` for a hole/control-flow) — narrower than
Phase 1's `/[^<]+/` since content position now also has holes, but still a
plain regex token, no external scanner.

## Scope

**In scope:**
- `element`/`fragment` bodies as `repeat($._child)`.
- `hole: '{' _expression '}'`.
- `control_flow` with `if`/`for`/`switch` + real Go condition clauses
  (reusing `for_clause`/`range_clause` from the base grammar) + `else`/
  `else if` chains.
- `test/corpus/` coverage for all 10 verified cases above, plus additional
  regression coverage (see Testing strategy).

**Explicitly out of scope (deferred):**
- Attributes (2b).
- `f`/`js`/`css` literals, anywhere (2c).
- `component` declarations (2d) — this phase's tests stay `.go`-shaped.
- `doctype`, `html_comment`, `content_comment`, `raw_element`
  (`<script>`/`<style>` raw-text bodies) — all valid `_child`-position
  content in the old grammar, not yet ported. `raw_element` in particular
  needs its own raw-text scanning (stopping at a matching close tag, not
  at `<`/`{`) and may be the first thing in 2a's scope to actually need an
  external scanner — deferred rather than assumed away.
- The `|>` pipeline operator inside holes (old grammar:
  `_hole_body: choice($.pipeline, repeat1($._node))`) — this spec's
  `hole` only accepts a single Go expression, not a pipe chain. Deferred
  to 2c or a dedicated follow-up; not silently dropped.
- `value_control_flow` (if/switch inside an attribute value like
  `class={ if ... }`) — attribute-position concern, 2b's job.

## Testing strategy

- New `test/corpus/*.txt` coverage (or an addition to
  `test/corpus/phase1_elements.txt`'s file, controller's call at plan
  time) for all 10 verified cases, plus:
  - A regression case confirming Phase 1's existing 13 cases still pass
    unmodified (children are additive to `element`/`fragment`, not a
    breaking change to the self-closing form).
  - `switch` control-flow (only `if`/`for` were hand-verified above;
    `switch`'s condition is a plain `_expression` per the shared
    `control_flow` rule, so it's expected to work identically to `if`,
    but ships its own corpus case rather than being assumed from `if`'s).
- `tree-sitter generate` must report zero unresolved conflicts.
- `tree-sitter test` must exit 0 with the full corpus passing (same
  "keep it genuinely green" bar as Phase 1 — the `queries-legacy-blob-model`/
  `test/*-legacy-blob-model` relocations from Phase 1 already handle the
  stale-query-file problem; no new relocation should be needed here since
  this phase touches no additional pre-existing file).
- Verified from a fresh clone, same as Phase 1.

## Done criteria

1. `element`/`fragment` bodies support `repeat($._child)`: text, nested
   elements/fragments, holes, and `if`/`for`/`switch`(+`else`) control-flow,
   all with zero `ERROR` nodes on the corpus.
2. Phase 1's existing 13 corpus cases still pass unmodified.
3. `tree-sitter generate`: zero unresolved conflicts. `tree-sitter test`:
   clean exit, full corpus passing.
4. Verified from a fresh clone.
5. A short written note (append to `NOTES.md`, following Phase 1's
   pattern) records: the hole-simplification finding (no
   `_hole_body`/pipeline-vs-node-sequence split needed), the `for`-clause
   fix, and the explicit deferral list above (so 2b–2e don't rediscover
   what's already been scoped out on purpose).

## Risks / open questions

- **`raw_element` may need 2a's first real external scanner.** Flagged in
  Scope, not resolved here — worth a quick prototype at the start of
  whichever sub-phase picks it up, same as this spec did for `for`.
- **Pipeline-in-holes** is a real gap vs. the old grammar's capability,
  not just an unimplemented nicety (used in the wild per the old
  `holes_attrs.txt` corpus). Explicitly tracked above rather than assumed
  to be free — needs its own scoping decision (2c or dedicated) before
  2e's corpus port can claim parity.
- **`text`'s negated-class token** (`/[^<{]+/`) will likely need to
  narrow further once `raw_element`/attributes/holes-in-attributes land
  (e.g. does text need to stop at other characters for error-recovery,
  the way the old grammar's `/[^<{}>]+/` also stopped at bare `}`/`>`?)
  — not addressed here; revisit if a later sub-phase's prototyping turns
  up a real case, don't preemptively narrow it without evidence.
