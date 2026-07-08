# Unified Go+gsx Grammar — Phase 2b: Attributes

> **For agentic workers:** this is a design spec, not a plan. Implementation
> follows superpowers:writing-plans → superpowers:subagent-driven-development
> once this spec is approved. Continues on the same `unified-go-grammar`
> branch as Phases 1 and 2a.

**Goal:** Give `element` a real attribute list — static (`class="x"`),
expression (`data={expr}`), boolean (`disabled`), spread (`{attrs...}`),
and conditional (`{if cond { class="a" } else { class="b" }}`) attributes —
where Phase 1/2a's `element` has none at all. Third of five Phase 2
sub-phases (2a children → **2b attributes** → 2c `f`/`js`/`css` literals →
2d `component` declarations → 2e full corpus port).

**Architecture:** `element`'s self-closing and open-tag forms gain
`repeat($.attribute)`. `attribute` is a choice of `static_attribute`,
`expr_attribute`, `bool_attribute`, `spread_attribute`, and
`conditional_attribute`. `expr_attribute`'s value reuses 2a's `hole` rule
directly (`name={ hole }` — no new hole grammar). `static_attribute`'s
value reuses Go's own `_string_literal` (dropping the old grammar's custom
single-quote-supporting `quoted_string` rule — not valid Go syntax, and
confirmed unused in the legacy corpus/examples). `conditional_attribute`
reuses the same condition-clause approach as 2a's `control_flow`
(`choice($._expression, $.for_clause, $.range_clause)`), applied to a
repeated attribute list instead of a repeated child list.

**Tech stack:** same as Phases 1/2a.

## Global Constraints

- Builds on 2a's `hole`/`_expression`/`for_clause`/`range_clause` — no
  change to child-content grammar, only to what `element`'s tags can carry.
- `f`/`js`/`css` literal attribute values (the old grammar's
  `embedded_attribute`) are **out of scope** — 2c's job.
- `css_composed_value` and `value_control_flow` (if/switch as an
  attribute's *value*, e.g. `class={ if cond { "a" } else { "b" } }`) are
  **out of scope** — both depend on 2c machinery or are their own
  follow-up; `conditional_attribute` (if/switch wrapping whole *attributes*,
  not a value) is in scope and is a different construct.
- `content_comment` (inline comments among attributes) is **out of
  scope**, deferred alongside its child-position form from 2a — one rule,
  implemented once in a later sub-phase, not split across two.
- `component` declarations remain out of scope (2d) — this phase's tests
  stay `.go`-shaped, same as 2a.
- Every new rule ships `test/corpus/*.txt` coverage.
- No external scanner unless empirically proven necessary.

---

## Decisions (both user-confirmed)

**1. Attribute value quoting: reuse Go's `_string_literal`, drop
single-quote support.** The old grammar's `static_attribute` used a custom
`quoted_string: choice(seq('"',...,'"'), seq("'",...,"'"), seq('`',...,'`'))`
— three delimiters, including single-quote, which isn't valid Go syntax on
its own. Confirmed via `grep` across the full legacy corpus and all 13
example `.gsx` files: **zero** real usages of single-quoted attribute
values. Decision: `static_attribute`'s value is Go's own `$._string_literal`
(`interpreted_string_literal` + `raw_string_literal` — double-quote and
backtick, matching `_expression`'s existing string-literal handling from
Phase 1). Consistent with the unified-grammar theme of reusing real Go
rules instead of custom ones wherever the old custom rule wasn't carrying
its weight.

**2. `content_comment` deferred, not split.** The old grammar's `attribute`
choice list includes `content_comment` (`<div /* note */ class="x">`) —
the *same* rule 2a already deferred for child position. Rather than
implement it once for attributes now and again for children later,
implement it once, in whichever later sub-phase takes on comments
generally. Real `.gsx` files with inline attribute comments don't parse
in 2b either — an explicit, tracked gap, not silently dropped.

## Prototype findings (verified, not assumed)

Extended the Phase 2a scratch grammar (same `tree-sitter-go@0.25.0`
composition, already including the `}`-boundary fix) with the attribute
rules below, in a throwaway scratch directory. All cases produced **zero
`ERROR` nodes** and `tree-sitter generate` reported **zero unresolved
conflicts**:

1. `<div class="x" disabled data={y} {attrs...}/>` — all four non-conditional
   attribute kinds on one tag, each correctly typed in the tree
   (`static_attribute`/`bool_attribute`/`expr_attribute`/`spread_attribute`).
2. `<div class="x">child</div>` — attributes on an open-tag form (not just
   self-closing).
3. `<div {if cond { class="active" } else { class="inactive" }}>x</div>` —
   `conditional_attribute` with `if`/`else`, correctly nesting
   `static_attribute`s inside each branch.
4. `<Icon/>` — Phase 1's bare, attribute-free form, confirmed unaffected.
5. `` <div class=`raw string`/> `` — backtick (raw) string attribute value.
6. `<div data-x="a" aria:label="b" @click={fn}/>` — `attribute_name`'s
   extended character set (`-`, `:`, `@`) unaffected.
7. `<div class="x"/>` — no whitespace before `/>`, confirmed no
   whitespace-sensitivity issue.
8. `<div id="x" {if a { class="b" }} disabled/>` — conditional attribute
   mixed with static/bool attributes on the same tag, `if` with no `else`.
9. `<div data={fn(args...)}/>` — **the key disambiguation check**: a
   variadic Go call (`fn(args...)`) inside an `expr_attribute`'s hole
   correctly parses as `hole(call_expression(argument_list(variadic_argument)))`,
   *not* confused with `spread_attribute`'s own top-level `{ expr... }`
   shape, even though both involve `...`. Confirmed by inspecting the
   actual tree, not just the absence of an `ERROR`.
10. `<div data={fn(a, b)} {spreadme...}/>` — `expr_attribute` and
    `spread_attribute` on the same tag, back to back.

The full existing 25-case corpus (Phase 1's 13 + Phase 2a's 12) was also
re-run against this attribute-extended grammar and passed **unchanged** —
attributes are purely additive to `element`'s tag syntax (`repeat()` was
implicitly zero before), unlike 2a's transition, which needed 3 expected
trees regenerated.

## Grammar (verified shape)

```js
// Extends Phase 2a's grammar.js — only the changed/added rules shown.

element: $ => choice(
  seq('<', field('name', $.identifier), repeat($.attribute), '/>'),
  seq(
    '<', field('open_name', $.identifier), repeat($.attribute), '>',
    repeat($._child),
    '</', field('close_name', $.identifier), '>',
  ),
),

attribute: $ => choice(
  $.static_attribute,
  $.expr_attribute,
  $.bool_attribute,
  $.spread_attribute,
  $.conditional_attribute,
),

attribute_name: $ => /[A-Za-z_@:][A-Za-z0-9_@:.\-]*/,

static_attribute: $ => seq(field('name', $.attribute_name), '=', field('value', $._string_literal)),

// Reuses 2a's `hole` rule directly for the value — name={ expr }.
expr_attribute: $ => prec(-1, seq(field('name', $.attribute_name), '=', field('value', $.hole))),

bool_attribute: $ => prec(-1, field('name', $.attribute_name)),

spread_attribute: $ => seq('{', field('value', $._expression), '...', '}'),

// Condition shape mirrors 2a's control_flow (reuses Go's own for_clause/
// range_clause, not reimplemented), applied to a repeated ATTRIBUTE list
// instead of a repeated CHILD list.
conditional_attribute: $ => seq(
  '{',
  alias(choice('if', 'for'), $.keyword),
  field('condition', choice($._expression, $.for_clause, $.range_clause)),
  '{', repeat($.attribute), '}',
  optional(seq(
    alias('else', $.keyword),
    '{', repeat($.attribute), '}',
  )),
  '}',
),
```

Note: the old grammar's `conditional_attribute` allowed `if`/`for` (not
`switch`) — carried forward unchanged here; `switch`-wrapping-attributes
was never a real construct in the old grammar either (only `control_flow`,
the children-position form, included `switch`).

## Scope

**In scope:**
- `element`'s self-closing and open-tag forms gain `repeat($.attribute)`.
- `static_attribute`, `expr_attribute` (reusing `hole`), `bool_attribute`,
  `spread_attribute`, `conditional_attribute` (`if`/`for`+optional `else`,
  reusing the `for_clause`/`range_clause` condition shape from 2a).
- `attribute_name`.
- `test/corpus/` coverage for all 10 verified cases above.

**Explicitly out of scope (deferred):**
- `f`/`js`/`css` literal attribute values (`embedded_attribute`) — 2c.
- `css_composed_value`, `value_control_flow` (if/switch as an attribute
  *value*) — 2c or a dedicated follow-up.
- `content_comment` (inline attribute comments) — deferred alongside its
  child-position form from 2a, one rule for both positions later.
- `component` declarations — 2d.
- The `|>` pipeline operator inside holes (still deferred from 2a — this
  phase's `expr_attribute` inherits that same limitation since it reuses
  `hole` as-is).

## Testing strategy

- New `test/corpus/*.txt` coverage (new file or an addition to
  `phase2a_children.txt`'s directory — controller's call at plan time) for
  all 10 verified cases.
- Full existing 25-case suite must still pass — verified above to need
  zero regeneration (purely additive), unlike 2a's 3-case regeneration.
- `tree-sitter generate`: zero unresolved conflicts. `tree-sitter test`:
  clean exit, full corpus passing, no warnings.
- Verified from a fresh clone, same as Phases 1/2a.
- Given 2a's own final review found a real gap the corpus's
  element-terminated bias hid (`text` swallowing a control-flow block's
  closing `}`), this phase's plan should deliberately include at least one
  corpus case per attribute kind in a **non-trivial position** (e.g. a
  conditional attribute as the *last* attribute before `/>`, not only ever
  first) rather than only the straightforward orderings prototyped above.

## Done criteria

1. `element`'s attribute list supports all five kinds with zero `ERROR`
   nodes on the corpus, including the variadic-call-vs-spread
   disambiguation case.
2. Full existing 25-case corpus still passes (regenerate only if a real
   diff is found — not assumed clean without checking, same discipline as
   2a's Task 1 Step 3).
3. `tree-sitter generate`: zero unresolved conflicts. `tree-sitter test`:
   clean exit, no warnings.
4. Verified from a fresh clone.
5. NOTES.md gets a "Phase 2b notes" section recording: the
   quoting-simplification decision (with the corpus/example grep result
   that justified it), the `content_comment` deferral, and the
   variadic-call-vs-spread disambiguation finding.

## Risks / open questions

- **`conditional_attribute`'s `if`/`for`-only (no `switch`) scope carries
  forward from the old grammar unchanged** — not re-litigated here, since
  the old grammar never supported attribute-wrapping `switch` either. If a
  real need surfaces later, that's a fresh, scoped decision, not an
  oversight.
- **Same `}`-boundary class of risk 2a hit could recur inside
  `conditional_attribute`'s attribute-list block** (`{ if cond { class="a"
  } }` — does a lone bare identifier attribute name right before the
  block's closing `}` ever get mis-consumed the way 2a's `text` did?)
  Attribute names are a tight regex (`/[A-Za-z_@:][A-Za-z0-9_@:.\-]*/`,
  no `}` in its character class), so this specific failure mode shouldn't
  recur, but the *general* lesson from 2a — element-terminated/
  simple-ordering corpus bias can hide boundary bugs — is exactly why
  Testing Strategy above calls for non-trivial-position coverage, not
  just "it worked in the prototype."
- **Reusing `hole` unchanged for `expr_attribute`** means attribute
  expression values inherit every one of `hole`'s current limitations
  (no pipeline, single-expression only) — intentional (one rule, one set
  of limitations, one place to lift them later), not a new gap introduced
  by this phase.
