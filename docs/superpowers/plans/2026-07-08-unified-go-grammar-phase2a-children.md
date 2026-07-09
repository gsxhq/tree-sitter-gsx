# Unified Go+gsx Grammar — Phase 2a Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give `element`/`fragment` real mixed-content bodies (text, nested
elements/fragments, `{ }` holes, `if`/`for`/`switch`+`else` control-flow),
replacing Phase 1's flat, un-nestable `element_text` regex.

**Architecture:** `element`/`fragment` bodies become `repeat($._child)`
where `_child` is a choice of `element`, `fragment`, `hole` (`{
_expression }`), `control_flow`, and `text`. Holes and control-flow
conditions are real Go `_expression`s (with `for` reusing Go's own
`for_clause`/`range_clause` verbatim) — no external scanner.

**Tech Stack:** `tree-sitter-cli`, `tree-sitter-go` (already pinned devDependency from Phase 1), Node.js.

## Global Constraints

- Continues on the `unified-go-grammar` branch (same branch as Phase 1 — do
  not create a new worktree/branch).
- Attributes, `f`/`js`/`css` literals, `component` declarations, `doctype`,
  `html_comment`, `content_comment`, `raw_element`, and the `\|>` pipeline
  operator inside holes are **out of scope** — do not add them.
- `value_control_flow` (if/switch inside an attribute value) is out of
  scope — attribute-position concern, not this phase's.
- No external scanner unless a step below empirically hits a case that
  needs one — none is expected.
- Every new rule ships `test/corpus/*.txt` coverage.
- Full design rationale: `docs/superpowers/specs/2026-07-08-unified-go-grammar-phase2a-children-design.md`.

---

### Task 1: Element/fragment children, holes, and control-flow

**Files:**
- Modify: `grammar.js`
- Modify: `test/corpus/phase1_elements.txt` (regenerate 3 cases' expected
  trees only — inputs unchanged)
- Create: `test/corpus/phase2a_children.txt`
- Modify: `NOTES.md`

**Interfaces:**
- Consumes: Phase 1's `_expression` (already includes `$.element`,
  `$.fragment`), and `tree-sitter-go`'s `for_clause`/`range_clause` rules
  (inherited unmodified from the base grammar — reference them as
  `$.for_clause`/`$.range_clause`, do not redefine).
- Produces: `element`'s open/close form and `fragment` both take
  `repeat($._child)` as their body. `_child` is a choice of `element`,
  `fragment`, `hole`, `control_flow`, `text` — Phase 2b (attributes) and
  2c (`f`/`js`/`css` literals) will extend this same `_child` choice list,
  not replace it.

- [ ] **Step 1: Replace `element`/`fragment` and add the children rules in `grammar.js`**

Find the current `element`/`fragment`/`element_text` block (added in
Phase 1) and replace it with:

```js
    element: $ => choice(
      seq('<', field('name', $.identifier), '/>'),
      seq(
        '<', field('open_name', $.identifier), '>',
        repeat($._child),
        '</', field('close_name', $.identifier), '>',
      ),
    ),

    // '<>'/'</>' as single atomic tokens (not seq('<', '>')) — matters:
    // a naive two-literal seq lets the parser fork into element's
    // '<' + identifier path first and error out on '>' instead of
    // choosing fragment.
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

    // Hole body is a real Go expression — element/fragment already
    // included via _expression (Phase 1). No separate node-sequence
    // alternative: every real standalone-hole usage in the legacy corpus
    // is a single node, and elements are already Go expressions.
    hole: $ => seq('{', $._expression, '}'),

    // Condition reuses Go's own for_statement condition shape (plain
    // expr, or a real for_clause/range_clause for `for`) — inherited
    // from the base grammar unmodified, not reimplemented. The block
    // body is markup children, not Go statements, so control_flow can't
    // reuse Go's native if_statement/for_statement wholesale (their
    // block holds $._statement).
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

Remove the old `element_text` rule entirely — it's replaced by `text` +
the `_child` model. Also remove `$.element`/`$.fragment` if they were
duplicated in the `_expression` choice list — they should already be
there from Phase 1 and don't need to change.

- [ ] **Step 2: Generate and build**

```bash
npx tree-sitter generate
npx tree-sitter build
```

Expected: both succeed with no output (no unresolved-conflict warnings, no
build errors).

- [ ] **Step 3: Regenerate Phase 1's corpus expected trees (inputs unchanged)**

```bash
npx tree-sitter test --file-name phase1_elements.txt --update --show-fields
```

Expected output: `3 updates:` naming the 3 cases whose bodies are flat
text (`element open/close with plain text in var-decl value`, `fragment
with plain text in var-decl value`, `element open/close with inline text
as a return value`). Then verify:

```bash
npx tree-sitter test --file-name phase1_elements.txt
```

Expected: `Total parses: 13; successful parses: 13; failed parses: 0`.
Confirm via `git diff test/corpus/phase1_elements.txt` that only those 3
cases' **expected trees** changed (each `body: (element_text)` line
becomes a bare `(text)` line, no other change) — the `---`-delimited
**input** snippets must be byte-identical to before. If the diff touches
anything else, stop and investigate before continuing.

- [ ] **Step 4: Write `test/corpus/phase2a_children.txt`**

Create the file with this exact content:

```
==================
mixed text, nested element, and a hole in one body
==================

package main
func f() {
	var x = <div>Hello <b>world</b>, you have {count} items</div>
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
                (text)
                (element
                  open_name: (identifier)
                  (text)
                  close_name: (identifier))
                (text)
                (hole
                  (identifier))
                (text)
                close_name: (identifier)))))))))

==================
empty children
==================

package main
func f() {
	var x = <div></div>
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
                close_name: (identifier)))))))))

==================
hole containing a plain identifier
==================

package main
func f() {
	var x = <div>{x}</div>
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
                  (identifier))
                close_name: (identifier)))))))))

==================
nested fragment as a child
==================

package main
func f() {
	var x = <div><></></div>
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
                (fragment)
                close_name: (identifier)))))))))

==================
hole containing an element (hole is a real Go expression)
==================

package main
func f() {
	var x = <div>{<Icon/>}</div>
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
                  (element
                    name: (identifier)))
                close_name: (identifier)))))))))

==================
bare self-closing element is unaffected by children support
==================

package main
func f() {
	var x = <Icon/>
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
                name: (identifier)))))))))

==================
if control-flow with a plain expression condition
==================

package main
func f() {
	var x = <div>{ if cond { <span/> } }</div>
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
                (control_flow
                  (keyword)
                  condition: (identifier)
                  (element
                    name: (identifier)))
                close_name: (identifier)))))))))

==================
for control-flow with a range clause
==================

package main
func f() {
	var x = <div>{ for _, it := range items { <li>{it.Name}</li> } }</div>
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
                (control_flow
                  (keyword)
                  condition: (range_clause
                    left: (expression_list
                      (identifier)
                      (identifier))
                    right: (identifier))
                  (element
                    open_name: (identifier)
                    (hole
                      (selector_expression
                        operand: (identifier)
                        field: (field_identifier)))
                    close_name: (identifier)))
                close_name: (identifier)))))))))

==================
if-else control-flow
==================

package main
func f() {
	var x = <div>{ if cond { <span/> } else { <div/> } }</div>
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
                (control_flow
                  (keyword)
                  condition: (identifier)
                  (element
                    name: (identifier))
                  (else_clause
                    (keyword)
                    (element
                      name: (identifier))))
                close_name: (identifier)))))))))

==================
if-else-if-else chain
==================

package main
func f() {
	var x = <div>{ if a { <span/> } else if b { <div/> } else { <p/> } }</div>
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
                (control_flow
                  (keyword)
                  condition: (identifier)
                  (element
                    name: (identifier))
                  (else_clause
                    (keyword)
                    (keyword)
                    condition: (identifier)
                    (element
                      name: (identifier)))
                  (else_clause
                    (keyword)
                    (element
                      name: (identifier))))
                close_name: (identifier)))))))))

==================
switch control-flow (case/default lines are inert text, matching the pre-existing shipped grammar's own design)
==================

package main
func f() {
	var x = <div>{ switch status {
	case "ok":
		<span/>
	default:
		<div/>
	} }</div>
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
                (control_flow
                  (keyword)
                  condition: (identifier)
                  (text)
                  (element
                    name: (identifier))
                  (text)
                  (element
                    name: (identifier)))
                close_name: (identifier)))))))))
```

This exact content (11 cases) was hand-written, run once to see genuine
diffs, corrected via `tree-sitter test --update --show-fields`, and
re-verified to 11/11 passing against the real `tree-sitter-go@0.25.0`
package before this plan was written — not a guess.

- [ ] **Step 5: Run the new corpus and confirm 11/11 pass**

```bash
npx tree-sitter test --file-name phase2a_children.txt
```

Expected: `Total parses: 11; successful parses: 11; failed parses: 0;
success percentage: 100.00%`.

- [ ] **Step 6: Run the full suite (Phase 1 + Phase 2a together) and confirm 24/24**

```bash
npx tree-sitter test
git status --short
```

Expected: `Total parses: 24; successful parses: 24; failed parses: 0`.
`git status --short` shows only: `grammar.js` modified,
`test/corpus/phase1_elements.txt` modified (3 expected-tree updates only),
`test/corpus/phase2a_children.txt` created, plus the regenerated `src/`
files.

- [ ] **Step 7: Fresh-clone verification**

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

Expected: all succeed; `tree-sitter test` reports `Total parses: 24;
successful parses: 24; failed parses: 0`, clean exit, no warnings (same
bar as Phase 1 — the `queries-legacy-blob-model`/`test/*-legacy-blob-model`
relocations from Phase 1 already keep `tree-sitter test` warning-free — no
new relocation is needed in this task). Clean up afterward:

```bash
cd /Users/jackieli/personal/gsxhq/tree-sitter-gsx/.worktrees/unified-go-grammar
rm -rf /tmp/tree-sitter-gsx-freshclone
```

- [ ] **Step 8: Append to `NOTES.md`**

Add this section (after the existing Phase 1 content, before or after the
"Capability regressions" section already there — either position is
fine, just don't remove existing content):

```markdown

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
```

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat(grammar): element/fragment children — text, nested markup, holes, if/for/switch control-flow

element/fragment bodies become repeat(_child) (element/fragment/hole/
control_flow/text) instead of Phase 1's flat element_text regex. Holes
and if/switch conditions are real Go _expressions (elements/fragments
already included via Phase 1); for reuses Go's own for_clause/
range_clause verbatim. No external scanner. 24/24 corpus passing
(Phase 1's 13 + this task's 11), verified from a fresh clone. See
docs/superpowers/specs/2026-07-08-unified-go-grammar-phase2a-children-design.md."
```

---

## Self-Review Notes (already applied above)

- **Spec coverage:** every "In scope" item from the spec has a
  corresponding step — `repeat($._child)` bodies (Step 1), `hole` (Step
  1, tested Step 4/5), `control_flow` with `if`/`for`/`switch`+`else`
  (Step 1, tested Step 4/5), corpus coverage for all 10 spec-listed cases
  plus the `switch` case the spec called out as needing its own test
  (Step 4), the Phase 1 regression requirement — corrected in both the
  spec and here to "zero `ERROR` nodes, 3 expected-tree updates" rather
  than "unmodified" (Step 3), fresh-clone verification (Step 7), the
  NOTES.md entry (Step 8, matches Done Criterion 5's required content:
  hole-simplification finding, `for`-clause fix, deferral list).
- **Placeholder scan:** no TBD/TODO; the corpus content is the literal
  machine-verified output, not hand-guessed.
- **Type/name consistency:** `_child`, `hole`, `control_flow`,
  `else_clause`, `text` are named identically across Step 1's grammar
  code and Step 4's corpus file (both transcribed from the same verified
  prototype). `control_flow`'s `condition` field and `element`'s
  `open_name`/`close_name`/`name` fields match Phase 1's existing
  naming — no drift.
