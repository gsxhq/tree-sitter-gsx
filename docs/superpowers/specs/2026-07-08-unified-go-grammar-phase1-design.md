# Unified Go+gsx Grammar — Phase 1: Architecture Skeleton

> **For agentic workers:** this is a design spec, not a plan. Implementation
> follows superpowers:writing-plans → superpowers:subagent-driven-development
> once this spec is approved.

**Goal:** Replace tree-sitter-gsx's "Go as opaque blob + tree-sitter-go
injection" model with a **unified grammar** — gsx as a syntactic superset of
Go, the way `tree-sitter-tsx` extends `tree-sitter-javascript` — so that an
element/fragment/`f`-literal in a Go **value** position parses as one
coherent tree with zero injected-grammar errors. This spec covers **Phase 1
only**: prove the composition mechanics and the core disambiguation on a
from-scratch grammar skeleton, with no gsx-specific surface syntax
(attributes, `{ }` holes, `component` declarations) yet.

**Architecture:** `tree-sitter-gsx`'s `grammar.js` takes the real
`tree-sitter-go` npm package as a **devDependency** and calls tree-sitter's
native `grammar(base, overrides)` composition API to layer `element` and
`fragment` on top of Go's `_expression` rule, inheriting everything else
from Go unchanged. No Go source is copied into this repo.

**Tech stack:** `tree-sitter-cli` (already a devDependency), `tree-sitter-go`
(new devDependency), Node.js (grammar.js authoring/generation only — no
runtime dependency for consumers of the compiled parser).

## Global Constraints

- No source from `tree-sitter-go` is copied or hand-patched into this repo.
  It is required directly from `node_modules` at grammar-generation time
  (`require('tree-sitter-go/grammar.js')`); the generated `src/parser.c` is
  fully self-contained and has no runtime dependency on it.
- `tree-sitter-go` version is pinned exactly in `package.json` (no `^`/`~`
  range) so upstream drift is an explicit, reviewed bump, not a silent
  surprise on `npm install`.
- Phase 1 does not touch `component_declaration`, attributes, `{ }`
  interpolation holes, `f`/`js`/`css` literals, or the current
  `go_chunk`/`go_text`/blob-boundary scanner machinery. Those are Phase 2/3.
  Phase 1's `source_file` is Go's own, **inherited unmodified** from the
  base grammar — this spec proves elements work as native Go expressions
  inside real `.go`-shaped source, not `.gsx` source.
- Work happens on a new branch/worktree off `tree-sitter-gsx` `main`
  (`superpowers:using-git-worktrees`) and does **not** merge to `main` until
  Phase 2/3 reach full feature parity with the shipped grammar. No
  half-finished grammar ships.
- Every new syntax rule ships `test/corpus/*.txt` coverage in tree-sitter's
  native corpus format (this repo's existing testing convention), covering
  the happy path and the adjacent-syntax regressions it could be confused
  with.

---

## Background: why the current model breaks

`tree-sitter-gsx` treats Go as an opaque string and re-highlights it by
**injecting** `tree-sitter-go` per `go_text` run (`queries/injections.scm`).
This works everywhere except when an element/fragment/`f`-literal sits in a
Go **value** position (`var x = <Icon/>`, `return <div/>`, `f(<a/>)`): to
highlight the element, the gsx grammar must split the surrounding Go text
around it, and injection requires each injected region to be
*independently* valid Go. The split fragments (a bare `var x = `, an
orphaned `}`) aren't independently valid, so the injected Go parser emits an
`ERROR` node on them. This is cosmetic (no LSP squiggle; at worst a token
goes uncolored) but structurally wrong, and **no injection technique
escapes it** — `injection.combined` would need to scope the recombination to
a single Go function/block, which requires the grammar to understand Go
block structure, which is exactly what the blob model avoids. Full
background and the decision to pursue the unified-grammar approach (over
staying with injection, or an embed-in-JS-style model) is recorded in
`gsx`'s `docs/ROADMAP.md` under "Tracked debts / deferrals" (entry added
2026-07-08).

**Confirmed by two throwaway prototypes** (not part of this repo, built in a
scratch directory) before this spec was written. The first isolated the
disambiguation question with a hand-copied `tree-sitter-go@0.25.0`
`grammar.js` (a six-line inline edit — `$.element` added to `_expression`'s
choice list, plus a minimal `element` rule): clean `tree-sitter generate`
(**zero declared conflicts**) and **zero `ERROR` nodes** for:
- `var x = <Icon/>` (element in a var-decl value)
- `return a < b` (comparison — untouched)
- `return <-ch` (channel receive — untouched)
- `wrap(<Icon/>)` (element as a call argument)
- `func render() gsx.Node { return <div>inline JSX</div> }` — **the exact
  case that motivated this investigation** — parses as one coherent
  `element` node nested in `return_statement`, no split, no injected-Go
  error.

The second prototype re-verified all five cases (plus fragments — see
below) against the *actual composition mechanism* this spec adopts
(`require('tree-sitter-go/grammar.js')` + `grammar(base, overrides)`, no
copied source) using the real npm package, not a hand-copied stand-in —
see "Decision" below.

The reason there's no ambiguity: `element` only ever starts at an
**expression-prefix** position (inside `_expression`'s choice list), while
`<` as comparison/channel-receive only ever appears **after** a completed
left operand (infix, in `binary_expression`/`unary_expression`) or as a
distinct `<-` token. These are different grammar positions, so tree-sitter's
LR automaton never forks a stack over it — structurally easier than TSX's
`<T>`-cast-vs-`<div>`-JSX ambiguity, which forks at the *same* position and
needs real disambiguation.

## Decision: composition, not a hand-copied fork

Two ways to build on `tree-sitter-go`:

**A. Hand-patch a vendored copy.** Copy `grammar.js` into this repo, edit it
in place, manually re-diff against upstream on sync. Simple, but duplicates
~1000 lines and turns every upstream sync into a manual merge.

**B. Compose via `grammar(base, overrides)` (chosen).** tree-sitter's DSL
supports passing an existing grammar object as the first argument to
`grammar()`, inheriting all its rules and letting the second argument
override or add specific ones. `tree-sitter-go` publishes to npm with
`grammar.js` included in the tarball (verified: `npm pack
tree-sitter-go@0.25.0` contains `package/grammar.js`), and it is
MIT-licensed (compatible with this project).

**Verified against the real package** (not just a synthetic stand-in): the
value returned by `require('tree-sitter-go/grammar.js')` after evaluation
inside tree-sitter's `grammar()` runtime is an **opaque wrapper**
(`{ grammar: <internal> }`) — its `.rules` are not directly readable by our
code. `grammar()` itself knows how to unwrap this shape when given as the
*first* argument, but we can't programmatically spread or introspect a
base rule's existing alternatives from JS. So extending a `choice()`-based
rule like `_expression` means **redeclaring that one rule's list of
alternative names** (not their bodies — `binary_expression`,
`call_expression`, etc. all stay fully inherited and untouched, only the
top-level `_expression` choice() is restated) plus the new
`element`/`fragment` alternatives:

```js
// grammar.js
const goGrammar = require('tree-sitter-go/grammar.js');

module.exports = grammar(goGrammar, {
  name: 'gsx',

  rules: {
    // Redeclares Go's _expression alternative list (rule NAMES only —
    // each rule's own body stays inherited/untouched from goGrammar)
    // plus element/fragment. Verify this list against tree-sitter-go's
    // _expression rule on every upstream version bump.
    _expression: $ => choice(
      $.unary_expression,
      $.binary_expression,
      $.selector_expression,
      $.index_expression,
      $.slice_expression,
      $.call_expression,
      $.type_assertion_expression,
      $.type_conversion_expression,
      $.type_instantiation_expression,
      $.identifier,
      alias(choice('new', 'make'), $.identifier),
      $.composite_literal,
      $.func_literal,
      $._string_literal,
      $.int_literal,
      $.float_literal,
      $.imaginary_literal,
      $.rune_literal,
      $.nil,
      $.true,
      $.false,
      $.iota,
      $.parenthesized_expression,
      $.element,
      $.fragment,
    ),

    element: $ => choice(
      seq('<', field('name', $.identifier), '/>'),
      seq(
        '<', field('open_name', $.identifier), '>',
        optional(field('body', $.element_text)),
        '</', field('close_name', $.identifier), '>',
      ),
    ),

    // '<>'/'</>' as single atomic tokens (not seq('<', '>')) — matters:
    // a naive two-literal seq lets the parser fork into element's
    // '<' + identifier path first and error out on '>' instead of
    // choosing fragment. Caught by testing, not assumed.
    fragment: $ => seq(
      token(seq('<', '>')),
      optional(field('body', $.element_text)),
      token(seq('<', '/', '>')),
    ),

    element_text: $ => token(prec(-1, /[^<]+/)),
  },
});
```

This exact shape (including the full `_expression` alternative list and the
atomic-token fragment fix) was generated and built against the real,
npm-extracted `tree-sitter-go@0.25.0` package (not a synthetic stand-in)
and re-ran all five earlier prototype cases plus two fragment cases
(`<>fragment text</>`, `<></>`) with zero `ERROR` nodes, including the
motivating case: `func render() gsx.Node { return <div>inline JSX</div> }`
parses as one clean `element` node nested in `return_statement`.
**The naive `seq('<', '>', ...)` fragment rule (two separate literals) does
not work** — it produced 2-3 `ERROR` nodes because the parser forked into
`element`'s `'<' + identifier` path and failed on the following `>` instead
of choosing `fragment`. The atomic-token form above (`token(seq('<',
'>'))`, forcing `<>` to lex as one token distinct from `element`'s `<`)
fixes it. This is exactly the kind of thing this spec's empirical
verification step exists to catch before it becomes Task 1's problem.

**Upstream-sync cost, precisely stated:** bump the pinned version, run
`tree-sitter generate` + `tree-sitter test`. The one thing that needs a
manual look on each bump is whether upstream's `_expression` choice list
itself gained or dropped an alternative (rare — it's Go's top-level
expression-kind enumeration, not a frequently-changed rule) — everything
else (every other rule's actual grammar, the scanner-less ASI handling,
etc.) inherits automatically with no diffing required. Materially smaller
than hand-diffing a ~1000-line fork.

## Phase 1 scope

**In scope:**
- `tree-sitter-go` added as a pinned devDependency.
- `element` and `fragment` rules: self-closing and open/close forms, with
  a **plain-text-only** body (no attributes, no `{ }` holes).
- `element`/`fragment` added as `_expression` alternatives.
- Regression coverage proving `<`/`<=` (comparison) and `<-`/`<<` (channel
  receive/shift) are unaffected.
- A new `test/corpus/` file (or files) in this repo, using tree-sitter's
  native corpus format, covering element/fragment as expression values in:
  var-decl, return, call-argument, composite-literal-field, struct-field,
  and assignment positions.
- Confirming the whole thing works from a **fresh clone** — `npm install`,
  `npm run generate`, `npm test` — not just in the throwaway scratch
  prototype.

**Explicitly out of scope (deferred):**
- `component_declaration` and any gsx-specific top-level syntax.
- Attributes on elements.
- `{ }` interpolation holes (these become real Go `_expression`s once
  wired up in Phase 2 — expected to be *simpler* than today, since they no
  longer need a separate hole grammar, but that wiring is not Phase 1).
- `f`/`js`/`css` literals.
- Porting/retiring the current scanner's blob-boundary tokens
  (`go_text`, `go_cond_text`, `go_interp_text`, `go_spread_text`,
  `go_top_text`, `style_go_text`) — expected to become fully unnecessary
  once the unified grammar replaces the blob model, but that retirement
  happens when Phase 3 cuts the new grammar over, not in Phase 1.
- Rewriting `queries/highlights.scm` / `queries/injections.scm`.
- Any change to the currently-shipped `grammar.js`/`scanner.c` on `main`.

## Scanner

Phase 1 is expected to need **no external scanner at all** — no
`externals:` field, no `scanner.c`. Every current external token exists to
answer "where does this Go-blob run end," which is meaningless once Go is
native (real Go grammar rules define their own boundaries). Plain
element-text content doesn't need scanning either: the prototype's
`element_text: $ => token(prec(-1, /[^<]+/))` (a plain regex token, no
external scanner) worked with zero errors. If Phase 1 implementation
surfaces a real need for external scanning (unexpected LR conflict that
only a scanner can resolve), that's a plan-time discovery to bring back for
a design decision — not assumed here.

## Repo & workflow

- New git worktree + branch off `tree-sitter-gsx` `main` (name suggestion:
  `unified-go-grammar`), created via `superpowers:using-git-worktrees`.
- Stays on the branch — **not merged to `main`** — until Phase 2 (full
  feature parity: attributes, holes, `f`/`js`/`css` literals, component
  declarations, full corpus port) and Phase 3 (query rewrite + editor
  rollout, cutover) both land. Each phase gets its own
  brainstorm → spec → plan cycle; this spec only commits to Phase 1.
- The existing `grammar.js`/`scanner.c`/`queries/*.scm` on `main` are
  untouched by Phase 1 — the shipped grammar keeps working throughout.

## Testing strategy

- New `test/corpus/*.txt` file(s) (this repo's existing format — see
  `test/corpus/holes_attrs.txt` and `toplevel.txt` for house style),
  scoped to this phase's surface: element/fragment as expression values,
  plus the comparison/channel-op regression set.
- Not a port of the existing `.gsx` corpus — every existing fixture uses
  attributes, which don't exist in this phase's grammar yet. That port is
  Phase 2's job, once attributes land and a real feature-parity comparison
  against the shipped grammar is meaningful.
- `tree-sitter generate` must produce zero unresolved-conflict warnings.
- `tree-sitter test` (the corpus) must pass.
- Verified from a fresh clone (`npm install && npm run generate && npm
  test`), not just the interactively-built scratch prototype — confirms
  the pinned dependency actually resolves and installs cleanly for a new
  contributor/CI, which the scratch prototype (built by hand-copying files)
  did not exercise.

## Done criteria

Phase 1 is complete when:
1. `tree-sitter-go` is a pinned devDependency, required (not copied) from
   `grammar.js`.
2. `element`/`fragment` parse cleanly as `_expression` alternatives
   (self-closing and open/close-with-plain-text forms) in var-decl, return,
   call-argument, composite-literal-field, struct-field, and assignment
   positions, with zero `ERROR` nodes.
3. The comparison/channel-op regression corpus passes (`<`, `<=`, `<-`,
   `<<` all parse exactly as they do in unmodified `tree-sitter-go`).
4. `tree-sitter generate` reports no unresolved conflicts.
5. All of the above is verified from a fresh clone, not only in the
   scratch prototype.
6. A short written note (in the branch, e.g. a `NOTES.md` or PR
   description) records whether any external scanner turned out to be
   necessary (expected: no, per the verified design above).

Phase 1 does **not** replace the shipped grammar, does not need a review
gate beyond the normal per-task review in subagent-driven-development, and
does not require sibling-repo (`vscode-gsx`, `gsxhq.github.io`) changes —
none of them consume tree-sitter-gsx's raw parse tree (confirmed: the
playground's `gsx.wasm` is the unrelated Go-compiled codegen binary, and
CodeMirror highlighting is a hand-written tokenizer, not tree-sitter WASM).

## Risks / open questions

- **Upstream `tree-sitter-go` version choice** — pin `0.25.0` (latest at
  time of writing, matches the version already vendored in this machine's
  Go module cache, so behavior is directly comparable to what `gopls`/`go
  build` see; also the exact version this spec's real-package verification
  ran against).
- **Whether tree-sitter's single-external-scanner-per-grammar limit ever
  becomes a real constraint** — Phase 1 needs zero scanners, so this is
  deferred entirely to Phase 2 (where `embedded_text`/`embedded_text_dq`
  and `raw_text`-equivalent scanning will need to be designed against
  whatever grammar shape Phase 1 lands on).
- **`_expression`'s alternative list must be eyeballed on every upstream
  version bump** — the redeclaration approach means a new expression kind
  added upstream needs a matching addition here, or it silently becomes
  unparseable in gsx source. Low-frequency rule to watch, not a blocker.
