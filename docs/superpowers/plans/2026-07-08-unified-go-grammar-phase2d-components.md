# Unified Go+gsx Grammar — Phase 2d Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add gsx's `component` declaration — the one genuinely
gsx-specific top-level construct — with function-style parameters,
optional method receiver, optional generics, and a markup child body.

**Architecture:** `component_declaration` joins a redeclared
`_top_level_declaration` choice list (same pattern Phase 1 used for
`_expression`). Its receiver/parameters/type-parameters reuse Go's own
`parameter_list`/`type_parameter_list` verbatim; its body is 2a's
`_child` grammar. No external scanner added.

**Tech Stack:** `tree-sitter-cli`, `tree-sitter-go` (already pinned
devDependency), Node.js.

## Global Constraints

- Continues on the `unified-go-grammar` branch (no new worktree/branch).
- `doctype`, `html_comment`, `raw_element` (`<script>`/`<style>` raw-text
  bodies), and `content_comment` are **out of scope** — do not add them.
- No external scanner is added — `component`'s pieces are Go's native
  rules plus 2a's `_child`. `src/scanner.c` (from 2c) is untouched.
- `component_body`, `receiver`, `type_parameters`, `parameters`, `name`,
  `body` field names match the old grammar's `component_declaration`.
- Every new rule ships `test/corpus/*.txt` coverage.
- Full design rationale: `docs/superpowers/specs/2026-07-08-unified-go-grammar-phase2d-components-design.md`.

---

### Task 1: `component_declaration` reusing Go's native parameter rules

**Files:**
- Modify: `grammar.js`
- Create: `test/corpus/phase2d_components.txt`
- Modify: `NOTES.md`

**Interfaces:**
- Consumes: Go's `parameter_list`/`type_parameter_list`/`identifier`
  (inherited from the base grammar, referenced unchanged), Go's
  `package_clause`/`function_declaration`/`method_declaration`/
  `import_declaration` (the existing `_top_level_declaration`
  alternatives, redeclared verbatim plus the new one), 2a's `_child`.
- Produces: `component_declaration` (fields `receiver` [optional],
  `name`, `type_parameters` [optional], `parameters`, `body`) and
  `component_body` (`{ repeat($._child) }`). 2e (corpus port) consumes
  these; no later sub-phase changes them.

- [ ] **Step 1: Add the component rules to `grammar.js`**

Add these two rules to the `rules:` object (e.g. right after the
`externals` block / before `_expression`, anywhere in `rules:` works):

```js
    // Redeclares Go's own top-level-declaration choice list (rule NAMES
    // only) plus component_declaration — same redeclaration pattern as
    // _expression in Phase 1. Verify this list against tree-sitter-go's
    // _top_level_declaration on every upstream version bump.
    _top_level_declaration: $ => choice(
      $.package_clause,
      $.function_declaration,
      $.method_declaration,
      $.import_declaration,
      $.component_declaration,
    ),

    // Reuses Go's own parameter_list (receiver + parameters) and
    // type_parameter_list (generics) verbatim — no custom regex-blob
    // capture needed now that Go is native. Body is 2a's _child grammar.
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

- [ ] **Step 2: Generate and build**

```bash
npx tree-sitter generate
npx tree-sitter build
```

Expected: both succeed with no output (no unresolved-conflict warnings,
no build errors — the scanner from 2c is unchanged, so this is a
grammar-only regeneration plus a relink).

- [ ] **Step 3: Write `test/corpus/phase2d_components.txt`**

Create the file with this exact content:

```
==================
simple component with an element body
==================

package views

component Foo() {
	<div>hello</div>
}

---

(source_file
  (package_clause
    (package_identifier))
  (component_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (component_body
      (element
        open_name: (identifier)
        (text)
        close_name: (identifier)))))

==================
component with typed parameters
==================

package views

component Card(title string, count int) {
	<div class="card">{title}</div>
}

---

(source_file
  (package_clause
    (package_identifier))
  (component_declaration
    name: (identifier)
    parameters: (parameter_list
      (parameter_declaration
        name: (identifier)
        type: (type_identifier))
      (parameter_declaration
        name: (identifier)
        type: (type_identifier)))
    body: (component_body
      (element
        open_name: (identifier)
        (attribute
          (static_attribute
            name: (attribute_name)
            value: (interpreted_string_literal
              (interpreted_string_literal_content))))
        (hole
          (identifier))
        close_name: (identifier)))))

==================
method component with a receiver
==================

package views

component (p Page) Content() {
	<div>{p.Title}</div>
}

---

(source_file
  (package_clause
    (package_identifier))
  (component_declaration
    receiver: (parameter_list
      (parameter_declaration
        name: (identifier)
        type: (type_identifier)))
    name: (identifier)
    parameters: (parameter_list)
    body: (component_body
      (element
        open_name: (identifier)
        (hole
          (selector_expression
            operand: (identifier)
            field: (field_identifier)))
        close_name: (identifier)))))

==================
generic component with a type parameter
==================

package views

component List[T any](items []T) {
	<ul>{ for _, it := range items { <li>{it}</li> } }</ul>
}

---

(source_file
  (package_clause
    (package_identifier))
  (component_declaration
    name: (identifier)
    type_parameters: (type_parameter_list
      (type_parameter_declaration
        name: (identifier)
        type: (type_constraint
          (type_identifier))))
    parameters: (parameter_list
      (parameter_declaration
        name: (identifier)
        type: (slice_type
          element: (type_identifier))))
    body: (component_body
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
              (identifier))
            close_name: (identifier)))
        close_name: (identifier)))))

==================
two adjacent components
==================

package views
component A() {}
component B() {}

---

(source_file
  (package_clause
    (package_identifier))
  (component_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (component_body))
  (component_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (component_body)))

==================
identifier ending in component is not a keyword
==================

package views

var mycomponent = 1

component X() {}

---

(source_file
  (package_clause
    (package_identifier))
  (var_declaration
    (var_spec
      name: (identifier)
      value: (expression_list
        (int_literal))))
  (component_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (component_body)))

==================
component alongside a real Go function declaration
==================

package views

func helper() int { return 1 }

component Foo() {
	<div>{helper()}</div>
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    result: (type_identifier)
    body: (block
      (statement_list
        (return_statement
          (expression_list
            (int_literal))))))
  (component_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (component_body
      (element
        open_name: (identifier)
        (hole
          (call_expression
            function: (identifier)
            arguments: (argument_list)))
        close_name: (identifier)))))

==================
component with an empty body
==================

package views
component Empty() {}

---

(source_file
  (package_clause
    (package_identifier))
  (component_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (component_body)))

==================
component coexists with a Phase 1 top-level element value
==================

package views

var icon = <Icon/>

component Foo() {
	<div>{icon}</div>
}

---

(source_file
  (package_clause
    (package_identifier))
  (var_declaration
    (var_spec
      name: (identifier)
      value: (expression_list
        (element
          name: (identifier)))))
  (component_declaration
    name: (identifier)
    parameters: (parameter_list)
    body: (component_body
      (element
        open_name: (identifier)
        (hole
          (identifier))
        close_name: (identifier)))))
```

This exact content (9 cases, including the method-receiver and generics
cases that prove Go's native `parameter_list`/`type_parameter_list` reuse
gives full structure, the `mycomponent` keyword-boundary regression, and
the coexistence-with-Phase-1-top-level-element case) was hand-written,
run once to see genuine diffs, corrected via `tree-sitter test --update
--show-fields`, and re-verified to 9/9 passing against the real
`tree-sitter-go@0.25.0` package before this plan was written.

- [ ] **Step 4: Run the new corpus and confirm 9/9 pass**

```bash
npx tree-sitter test --file-name phase2d_components.txt
```

Expected: `Total parses: 9; successful parses: 9; failed parses: 0;
success percentage: 100.00%`.

- [ ] **Step 5: Run the full suite (Phase 1 + 2a + 2b + 2c + 2d together) and confirm 56/56**

```bash
npx tree-sitter test
git status --short
```

Expected: `Total parses: 56; successful parses: 56; failed parses: 0`
(47 prior + this task's 9). This phase's grammar change is purely
additive, so `git status --short` on the four existing corpus files
(`phase1_elements.txt`, `phase2a_children.txt`, `phase2b_attributes.txt`,
`phase2c_literals.txt`) should show nothing. If any shows as modified,
stop and investigate before continuing (same discipline as every prior
phase's regression check).

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

Expected: all succeed; `tree-sitter test` reports `Total parses: 56;
successful parses: 56; failed parses: 0`, clean exit, no warnings. Clean
up afterward:

```bash
cd /Users/jackieli/personal/gsxhq/tree-sitter-gsx/.worktrees/unified-go-grammar
rm -rf /tmp/tree-sitter-gsx-freshclone
```

- [ ] **Step 7: Append to `NOTES.md`**

Add this section at the end of the file (after the existing Phase 2c
content and its backlog section — don't remove or edit anything already
there):

```markdown

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
```

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat(grammar): component declarations reusing Go's native parameter rules

component_declaration joins a redeclared _top_level_declaration (same
pattern as Phase 1's _expression). Receiver/parameters/type-parameters
reuse Go's own parameter_list/type_parameter_list verbatim -- no
regex-blob capture, full type-aware structure for free now that Go is
native (method receivers, generics all get real parameter_declaration/
type_parameter_declaration nodes). Body is 2a's _child grammar via a
distinct component_body node. No external scanner added. 56/56 corpus
passing (47 prior + this task's 9), purely additive. Verified from a
fresh clone. Real .gsx files (which all start with 'component ...') now
parse on this branch for the first time. See
docs/superpowers/specs/2026-07-08-unified-go-grammar-phase2d-components-design.md."
```

---

## Self-Review Notes (already applied above)

- **Spec coverage:** every "In scope" item has a corresponding step —
  `component_declaration` on a redeclared `_top_level_declaration` (Step
  1), `component_body` (Step 1), receiver/typed-params/generics via Go's
  native rules (Step 1, proven by corpus cases 2/3/4 in Step 3),
  corpus coverage for all 9 verified cases including the two
  regression-flavored ones and the cross-phase coexistence case (Step 3),
  fresh-clone verification (Step 6), the NOTES.md entry matching Done
  Criterion 6's required content (Go-native reuse, redeclaration +
  maintenance note, deferral list) (Step 7).
- **Placeholder scan:** no TBD/TODO; corpus content is the literal
  machine-verified output.
- **Type/name consistency:** `component_declaration`/`component_body` and
  the `receiver`/`name`/`type_parameters`/`parameters`/`body` field names
  are used identically across Step 1's grammar code and Step 3's corpus
  file (both transcribed from the same verified prototype), and match the
  field names the spec says the old grammar used.
