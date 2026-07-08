# Unified Go+gsx Grammar — Phase 2b Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give `element` a real attribute list — static, expression,
boolean, spread, and conditional attributes — where Phase 1/2a's
`element` has none at all.

**Architecture:** `element`'s self-closing and open-tag forms gain
`repeat($.attribute)`. `attribute` is a choice of `static_attribute`
(reusing Go's `_string_literal`), `expr_attribute` (reusing 2a's `hole`),
`bool_attribute`, `spread_attribute`, and `conditional_attribute`
(reusing 2a's `for_clause`/`range_clause` condition-clause approach,
applied to an attribute list instead of a child list).

**Tech Stack:** `tree-sitter-cli`, `tree-sitter-go` (already pinned devDependency), Node.js.

## Global Constraints

- Continues on the `unified-go-grammar` branch (no new worktree/branch).
- `f`/`js`/`css` literal attribute values, `css_composed_value`,
  `value_control_flow` (if/switch as an attribute *value*), `content_comment`
  (inline attribute comments — deferred alongside its child-position form
  from 2a), `component` declarations, and the `\|>` pipeline operator
  inside holes are **out of scope** — do not add them.
- `conditional_attribute` supports `if`/`for` only (no `switch`) — matches
  the old grammar's own scope, not a new limitation to "fix."
- No external scanner unless a step below empirically hits a case that
  needs one — none is expected.
- Every new rule ships `test/corpus/*.txt` coverage.
- Full design rationale: `docs/superpowers/specs/2026-07-08-unified-go-grammar-phase2b-attributes-design.md`.

---

### Task 1: Element attributes — static, expr, bool, spread, conditional

**Files:**
- Modify: `grammar.js`
- Create: `test/corpus/phase2b_attributes.txt`
- Modify: `NOTES.md`

**Interfaces:**
- Consumes: 2a's `hole` (reused unchanged for `expr_attribute`'s value),
  `for_clause`/`range_clause` (reused unchanged for `conditional_attribute`'s
  condition), `_expression` (from Phase 1, includes `element`/`fragment`).
- Produces: `element`'s `name`/`open_name` field now precedes zero or more
  `attribute` children (unnamed, i.e. not a field — matches how `_child`
  works in 2a) before the tag's closing `>`/`/>`. `attribute_name` is the
  name field's type for all four named-attribute kinds
  (`static_attribute`/`expr_attribute`/`bool_attribute` use `name:`;
  `spread_attribute`/`conditional_attribute` don't have a name). Phase 2c
  will extend `attribute`'s choice list with `embedded_attribute`, not
  replace it.

- [ ] **Step 1: Add the attribute rules to `grammar.js`**

Find the `element` rule (from Phase 2a) and replace it, then add the new
rules immediately after it:

```js
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

- [ ] **Step 2: Generate and build**

```bash
npx tree-sitter generate
npx tree-sitter build
```

Expected: both succeed with no output (no unresolved-conflict warnings,
no build errors).

- [ ] **Step 3: Write `test/corpus/phase2b_attributes.txt`**

Create the file with this exact content:

```
==================
static, bool, expr, and spread attributes on a self-closing tag
==================

package main
func f() {
	var x = <div class="x" disabled data={y} {attrs...}/>
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
                    value: (interpreted_string_literal
                      (interpreted_string_literal_content))))
                (attribute
                  (bool_attribute
                    name: (attribute_name)))
                (attribute
                  (expr_attribute
                    name: (attribute_name)
                    value: (hole
                      (identifier))))
                (attribute
                  (spread_attribute
                    value: (identifier)))))))))))

==================
attributes on an open-tag form (not just self-closing)
==================

package main
func f() {
	var x = <div class="x">child</div>
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
                  (static_attribute
                    name: (attribute_name)
                    value: (interpreted_string_literal
                      (interpreted_string_literal_content))))
                (text)
                close_name: (identifier)))))))))

==================
conditional attribute with if-else, nested static attributes
==================

package main
func f() {
	var x = <div {if cond { class="active" } else { class="inactive" }}>x</div>
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
                  (conditional_attribute
                    (keyword)
                    condition: (identifier)
                    (attribute
                      (static_attribute
                        name: (attribute_name)
                        value: (interpreted_string_literal
                          (interpreted_string_literal_content))))
                    (keyword)
                    (attribute
                      (static_attribute
                        name: (attribute_name)
                        value: (interpreted_string_literal
                          (interpreted_string_literal_content))))))
                (text)
                close_name: (identifier)))))))))

==================
backtick (raw) string attribute value
==================

package main
func f() {
	var x = <div class=`raw string`/>
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
attribute_name extended character set (dash, colon, at-sign)
==================

package main
func f() {
	var x = <div data-x="a" aria:label="b" @click={fn}/>
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
                    value: (interpreted_string_literal
                      (interpreted_string_literal_content))))
                (attribute
                  (static_attribute
                    name: (attribute_name)
                    value: (interpreted_string_literal
                      (interpreted_string_literal_content))))
                (attribute
                  (expr_attribute
                    name: (attribute_name)
                    value: (hole
                      (identifier))))))))))))

==================
conditional attribute mixed with static and bool attributes, if with no else
==================

package main
func f() {
	var x = <div id="x" {if a { class="b" }} disabled/>
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
                    value: (interpreted_string_literal
                      (interpreted_string_literal_content))))
                (attribute
                  (conditional_attribute
                    (keyword)
                    condition: (identifier)
                    (attribute
                      (static_attribute
                        name: (attribute_name)
                        value: (interpreted_string_literal
                          (interpreted_string_literal_content))))))
                (attribute
                  (bool_attribute
                    name: (attribute_name)))))))))))

==================
variadic Go call inside expr_attribute disambiguates from spread_attribute
==================

package main
func f() {
	var x = <div data={fn(args...)}/>
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
                  (expr_attribute
                    name: (attribute_name)
                    value: (hole
                      (call_expression
                        function: (identifier)
                        arguments: (argument_list
                          (variadic_argument
                            (identifier)))))))))))))))

==================
expr_attribute and spread_attribute back to back
==================

package main
func f() {
	var x = <div data={fn(a, b)} {spreadme...}/>
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
                  (expr_attribute
                    name: (attribute_name)
                    value: (hole
                      (call_expression
                        function: (identifier)
                        arguments: (argument_list
                          (identifier)
                          (identifier))))))
                (attribute
                  (spread_attribute
                    value: (identifier)))))))))))

==================
conditional attribute as the last attribute before the closing tag
==================

package main
func f() {
	var x = <div class="x" {if cond { disabled }}/>
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
                    value: (interpreted_string_literal
                      (interpreted_string_literal_content))))
                (attribute
                  (conditional_attribute
                    (keyword)
                    condition: (identifier)
                    (attribute
                      (bool_attribute
                        name: (attribute_name)))))))))))))
```

This exact content (9 cases, including the variadic-call-vs-spread
disambiguation and the conditional-attribute-in-last-position case the
spec specifically called for) was hand-written, run once to see genuine
diffs, corrected via `tree-sitter test --update --show-fields`, and
re-verified to 9/9 passing against the real `tree-sitter-go@0.25.0`
package before this plan was written.

- [ ] **Step 4: Run the new corpus and confirm 9/9 pass**

```bash
npx tree-sitter test --file-name phase2b_attributes.txt
```

Expected: `Total parses: 9; successful parses: 9; failed parses: 0;
success percentage: 100.00%`.

- [ ] **Step 5: Run the full suite (Phase 1 + 2a + 2b together) and confirm 34/34**

```bash
npx tree-sitter test
git status --short
```

Expected: `Total parses: 34; successful parses: 34; failed parses: 0`.
This phase's grammar change is purely additive (`repeat($.attribute)` was
implicitly zero before), so `git status --short` on `test/corpus/`
should show only the new `phase2b_attributes.txt` file — no existing
corpus file's expected trees should need regenerating. Confirm this by
checking `git status --short test/corpus/phase1_elements.txt
test/corpus/phase2a_children.txt` shows nothing. If either file DOES
show as modified, stop: that means an assumption in this plan was wrong,
and the diff needs to be understood before proceeding (same discipline
as Phase 2a's Task 1 Step 3 — don't just accept an unexplained diff).

- [ ] **Step 6: Fresh-clone verification**

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

Expected: all succeed; `tree-sitter test` reports `Total parses: 34;
successful parses: 34; failed parses: 0`, clean exit, no warnings. Clean
up afterward:

```bash
cd /Users/jackieli/personal/gsxhq/tree-sitter-gsx/.worktrees/unified-go-grammar
rm -rf /tmp/tree-sitter-gsx-freshclone
```

- [ ] **Step 7: Append to `NOTES.md`**

Add this section at the end of the file (after the existing "Phase 2a
notes" content — don't remove or edit anything already there):

```markdown

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
- `conditional_attribute` supports `if`/`for` only (no `switch`) —
  matches the old grammar's own scope, not a new limitation.
- Still no external scanner.
- Deferred (see the Phase 2b spec for the full list): `f`/`js`/`css`
  literal attribute values (2c), `css_composed_value`,
  `value_control_flow` (if/switch as an attribute *value* — distinct from
  `conditional_attribute`, which wraps whole attributes), `component`
  declarations (2d), the `\|>` pipeline operator inside holes (inherited
  from 2a, `expr_attribute` reuses `hole` as-is).
```

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat(grammar): element attributes — static, expr, bool, spread, conditional

element gains repeat(attribute): static_attribute (reuses Go's own
_string_literal, drops the old grammar's non-Go single-quote support),
expr_attribute (reuses 2a's hole unchanged), bool_attribute,
spread_attribute, and conditional_attribute (if/for+else, reusing 2a's
for_clause/range_clause condition-clause approach for an attribute list
instead of a child list). No external scanner. 34/34 corpus passing
(Phase 1's 13 + 2a's 12 + this task's 9), purely additive - no existing
corpus file needed regenerating. Verified from a fresh clone. See
docs/superpowers/specs/2026-07-08-unified-go-grammar-phase2b-attributes-design.md."
```

---

## Self-Review Notes (already applied above)

- **Spec coverage:** every "In scope" item has a corresponding step —
  `repeat($.attribute)` on both element tag forms (Step 1), all five
  attribute kinds (Step 1, tested Step 4/5), `attribute_name` (Step 1),
  corpus coverage for all 10 spec-verified cases plus the explicit
  non-trivial-position requirement from the spec's Testing Strategy
  (conditional attribute last, Step 3's final case), fresh-clone
  verification (Step 6), the NOTES.md entry matching Done Criterion 5's
  required content (quoting decision + grep evidence, `content_comment`
  deferral, variadic-vs-spread finding) (Step 7).
- **Placeholder scan:** no TBD/TODO; corpus content is the literal
  machine-verified output.
- **Type/name consistency:** `attribute`, `attribute_name`,
  `static_attribute`, `expr_attribute`, `bool_attribute`,
  `spread_attribute`, `conditional_attribute` are named identically
  across Step 1's grammar code and Step 3's corpus file (both
  transcribed from the same verified prototype). `element`'s
  `name`/`open_name`/`close_name` fields are unchanged from 2a/Phase 1 —
  no drift.
