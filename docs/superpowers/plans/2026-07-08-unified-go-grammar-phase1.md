# Unified Go+gsx Grammar — Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `tree-sitter-gsx`'s `grammar.js` (on a dedicated branch, not
`main`) with a unified Go+gsx grammar — `element`/`fragment` as native Go
`_expression` alternatives, composed on top of the real `tree-sitter-go` npm
package — proving the architecture with zero `ERROR` nodes on the case that
motivated this work, before any gsx-specific surface syntax is added.

**Architecture:** `grammar.js` does `require('tree-sitter-go/grammar.js')`
and calls tree-sitter's `grammar(base, overrides)` composition API,
redeclaring `_expression`'s alternative list (rule names only — every other
rule, including `_expression`'s existing alternatives' own bodies, is
inherited untouched) to add `element` and `fragment`. No external scanner.
Legacy corpus/examples (which all depend on syntax this phase doesn't
implement) are relocated for the duration of the branch so CI keeps
validating exactly what this phase claims.

**Tech stack:** `tree-sitter-cli` (existing devDependency), `tree-sitter-go`
(new devDependency, pinned `0.25.0`), Node.js (generation-time only).

## Global Constraints

- `tree-sitter-go` is a devDependency, required from `node_modules`, never
  copied into this repo. Version pinned exactly (`"0.25.0"`, no `^`/`~`).
- `component_declaration`, attributes, `{ }` holes, `f`/`js`/`css` literals,
  and the current blob-boundary scanner tokens are **out of scope**. Do not
  touch `src/scanner.c` — it is confirmed harmless to leave in place
  unreferenced (verified: `tree-sitter generate`+`build`+`parse` all
  succeed with zero `ERROR` nodes with the old `scanner.c` physically
  present alongside a zero-`externals` `grammar.js`).
- Every new rule ships `test/corpus/*.txt` coverage (tree-sitter's native
  corpus format — see `test/corpus-legacy-blob-model/toplevel.txt` for
  house style after Task 1 moves it there).
- This branch does not merge to `main` — Phase 2/3 (separate specs/plans)
  reach full parity first. Do not delete or edit the content of any legacy
  corpus/example file — only relocate it.
- Work happens in a git worktree/branch off `tree-sitter-gsx` `main`
  (`superpowers:using-git-worktrees`), branch name `unified-go-grammar`.
- Full design rationale, the composition mechanism, and the exact verified
  grammar shape (including the fragment atomic-token fix) are in
  `docs/superpowers/specs/2026-07-08-unified-go-grammar-phase1-design.md`
  — read it before Task 2.

---

### Task 1: Relocate legacy test assets, add the `tree-sitter-go` dependency, keep CI green

**Files:**
- Move: `test/corpus/components_fragments.txt` → `test/corpus-legacy-blob-model/components_fragments.txt`
- Move: `test/corpus/control_flow.txt` → `test/corpus-legacy-blob-model/control_flow.txt`
- Move: `test/corpus/elements.txt` → `test/corpus-legacy-blob-model/elements.txt`
- Move: `test/corpus/holes_attrs.txt` → `test/corpus-legacy-blob-model/holes_attrs.txt`
- Move: `test/corpus/pipeline.txt` → `test/corpus-legacy-blob-model/pipeline.txt`
- Move: `test/corpus/raw_text.txt` → `test/corpus-legacy-blob-model/raw_text.txt`
- Move: `test/corpus/skeleton.txt` → `test/corpus-legacy-blob-model/skeleton.txt`
- Move: `test/corpus/toplevel.txt` → `test/corpus-legacy-blob-model/toplevel.txt`
- Move: `test/examples/01_elements.gsx` through `test/examples/13_embedded_literals.gsx` (all 13 files) → same names under `test/examples-legacy-blob-model/`
- Create: `test/corpus-legacy-blob-model/README.md`
- Create: `test/examples-legacy-blob-model/README.md`
- Modify: `package.json`
- Modify: `.github/workflows/ci.yml`

**Interfaces:**
- Produces: `test/corpus/` and `test/examples/` both empty/absent at the end
  of this task (Task 2 creates `test/corpus/phase1_elements.txt`; no
  `.gsx` example file is created in Phase 1 at all — `component` syntax
  doesn't exist yet).
- Produces: `package.json` `devDependencies["tree-sitter-go"] === "0.25.0"`,
  used by Task 2's `grammar.js`.

- [ ] **Step 1: Move the legacy corpus and example files**

```bash
mkdir -p test/corpus-legacy-blob-model test/examples-legacy-blob-model
git mv test/corpus/components_fragments.txt test/corpus-legacy-blob-model/
git mv test/corpus/control_flow.txt test/corpus-legacy-blob-model/
git mv test/corpus/elements.txt test/corpus-legacy-blob-model/
git mv test/corpus/holes_attrs.txt test/corpus-legacy-blob-model/
git mv test/corpus/pipeline.txt test/corpus-legacy-blob-model/
git mv test/corpus/raw_text.txt test/corpus-legacy-blob-model/
git mv test/corpus/skeleton.txt test/corpus-legacy-blob-model/
git mv test/corpus/toplevel.txt test/corpus-legacy-blob-model/
git mv test/examples/01_elements.gsx test/examples-legacy-blob-model/
git mv test/examples/02_text_escaping.gsx test/examples-legacy-blob-model/
git mv test/examples/03_control_flow.gsx test/examples-legacy-blob-model/
git mv test/examples/04_components.gsx test/examples-legacy-blob-model/
git mv test/examples/05_attributes.gsx test/examples-legacy-blob-model/
git mv test/examples/06_corner_cases.gsx test/examples-legacy-blob-model/
git mv test/examples/07_realworld_dialog.gsx test/examples-legacy-blob-model/
git mv test/examples/08_realworld_table.gsx test/examples-legacy-blob-model/
git mv test/examples/09_realworld_form_htmx.gsx test/examples-legacy-blob-model/
git mv test/examples/10_realworld_layout_email.gsx test/examples-legacy-blob-model/
git mv test/examples/11_struct_methods.gsx test/examples-legacy-blob-model/
git mv test/examples/12_children_attrs.gsx test/examples-legacy-blob-model/
git mv test/examples/13_embedded_literals.gsx test/examples-legacy-blob-model/
rmdir test/corpus test/examples 2>/dev/null || true
```

Expected: both `test/corpus/` and `test/examples/` no longer exist (or are
empty); `git status` shows all files as renames, not add+delete.

- [ ] **Step 2: Write the legacy-corpus README**

Create `test/corpus-legacy-blob-model/README.md`:

```markdown
# Legacy blob-model corpus (temporarily relocated)

These are the `test/corpus/*.txt` files as they existed on `main` before the
`unified-go-grammar` branch replaced `grammar.js` with a Go-superset
architecture (see
`docs/superpowers/specs/2026-07-08-unified-go-grammar-phase1-design.md`).

They test the "Go as opaque blob + tree-sitter-go injection" grammar
(`go_chunk`/`go_text`/`component_declaration`/attributes/`{ }` holes/etc.)
that this branch does not implement yet — Phase 1 only adds `element`/
`fragment` as native Go expressions, with no `component` syntax or
attributes at all.

Moved here — not deleted, not modified — so `tree-sitter test` on this
branch validates only what Phase 1 actually claims to support, instead of
failing on assertions about syntax this branch hasn't built yet.

**Phase 2** ports/reconciles these against the new unified grammar and
restores them to `test/corpus/`.
```

- [ ] **Step 3: Write the legacy-examples README**

Create `test/examples-legacy-blob-model/README.md`:

```markdown
# Legacy blob-model examples (temporarily relocated)

`.gsx` example files as they existed on `main` before the
`unified-go-grammar` branch replaced `grammar.js` with a Go-superset
architecture (see
`docs/superpowers/specs/2026-07-08-unified-go-grammar-phase1-design.md`).
Every file here uses `component` syntax and/or attributes, neither of
which exist in this branch's Phase 1 grammar.

Moved here — not deleted, not modified — so CI's "Parse examples" step on
this branch doesn't fail on syntax this branch hasn't built yet.

**Phase 2** ports/reconciles these against the new unified grammar and
restores them to `test/examples/`.
```

- [ ] **Step 4: Add `tree-sitter-go` as a pinned devDependency**

Edit `package.json` (exact current content, then the diff):

```json
{
  "name": "tree-sitter-gsx",
  "version": "0.0.1",
  "private": true,
  "description": "tree-sitter grammar for the gsx templating language",
  "devDependencies": {
    "tree-sitter-cli": "^0.26.0",
    "tree-sitter-go": "0.25.0"
  },
  "scripts": { "generate": "tree-sitter generate", "test": "tree-sitter test" }
}
```

- [ ] **Step 5: Install and confirm the lockfile picks up the pin**

```bash
npm install
grep -A2 '"tree-sitter-go"' package-lock.json | head -5
```

Expected: `package-lock.json` now has a `node_modules/tree-sitter-go` entry
resolving to `0.25.0`.

- [ ] **Step 6: Guard CI's "Parse examples" step against zero example files**

Edit `.github/workflows/ci.yml`. Current content:

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: actions/setup-node@v6
        with: { node-version: 24 }
      - run: npm install
      - run: npx tree-sitter generate
      - name: Generated parser is committed and up to date
        run: git diff --exit-code -- src/
      - run: npx tree-sitter test
      - name: Parse examples (zero errors)
        run: for f in test/examples/*.gsx; do npx tree-sitter parse -q "$f"; done
```

Replace the final step with:

```yaml
      - name: Parse examples (zero errors)
        run: |
          shopt -s nullglob
          examples=(test/examples/*.gsx)
          if [ ${#examples[@]} -eq 0 ]; then
            echo "no test/examples/*.gsx yet (expected on unified-go-grammar Phase 1 — see docs/superpowers/specs/2026-07-08-unified-go-grammar-phase1-design.md)"
            exit 0
          fi
          for f in "${examples[@]}"; do npx tree-sitter parse -q "$f"; done
```

(GitHub Actions runs `run:` steps under `bash` by default on
`ubuntu-latest`, so `shopt` works without an explicit `shell:` key.)

- [ ] **Step 7: Verify generate is a no-op (grammar.js hasn't changed yet) and test passes vacuously**

```bash
npx tree-sitter generate
git diff --exit-code -- src/
npx tree-sitter test
```

Expected: `git diff --exit-code -- src/` exits 0 (no changes — `grammar.js`
is untouched in this task, so regenerating produces byte-identical output).
`npx tree-sitter test` prints `Total parses: 0; successful parses: 0;
failed parses: 0; success percentage: N/A` and exits 0 (confirmed: this is
`tree-sitter test`'s real behavior with no `test/corpus/` directory
present, not an assumption).

- [ ] **Step 8: Locally replicate the CI example-parsing step to confirm the guard works**

```bash
bash -c '
shopt -s nullglob
examples=(test/examples/*.gsx)
if [ ${#examples[@]} -eq 0 ]; then
  echo "no examples yet - OK path"
  exit 0
fi
for f in "${examples[@]}"; do npx tree-sitter parse -q "$f"; done
'
echo "exit: $?"
```

Expected: prints `no examples yet - OK path` and `exit: 0`.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "chore: relocate legacy blob-model corpus/examples, add tree-sitter-go dependency

Phase 1 of the unified Go+gsx grammar (docs/superpowers/specs/2026-07-08-unified-go-grammar-phase1-design.md)
replaces grammar.js with a Go-superset architecture that doesn't implement
component/attribute syntax yet. Relocating the legacy corpus/examples (not
deleting — Phase 2 restores and ports them) keeps CI meaningfully green
for what this branch actually builds, instead of red on hundreds of
assertions about syntax that doesn't exist here yet."
```

---

### Task 2: Compose the unified grammar and verify with the Phase 1 corpus

**Files:**
- Modify: `grammar.js` (full replacement)
- Create: `test/corpus/phase1_elements.txt`
- No change (confirmed unnecessary and harmless to touch): `src/scanner.c`

**Interfaces:**
- Consumes: `tree-sitter-go` devDependency pinned in `package.json` from
  Task 1.
- Produces: a `gsx` grammar whose `_expression` rule includes `$.element`
  and `$.fragment`; `element` has fields `name` (self-closing) or
  `open_name`/`body`/`close_name` (open/close with plain text);
  `fragment` has an optional `body` field. These field/node names are
  Phase 2's integration surface (attributes get added to `element`'s
  rule, holes replace `element_text` where `{ }` appears) — do not rename
  them without a reason recorded in this task's report.

- [ ] **Step 1: Replace `grammar.js` with the composed grammar**

Replace the full contents of `grammar.js` with:

```js
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
    // choosing fragment.
    fragment: $ => seq(
      token(seq('<', '>')),
      optional(field('body', $.element_text)),
      token(seq('<', '/', '>')),
    ),

    element_text: $ => token(prec(-1, /[^<]+/)),
  },
});
```

- [ ] **Step 2: Generate and build**

```bash
npx tree-sitter generate
npx tree-sitter build
```

Expected: both succeed with no output (no unresolved-conflict warnings,
no build errors).

- [ ] **Step 3: Write the Phase 1 corpus file**

Create `test/corpus/phase1_elements.txt`:

```
==================
element self-closing in var-decl value
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
element open/close with plain text in var-decl value
==================

package main
func f() {
	var x = <div>hello</div>
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
                body: (element_text)
                close_name: (identifier)))))))))

==================
fragment with plain text in var-decl value
==================

package main
func f() {
	var x = <>hello</>
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
              (fragment
                body: (element_text)))))))))

==================
element self-closing as a return value
==================

package main
func f() gsx.Node {
	return <Icon/>
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    result: (qualified_type
      package: (package_identifier)
      name: (type_identifier))
    body: (block
      (statement_list
        (return_statement
          (expression_list
            (element
              name: (identifier))))))))

==================
element open/close with inline text as a return value
==================

package main
func render() gsx.Node {
	return <div>inline JSX</div>
}

---

(source_file
  (package_clause
    (package_identifier))
  (function_declaration
    name: (identifier)
    parameters: (parameter_list)
    result: (qualified_type
      package: (package_identifier)
      name: (type_identifier))
    body: (block
      (statement_list
        (return_statement
          (expression_list
            (element
              open_name: (identifier)
              body: (element_text)
              close_name: (identifier))))))))

==================
element as a call argument
==================

package main
func f() {
	wrap(<Icon/>)
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
        (expression_statement
          (call_expression
            function: (identifier)
            arguments: (argument_list
              (element
                name: (identifier)))))))))

==================
element as a positional composite-literal value
==================

package main
func f() {
	var x = []gsx.Node{<Icon/>, <div/>}
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
              (composite_literal
                type: (slice_type
                  element: (qualified_type
                    package: (package_identifier)
                    name: (type_identifier)))
                body: (literal_value
                  (literal_element
                    (element
                      name: (identifier)))
                  (literal_element
                    (element
                      name: (identifier))))))))))))

==================
element as a keyed struct-literal field
==================

package main
func f() {
	var x = Config{Node: <Icon/>}
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
              (composite_literal
                type: (type_identifier)
                body: (literal_value
                  (keyed_element
                    key: (literal_element
                      (identifier))
                    value: (literal_element
                      (element
                        name: (identifier)))))))))))))

==================
element as a plain assignment target value
==================

package main
func f() {
	var x gsx.Node
	x = <Icon/>
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
            type: (qualified_type
              package: (package_identifier)
              name: (type_identifier))))
        (assignment_statement
          left: (expression_list
            (identifier))
          right: (expression_list
            (element
              name: (identifier))))))))

==================
regression: spaced less-than stays a comparison, not markup
==================

package main
func cmp(a int, b int) bool {
	return a < b
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

==================
regression: less-than-or-equal stays a comparison
==================

package main
func cmp(a int, b int) bool {
	return a <= b
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

==================
regression: channel receive stays untouched
==================

package main
func recv(ch chan int) int {
	return <-ch
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
        type: (channel_type
          value: (type_identifier))))
    result: (type_identifier)
    body: (block
      (statement_list
        (return_statement
          (expression_list
            (unary_expression
              operand: (identifier))))))))

==================
regression: left shift stays untouched
==================

package main
func shl(a int, b int) int {
	return a << b
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

This exact content (input + expected trees) was machine-verified — written
by hand, run once to confirm real diffs were purely the `statement_list`
wrapper Go's grammar inserts around block statements, then corrected via
`tree-sitter test --update` and re-run to 13/13 passing — against the real
`tree-sitter-go@0.25.0` package, not a guess.

- [ ] **Step 4: Run the corpus and confirm 13/13 pass**

```bash
npx tree-sitter test --file-name phase1_elements.txt
```

Expected: `Total parses: 13; successful parses: 13; failed parses: 0;
success percentage: 100.00%`.

- [ ] **Step 5: Confirm the full test suite (legacy-relocated + new) is still clean**

```bash
npx tree-sitter test
git status --short
```

Expected: same 13/13 result (the legacy files are no longer under
`test/corpus/`, so this is identical to Step 4); `git status --short` shows
only the intended changes (`grammar.js` modified, `test/corpus/`
recreated with `phase1_elements.txt`, generated `src/*` files updated).

- [ ] **Step 6: Fresh-clone verification**

Simulate a new contributor / CI from scratch — this is a genuinely
different failure mode than "works in my already-`npm install`ed sandbox"
(e.g. an uncommitted lockfile entry, a `.gitignore` hole):

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

Expected: all four commands succeed; `tree-sitter test` reports `Total
parses: 13; successful parses: 13; failed parses: 0`. Clean up afterward:

```bash
cd /Users/jackieli/personal/gsxhq/tree-sitter-gsx
rm -rf /tmp/tree-sitter-gsx-freshclone
```

If any step fails here that didn't fail in the working branch (e.g.
`package-lock.json` wasn't committed, or a generated `src/` file was
missed), fix it in this task before proceeding — this is exactly the class
of bug this step exists to catch.

- [ ] **Step 7: Confirm generated `src/` output is committed**

```bash
git status --short -- src/
git add -A
git status --short
```

Expected: `src/grammar.json`, `src/node-types.json`, `src/parser.c` (all
regenerated by Step 2) show as modified/staged; nothing under `src/`
remains untracked or unstaged after `git add -A`.

- [ ] **Step 8: Write the short branch note required by the spec's done criteria**

Create `NOTES.md` at the repo root:

```markdown
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
```

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat(grammar): unified Go+gsx grammar skeleton — element/fragment as native Go expressions

Composes tree-sitter-go (real npm package, not a copied fork) with
element/fragment added to _expression. Zero ERROR nodes on the case that
motivated this work: func render() gsx.Node { return <div>inline JSX</div> }
parses as one clean element node, no injected-Go split/error. 13/13 Phase 1
corpus cases pass, verified from a fresh clone. No component/attribute/hole
syntax yet — see docs/superpowers/specs/2026-07-08-unified-go-grammar-phase1-design.md."
```

---

## Self-Review Notes (already applied above)

- **Spec coverage:** every "In scope" bullet from the spec has a
  corresponding step — dependency pin (Task 1 Step 4), element/fragment
  rules + `_expression` wiring (Task 2 Step 1), all six named expression
  positions in the corpus (Task 2 Step 3: var-decl ×2 forms, return ×2
  forms, call-argument, composite-literal-field, struct-field,
  assignment), the `<`/`<=`/`<-`/`<<` regression set (Task 2 Step 3, last
  four cases), fresh-clone verification (Task 2 Step 6). "Scanner: none
  needed" is verified, not assumed (Global Constraints, backed by the
  empirical stale-scanner.c test).
- **Placeholder scan:** no TBD/TODO; every code block is the actual,
  tested content (the corpus file is the literal machine-verified output,
  not a hand-guessed tree).
- **Type/name consistency:** `element`'s fields (`name` /
  `open_name`/`body`/`close_name`) and `fragment`'s field (`body`) are
  used identically across Task 2's grammar code and its corpus file, and
  flagged in Task 2's Interfaces block as the surface Phase 2 will extend.
