# Unified Go+gsx Grammar — Phase 2d: `component` Declarations

> **For agentic workers:** this is a design spec, not a plan. Implementation
> follows superpowers:writing-plans → superpowers:subagent-driven-development
> once this spec is approved. Continues on the same `unified-go-grammar`
> branch as Phases 1, 2a, 2b, and 2c.

**Goal:** Add gsx's `component` declaration — the one top-level construct
that is genuinely gsx-specific rather than Go — with function-style
parameters, optional method receiver, optional generics, and a markup
child body. This is the last grammar sub-phase before 2e (full corpus
port); after it, real `.gsx` files (which all start with `component …`)
parse for the first time on this branch.

**Architecture:** `component_declaration` is added to a redeclared
`_top_level_declaration` choice list (same redeclaration pattern Phase 1
used for `_expression`). Its receiver, parameters, and type parameters
**reuse Go's own `parameter_list`/`type_parameter_list` rules verbatim** —
no custom regex-blob capture (`_paren_go`/`_bracket_go`) like the old
grammar needed, because Go is native now. Its body is `{ repeat($._child)
}` — the exact same `_child` grammar 2a built for element/fragment bodies,
so component bodies get text/nested-markup/holes/control-flow for free.

**Tech stack:** same as Phases 1/2a/2b/2c (no new scanner — this phase
adds no external tokens; 2c's `src/scanner.c` is untouched).

## Global Constraints

- Builds on 2a's `_child`, Phase 1's `_top_level_declaration` redeclaration
  pattern, and Go's native `parameter_list`/`type_parameter_list`.
- `doctype`, `html_comment`, and `raw_element` (`<script>`/`<style>`
  raw-text bodies) remain **out of scope** — deferred (see below). They
  are independent child-content types, not part of `component`'s own
  grammar.
- `content_comment` (still deferred from 2a/2b) remains out of scope.
- No external scanner is added — `component`'s pieces are all either Go's
  native rules or 2a's existing `_child`. (`raw_element`, if it were in
  scope, would need one — another reason it's deferred.)
- Every new rule ships `test/corpus/*.txt` coverage.

---

## Decision: `component_declaration` only; defer doctype/html_comment/raw_element

The old grammar's `_child`/`_node` choice included `doctype`,
`html_comment`, and `raw_element` alongside elements/holes/control-flow.
2a deliberately scoped those out and this phase keeps them out:

- `doctype` (`<!DOCTYPE html>`) and `html_comment` (`<!-- … -->`) are
  small, scanner-free regex additions to `_child`, unrelated to
  `component`'s own grammar.
- `raw_element` (`<script>`/`<style>` bodies as raw text, not parsed as
  markup) needs its own external-scanner function (`scan_raw_text` in the
  old scanner — stops at the matching close tag, not at `<`/`{`), a
  distinct piece of work from anything `component` needs.

Bundling three independent child-content types into an already-substantial
`component` phase is scope creep. 2e (the full corpus port) is the natural
place to surface exactly which of these are load-bearing across real `.gsx`
files and scope them — as one focused follow-up or folded into 2e — rather
than guessing now. Tracked explicitly, not silently dropped.

## Prototype findings (verified, not assumed)

Extended the Phase 2c scratch grammar in a throwaway scratch directory.
All cases produced **zero `ERROR` nodes** and `tree-sitter generate`
reported **zero unresolved conflicts**:

1. `component Foo() { <div>hello</div> }` — simplest form, element body.
2. `component Card(title string, count int) { … }` — typed parameters,
   reusing Go's `parameter_list` (each param a real
   `parameter_declaration` with `name:`/`type:` fields — full structure,
   not an opaque blob).
3. `component (p Page) Content() { … }` — method receiver, reusing Go's
   `parameter_list` in receiver position (exactly how Go's own
   `method_declaration` does it). Confirmed by tree inspection: `receiver:
   (parameter_list (parameter_declaration name: … type: …))`.
4. `component List[T any](items []T) { … }` — generics, reusing Go's
   `type_parameter_list` (`[T any]` → real `type_parameter_declaration`).
5. `component A() {} component B() {}` — two adjacent components (tight,
   no blank line).
6. `var mycomponent = 1` followed by `component X() {}` — the identifier
   `mycomponent` is NOT mis-lexed as the `component` keyword; parses as a
   normal `var_declaration`, then a separate `component_declaration`. (The
   old grammar had an explicit regression test for exactly this.)
7. `func helper() int { return 1 }` alongside a `component` — a real Go
   `function_declaration` and a `component_declaration` coexist at top
   level (both are `_top_level_declaration` alternatives).
8. `component Empty() {}` — empty body (`repeat($._child)` matches zero).
9. `var icon = <Icon/>` (Phase 1's top-level element value) alongside a
   `component` — confirmed they coexist: the var-decl parses as a
   statement with an element value, the component as its own
   declaration, no conflict from redeclaring `_top_level_declaration`.

The full combined suite passes together — 55 cases (the 47 prior: Phase
1's 13 + 2a's 12 + 2b's 11 + 2c's 11, plus this phase's 8). The four
prior phases' corpus files pass **unchanged** — `component_declaration`
is purely additive
(it's a new `_top_level_declaration` alternative and a new rule; nothing
existing changes shape).

## Grammar (verified shape)

```js
// grammar.js — additions on top of Phase 2c's grammar.js.

// Redeclares Go's own top-level-declaration choice list (rule NAMES only)
// plus component_declaration — same redeclaration pattern as _expression
// in Phase 1. Verify this list against tree-sitter-go's
// _top_level_declaration on every upstream version bump (same maintenance
// note as _expression's list).
_top_level_declaration: $ => choice(
  $.package_clause,
  $.function_declaration,
  $.method_declaration,
  $.import_declaration,
  $.component_declaration,
),

// Reuses Go's own parameter_list (receiver + parameters) and
// type_parameter_list (generics) verbatim — no custom regex-blob capture
// needed now that Go is native. Body is 2a's _child grammar.
component_declaration: $ => seq(
  'component',
  optional(field('receiver', $.parameter_list)),
  field('name', $.identifier),
  optional(field('type_parameters', $.type_parameter_list)),
  field('parameters', $.parameter_list),
  field('body', $.component_body),
),

component_body: $ => seq('{', repeat($._child), '}'),
```

Notes:
- `component_body` is its own named node (not reusing `element`'s inline
  `repeat($._child)`) so a consumer can distinguish a component's body
  from an element's children by node type — matches the old grammar's
  separate `body` node. Its *content* is identical to element children
  (`_child`), so no new child-content grammar is introduced.
- The `receiver`/`type_parameters`/`parameters`/`name`/`body` field names
  match the old grammar's `component_declaration` field names, so any
  existing consumer expectations (queries, the gen-side FileSymbols
  extractor if it ever reads this tree) carry over.

## Scope

**In scope:**
- `component_declaration` added to a redeclared `_top_level_declaration`.
- `component_body` (`{ repeat($._child) }`).
- Receiver (`(p T)`), typed parameters, and generics — all via Go's own
  `parameter_list`/`type_parameter_list`.
- `test/corpus/` coverage for all 8+ verified cases.

**Explicitly out of scope (deferred):**
- `doctype`, `html_comment` — small `_child` additions, deferred to 2e or
  a dedicated follow-up.
- `raw_element` (`<script>`/`<style>` raw-text bodies) — needs its own
  external scanner (`scan_raw_text`), deferred to 2e or a dedicated
  follow-up.
- `content_comment` — still deferred from 2a/2b.
- Anything not `component`-declaration-shaped.

## Testing strategy

- New `test/corpus/*.txt` coverage for all verified cases (controller's
  call at plan time on filename), including the two regression-flavored
  cases the old grammar itself tested (identifier-ending-in-`component`,
  and `component` coexisting with real Go declarations).
- Full existing 47-case suite must still pass — verified above to need
  zero regeneration (purely additive, like 2b/2c).
- `tree-sitter generate`: zero unresolved conflicts. `tree-sitter test`:
  clean exit, full corpus passing, no warnings.
- Verified from a fresh clone, same as prior phases.
- Given the recurring lesson that simple-ordering corpus coverage can
  hide bugs (2a's `text`-swallow, 2b's else-if gap), this phase's plan
  should include the tight-adjacency case (`component A() {} component
  B() {}` with no blank line) and the keyword-boundary case
  (`mycomponent`), not only the well-spaced happy path.

## Done criteria

1. `component_declaration` parses with a receiver, typed parameters,
   generics, and a `_child` body — each piece structured via Go's native
   rules (not an opaque blob), with zero `ERROR` nodes.
2. `component` coexists at top level with `package`/`import`/`func`/`var`
   declarations and Phase 1's top-level element values.
3. Full existing 47-case corpus still parses with zero `ERROR` nodes
   (regenerate only if a real diff is found — not assumed clean).
4. `tree-sitter generate`: zero unresolved conflicts. `tree-sitter test`:
   clean exit, no warnings.
5. Verified from a fresh clone.
6. NOTES.md gets a "Phase 2d notes" section recording: the Go-native
   `parameter_list`/`type_parameter_list` reuse (the big simplification
   vs. the old regex-blob), the `_top_level_declaration` redeclaration
   (and its upstream-bump maintenance note, same as `_expression`'s), and
   the doctype/html_comment/raw_element deferral with reasons.

## Risks / open questions

- **`_top_level_declaration` redeclaration adds a second list to eyeball
  on upstream `tree-sitter-go` bumps** (alongside `_expression`'s list
  from Phase 1). Low-frequency — both are Go's own top-level enumerations,
  rarely changed — but worth the same NOTES.md maintenance note
  `_expression` already carries.
- **2e will need doctype/html_comment/raw_element before it can claim full
  corpus parity** — flagged here so 2e's own scoping accounts for them
  (especially `raw_element`, the one that needs a scanner) rather than
  discovering them mid-port.
- **`component`'s body uses `component_body` (a distinct node) rather than
  reusing `element`'s inline children** — a deliberate choice for
  consumer clarity (matches the old grammar's separate `body` node), not
  an accident; if a future consumer would rather they be the same node
  type, that's a cheap change, but the default here favors
  distinguishability.
