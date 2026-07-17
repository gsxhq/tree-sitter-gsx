#!/usr/bin/env node
// sync-authoritative-corpus.mjs
//
// Vendors the `input.gsx` snippets from the sibling gsx repo's authoritative
// codegen corpus (`internal/corpus/testdata/cases/**/*.txtar`) into
// `test/corpus-authoritative/` as standalone `.gsx` files, so tree-sitter-gsx
// has a self-contained parse gate against the real language syntax.
//
// The gsx corpus is a *codegen* corpus: its "error" cases are type/semantic
// errors with syntactically-valid input, so (nearly) every input.gsx should
// parse with zero tree-sitter ERROR/MISSING nodes. A parse gate over these
// catches grammar gaps systematically (the way a hand-picked corpus can't).
//
// Usage:  node scripts/sync-authoritative-corpus.mjs
// gsx repo location: $GSX_REPO, else `<tree-sitter-gsx main checkout>/../gsx`.
//
// A small SKIP set excludes cases that are intentionally syntactically
// invalid (parser error-recovery fixtures) — these SHOULD fail to parse, so
// they don't belong in a zero-ERROR gate. Add to it as such cases appear.

import { execFileSync } from 'node:child_process'
import { readFileSync, writeFileSync, mkdirSync, rmSync, readdirSync } from 'node:fs'
import { join, resolve, dirname, relative } from 'node:path'
import { fileURLToPath } from 'node:url'

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..')

function resolveGsxRepo() {
  if (process.env.GSX_REPO) return resolve(process.env.GSX_REPO)
  // From a worktree, git-common-dir points at the main checkout's .git.
  const commonDir = execFileSync('git', ['rev-parse', '--path-format=absolute', '--git-common-dir'], {
    cwd: repoRoot, encoding: 'utf8',
  }).trim()
  const mainCheckout = dirname(commonDir) // .../tree-sitter-gsx
  return resolve(mainCheckout, '..', 'gsx')
}

// Cases excluded from the zero-ERROR parse gate, keyed by
// "<category>/<basename>" (no .txtar). Two kinds:
//
// (A) Intentionally syntactically-invalid fixtures — gsx's own PARSER
//     rejects them (leading spread, missing comma, the removed `?` try
//     marker, empty splat, bad attr name, parser error-recovery `eNN_*`
//     tests). tree-sitter correctly ERRORs too, so they don't belong in a
//     zero-ERROR gate. (Verified against each case's diagnostics.golden.)
//
// Only kind (A) remains: intentionally syntactically-invalid fixtures that
// gsx's own PARSER rejects — tree-sitter correctly ERRORs too, so they don't
// belong in a zero-ERROR gate. (Every one verified against its
// diagnostics.golden.) The earlier "(B) niche limitations" are now all
// implemented and back in the gate.
const SKIP = new Set([
  'attrs/spread_leading_rejected',
  'class/missing_comma_rejected',
  'components/child_prop_try_error',
  'control_flow/value_form_guard_rejected',
  'control_flow/value_form_trailing_rejected',
  'goblock-literal/diag_whole_pipe_goblock',
  'goexpr-css-literal/diag_whole_pipe_interp',
  'goexpr-f-literal/diag_whole_pipe_toplevel',
  'goexpr-f-literal/js_value_unsupported',
  'goexpr-js-literal/diag_nested_whole_pipe',
  'parser/18_pipeline_attr_try',
  'parser/e02_unterminated_interp',
  'parser/e03_bad_attr_name',
  'parser/e04_nonspread_brace',
  'parser/e05_empty_pipe_stage',
  'pipeerr/try_marker_still_rejected',
  'pipelines/attr_try_stage_rejected',
  'pipelines/try_rejected',
  'props/empty_spread_rejected',
  'props/non_attrs_spread_with_children_rejected',
  'props/non_attrs_spread_with_prop_rejected',
  'style/block_try_rejected',
])

// Recursively list *.txtar under a dir.
function listTxtar(dir) {
  const out = []
  for (const ent of readdirSync(dir, { withFileTypes: true })) {
    const p = join(dir, ent.name)
    if (ent.isDirectory()) out.push(...listTxtar(p))
    else if (ent.name.endsWith('.txtar')) out.push(p)
  }
  return out
}

// Extract the `-- input.gsx --` section from a txtar file.
function extractInputGsx(txtar) {
  const lines = readFileSync(txtar, 'utf8').split('\n')
  const start = lines.findIndex((l) => l === '-- input.gsx --')
  if (start === -1) return null
  const body = []
  for (let i = start + 1; i < lines.length; i++) {
    if (/^-- .* --$/.test(lines[i])) break
    body.push(lines[i])
  }
  return body.join('\n').replace(/\n+$/, '') + '\n'
}

const gsxRepo = resolveGsxRepo()
const casesDir = join(gsxRepo, 'internal', 'corpus', 'testdata', 'cases')
const outDir = join(repoRoot, 'test', 'corpus-authoritative')

let txtars
try {
  txtars = listTxtar(casesDir)
} catch (e) {
  console.error(`Cannot read gsx corpus at ${casesDir}`)
  console.error(`Set GSX_REPO to the gsx checkout (currently resolved: ${gsxRepo}).`)
  process.exit(1)
}

// Clean and rewrite the vendored dir so deletions in the source propagate.
rmSync(outDir, { recursive: true, force: true })
mkdirSync(outDir, { recursive: true })

let written = 0, skippedNoInput = 0, skippedExcluded = 0
for (const txtar of txtars) {
  const rel = relative(casesDir, txtar).replace(/\.txtar$/, '') // e.g. class/value_if
  if (SKIP.has(rel)) { skippedExcluded++; continue }
  const input = extractInputGsx(txtar)
  if (input == null) { skippedNoInput++; continue }
  const outPath = join(outDir, rel + '.gsx')
  mkdirSync(dirname(outPath), { recursive: true })
  writeFileSync(outPath, input)
  written++
}

// A README so the vendored dir explains itself.
writeFileSync(join(outDir, 'README.md'),
  `# Authoritative corpus (vendored parse gate)\n\n` +
  `\`.gsx\` snippets synced from the sibling gsx repo's codegen corpus\n` +
  `(\`internal/corpus/testdata/cases/**/*.txtar\`, the canonical syntax\n` +
  `reference) by \`scripts/sync-authoritative-corpus.mjs\`. Re-run that script\n` +
  `(with the gsx checkout at \`../gsx\` or \`$GSX_REPO\`) to refresh.\n\n` +
  `These are a **parse gate**: every file must parse with zero tree-sitter\n` +
  `ERROR/MISSING nodes (\`npm run test:authoritative\`). They are NOT hand-\n` +
  `maintained and have no tree goldens — they exist to catch grammar gaps\n` +
  `against the full real-world syntax surface. Do not edit by hand.\n`)

console.log(`synced ${written} input.gsx snippets → test/corpus-authoritative/`)
console.log(`  (skipped: ${skippedNoInput} without input.gsx, ${skippedExcluded} excluded)`)
console.log(`  source: ${casesDir}`)
