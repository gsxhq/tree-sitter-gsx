# Unified Go+gsx Grammar — Phase 2c Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add gsx's `f`/`js`/`css` interpolating literal syntax — as a Go
value (`f` only), an attribute value (all three), and inside plain holes
(`f` only, automatic via `_expression`) — where Phase 1/2a/2b have none at
all.

**Architecture:** `embedded_f_literal`/`embedded_js_literal`/
`embedded_css_literal` and `at_hole` (with `\|>` pipe-chain support) are
ported from the pre-existing shipped grammar largely unchanged. This is
the unified grammar's **first real external scanner**: a new, minimal
`src/scanner.c` containing only `scan_embedded_text`/
`scan_embedded_text_dq`, lifted near-verbatim from the pre-existing
shipped scanner.

**Tech Stack:** `tree-sitter-cli`, `tree-sitter-go` (already pinned
devDependency), Node.js, a C compiler.

## Global Constraints

- Continues on the `unified-go-grammar` branch (no new worktree/branch).
- `css_composed_value`, `value_control_flow`, and `component` declarations
  are **out of scope** — do not add them.
- `js`/`css` literals are attribute-context only — only `embedded_f_literal`
  joins `_expression`'s choice list.
- Pipe chains in *plain* `{ }` holes remain out of scope (2a/2b's existing
  deferral) — only `@{ }` gets pipe support in this phase.
- The new `src/scanner.c` is genuinely minimal — only `embedded_text`/
  `embedded_text_dq`. Do not port any other function from the pre-existing
  shipped scanner (its other functions are either obsolete or not yet
  needed).
- Every new rule ships `test/corpus/*.txt` coverage.
- Full design rationale: `docs/superpowers/specs/2026-07-08-unified-go-grammar-phase2c-literals-design.md`.

---

### Task 1: `f`/`js`/`css` literals, `at_hole` with pipe chains, first external scanner

**Files:**
- Modify: `grammar.js`
- Create: `src/scanner.c`
- Create: `test/corpus/phase2c_literals.txt`
- Modify: `NOTES.md`

**Interfaces:**
- Consumes: `_expression` (Phase 1), `hole` (2a, gets `embedded_f_literal`
  automatically — no change needed to `hole`'s own rule), `attribute`
  (2b, gains `embedded_attribute` as a new choice).
- Produces: `embedded_f_literal`/`embedded_js_literal`/
  `embedded_css_literal` (each with an `embedded_language` alias field —
  `f`/`js`/`css` — and delimiter-specific body via `embedded_text`/
  `embedded_text_dq`), `at_hole` (a real Go `_expression`, optionally
  followed by `repeat(seq('|>', $._expression))` pipe stages),
  `embedded_attribute` (`name:`/`value:` fields, value is one of the
  three literal types). Phase 2d will not touch these — 2c is this
  branch's only sub-phase that touches literal/hole grammar.

- [ ] **Step 1: Add the literal, hole, and attribute rules to `grammar.js`**

Add `externals` (currently absent — this is the first phase to need one)
right after the `module.exports = grammar(goGrammar, {` opening and
`name: 'gsx',` line:

```js
  externals: $ => [$.embedded_text, $.embedded_text_dq],
```

Find `_expression`'s choice list and add `$.embedded_f_literal` as the
last alternative (after `$.fragment`):

```js
      $.element,
      $.fragment,
      // js/css literals are attribute-context only, never standalone Go
      // values (matches the original f-literal design) — only f
      // qualifies as a bare _expression.
      $.embedded_f_literal,
    ),
```

Add these new rules (anywhere in `rules:`, e.g. right after `_expression`):

```js
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
```

Find the `attribute` rule (from Phase 2b) and add `$.embedded_attribute`
as the first alternative (matching the old grammar's own ordering):

```js
    attribute: $ => choice(
      $.embedded_attribute,
      $.static_attribute,
      $.expr_attribute,
      $.bool_attribute,
      $.spread_attribute,
      $.conditional_attribute,
    ),
```

- [ ] **Step 2: Create `src/scanner.c`**

This directory has no `scanner.c` yet (Phases 1/2a/2b needed none). Create
`src/scanner.c` with this exact content:

```c
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

The `tree_sitter_gsx_external_scanner_*` prefix matches this repo's real
grammar name (`gsx`, set in `grammar.js`'s `name:` field back in Phase 1)
— confirmed by reading the identical prefix in the pre-existing shipped
grammar's own (currently untouched, unreferenced) `src/scanner.c`. Do not
guess a different prefix.

- [ ] **Step 3: Generate and build**

```bash
npx tree-sitter generate
npx tree-sitter build
```

Expected: both succeed with no output. This is the first phase where
`build` actually compiles C code (`src/scanner.c`) — if it fails, check
for a missing C compiler before assuming the scanner code is wrong (the
code above was verified working in Task 1's spec-writing prototype).

- [ ] **Step 4: Write `test/corpus/phase2c_literals.txt`**

Create the file with this exact content:

```
==================
bare f-literal (backtick) as a Go value with a hole
==================

package main
func f() {
	var x = f`hi @{name}`
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (block
      (statement_list
        (var_declaration
          (var_spec
            name: (identifier)
            value: (expression_list
              (embedded_f_literal
                (embedded_language)
                (embedded_text)
                (at_hole
                  (identifier))))))))))

==================
bare f-literal (double-quote) as a Go value with a hole
==================

package main
func f() {
	var x = f"hi @{name}"
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (block
      (statement_list
        (var_declaration
          (var_spec
            name: (identifier)
            value: (expression_list
              (embedded_f_literal
                (embedded_language)
                (embedded_text_dq)
                (at_hole
                  (identifier))))))))))

==================
js literal as an attribute value
==================

package main
func f() {
	var x = <div class=js`track(@{count})`/>
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (block
      (statement_list
        (var_declaration
          (var_spec
            name: (identifier)
            value: (expression_list
              (element
                name: (identifier)
                (attribute
                  (embedded_attribute
                    name: (attribute_name)
                    value: (embedded_js_literal
                      (embedded_language)
                      (embedded_text)
                      (at_hole
                        (identifier))
                      (embedded_text))))))))))))

==================
css literal as an attribute value
==================

package main
func f() {
	var x = <div style=css`--n:@{count}`/>
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (block
      (statement_list
        (var_declaration
          (var_spec
            name: (identifier)
            value: (expression_list
              (element
                name: (identifier)
                (attribute
                  (embedded_attribute
                    name: (attribute_name)
                    value: (embedded_css_literal
                      (embedded_language)
                      (embedded_text)
                      (at_hole
                        (identifier)))))))))))))

==================
f-literal used inside a plain hole (via _expression, no special-casing)
==================

package main
func f() {
	var x = <div>{f`hi @{name}!`}</div>
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (block
      (statement_list
        (var_declaration
          (var_spec
            name: (identifier)
            value: (expression_list
              (element
                open_name: (identifier)
                (hole
                  (embedded_f_literal
                    (embedded_language)
                    (embedded_text)
                    (at_hole
                      (identifier))
                    (embedded_text)))
                close_name: (identifier)))))))))

==================
bare backtick attribute value stays a plain string, @{ } is literal text
==================

package main
func f() {
	var x = <div title=`literal @{not-a-hole}`/>
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (block
      (statement_list
        (var_declaration
          (var_spec
            name: (identifier)
            value: (expression_list
              (element
                name: (identifier)
                (attribute
                  (static_attribute
                    name: (attribute_name)
                    value: (raw_string_literal
                      (raw_string_literal_content))))))))))))

==================
js literal double-quote variant containing literal backticks
==================

package main
func f() {
	var x = <button @click=js"emit(`@{variant}`)">Quoted</button>
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (block
      (statement_list
        (var_declaration
          (var_spec
            name: (identifier)
            value: (expression_list
              (element
                open_name: (identifier)
                (attribute
                  (embedded_attribute
                    name: (attribute_name)
                    value: (embedded_js_literal
                      (embedded_language)
                      (embedded_text_dq)
                      (at_hole
                        (identifier))
                      (embedded_text_dq))))
                (text)
                close_name: (identifier)))))))))

==================
bare @ not followed by { stays part of the text run
==================

package main
func f() {
	var x = f`a @member b`
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (block
      (statement_list
        (var_declaration
          (var_spec
            name: (identifier)
            value: (expression_list
              (embedded_f_literal
                (embedded_language)
                (embedded_text)))))))))

==================
pipe chain inside an attribute-value f-literal's hole
==================

package main
func f() {
	var x = <span title=f`Item @{ id |> upper }`>y</span>
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (block
      (statement_list
        (var_declaration
          (var_spec
            name: (identifier)
            value: (expression_list
              (element
                open_name: (identifier)
                (attribute
                  (embedded_attribute
                    name: (attribute_name)
                    value: (embedded_f_literal
                      (embedded_language)
                      (embedded_text)
                      (at_hole
                        (identifier)
                        (identifier)))))
                (text)
                close_name: (identifier)))))))))

==================
two-stage pipe chain
==================

package main
func f() {
	var x = f`@{ id |> truncate(10) |> upper }`
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (block
      (statement_list
        (var_declaration
          (var_spec
            name: (identifier)
            value: (expression_list
              (embedded_f_literal
                (embedded_language)
                (at_hole
                  (identifier)
                  (call_expression
                    function: (identifier)
                    arguments: (argument_list
                      (int_literal)))
                  (identifier))))))))))

==================
regression: bitwise-or and logical-or operators stay untouched by the pipe token
==================

package main
func cmp(a int, b int) bool {
	return a | b
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list
      (parameter_declaration
        name: (identifier)
        type: (type_identifier))
      (parameter_declaration
        name: (identifier)
        type: (type_identifier)))
    result: (type_identifier)
    body: (block
      (statement_list
        (return_statement
          (expression_list
            (binary_expression
              left: (identifier)
              right: (identifier))))))))
```

This exact content (11 cases, including the bare-`@` scanner lookahead
check, the one-rule-no-exceptions bare-backtick regression, and the pipe
chains) was hand-written, run once to see genuine diffs, corrected via
`tree-sitter test --update --show-fields`, and re-verified to 11/11
passing against the real `tree-sitter-go@0.25.0` package with the real
compiled scanner before this plan was written.

- [ ] **Step 5: Run the new corpus and confirm 11/11 pass**

```bash
npx tree-sitter test --file-name phase2c_literals.txt
```

Expected: `Total parses: 11; successful parses: 11; failed parses: 0;
success percentage: 100.00%`.

- [ ] **Step 6: Run the full suite (Phase 1 + 2a + 2b + 2c together) and confirm 47/47**

```bash
npx tree-sitter test
git status --short
```

Expected: `Total parses: 47; successful parses: 47; failed parses: 0`.
This phase's grammar change is purely additive, so `git status --short`
on the three existing corpus files (`phase1_elements.txt`,
`phase2a_children.txt`, `phase2b_attributes.txt`) should show nothing. If
any shows as modified, stop and investigate before continuing (same
discipline as every prior phase's regression check).

- [ ] **Step 7: Fresh-clone verification**

This step matters more than usual this time — it's the first real test
of whether `src/scanner.c` builds correctly with no cached artifacts.

```bash
cd /tmp
rm -rf tree-sitter-gsx-freshclone
git clone /Users/jackieli/personal/gsxhq/tree-sitter-gsx tree-sitter-gsx-freshclone
cd tree-sitter-gsx-freshclone
git checkout unified-go-grammar
npm install
npx tree-sitter generate
npx tree-sitter build
npx tree-sitter test
```

Expected: all succeed; `tree-sitter test` reports `Total parses: 47;
successful parses: 47; failed parses: 0`, clean exit, no warnings. If
`build` fails here specifically (but succeeded in Step 3), that's a real
signal about the scanner's portability — investigate rather than dismiss.
Clean up afterward:

```bash
cd /Users/jackieli/personal/gsxhq/tree-sitter-gsx/.worktrees/unified-go-grammar
rm -rf /tmp/tree-sitter-gsx-freshclone
```

- [ ] **Step 8: Append to `NOTES.md`**

Add this section at the end of the file (after the existing "Phase 2b
notes" content — don't remove or edit anything already there):

```markdown

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
```

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat(grammar): f/js/css interpolating literals, first external scanner

embedded_f_literal joins _expression (works as a Go value and
automatically inside plain holes); embedded_js_literal/embedded_css_literal
are attribute-context only via embedded_attribute, matching the original
design. First real external scanner in the unified grammar
(embedded_text/embedded_text_dq, lifted near-verbatim from the
pre-existing shipped scanner) -- the @{-hole lookahead can't be a plain
regex token. at_hole supports |> pipe chains (scoped in after confirming
real corpus usage, unlike the still-deferred plain-{}-hole pipe support)
via a plain '|>' token, no scanner needed. 47/47 corpus passing (13+12+11
prior + this task's 11), purely additive. Verified from a fresh clone
(this phase's first real test of scanner portability with no cached
build artifacts). See
docs/superpowers/specs/2026-07-08-unified-go-grammar-phase2c-literals-design.md."
```

---

## Self-Review Notes (already applied above)

- **Spec coverage:** every "In scope" item has a corresponding step —
  `embedded_f_literal`/`embedded_js_literal`/`embedded_css_literal` (Step
  1), `at_hole` with pipe support (Step 1), `embedded_attribute` (Step
  1), the new scanner (Step 2), corpus coverage for all 11 spec-verified
  cases (Step 4), fresh-clone verification with explicit attention to
  scanner portability (Step 7), the NOTES.md entry matching Done
  Criterion 6's required content (first-scanner rationale,
  `css_composed_value` deferral with evidence, pipe-chain scoping
  decision with citation, `'\|>'` no-scanner confirmation) (Step 8).
- **Placeholder scan:** no TBD/TODO; corpus content and scanner.c are the
  literal machine-verified/compiled content, not guesses.
- **Type/name consistency:** `embedded_f_literal`/`embedded_js_literal`/
  `embedded_css_literal`/`embedded_language`/`at_hole`/`embedded_attribute`
  are named identically across Step 1's grammar code and Step 4's corpus
  file (both transcribed from the same verified prototype).
  `EMBEDDED_TEXT`/`EMBEDDED_TEXT_DQ` enum names in Step 2's scanner.c
  match `$.embedded_text`/`$.embedded_text_dq` in Step 1's `externals`
  array exactly (tree-sitter matches these positionally by declaration
  order, not by string name, but keeping the names visually aligned
  avoids confusing a future reader).
