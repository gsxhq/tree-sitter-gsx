#!/usr/bin/env node
// test-authoritative.mjs
//
// Parse gate over the vendored authoritative corpus
// (`test/corpus-authoritative/**/*.gsx`, synced by
// sync-authoritative-corpus.mjs from the gsx repo). Asserts every file
// parses with ZERO tree-sitter ERROR/MISSING nodes. This is the
// feature-completeness/regression gate against the real language syntax.
//
// Usage:  node scripts/test-authoritative.mjs   (or: npm run test:authoritative)
// Requires the parser to be generated (`npx tree-sitter generate`).

import { execFileSync } from 'node:child_process'
import { readdirSync } from 'node:fs'
import { join, resolve, dirname, relative } from 'node:path'
import { fileURLToPath } from 'node:url'

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const corpusDir = join(repoRoot, 'test', 'corpus-authoritative')
const cli = join(repoRoot, 'node_modules', '.bin', 'tree-sitter')

function listGsx(dir) {
  const out = []
  for (const ent of readdirSync(dir, { withFileTypes: true })) {
    const p = join(dir, ent.name)
    if (ent.isDirectory()) out.push(...listGsx(p))
    else if (ent.name.endsWith('.gsx')) out.push(p)
  }
  return out
}

const files = listGsx(corpusDir).sort()
let failed = []
for (const f of files) {
  // `tree-sitter parse -q` exits non-zero on any ERROR/MISSING node.
  try {
    execFileSync(cli, ['parse', '-q', f], { cwd: repoRoot, stdio: 'ignore' })
  } catch {
    failed.push(relative(repoRoot, f))
  }
}

console.log(`authoritative parse gate: ${files.length - failed.length}/${files.length} clean`)
if (failed.length) {
  console.error(`\n${failed.length} file(s) parsed with ERROR/MISSING nodes:`)
  for (const f of failed) console.error(`  ${f}`)
  console.error(`\nEither the grammar has a gap, or (if this is intentionally`)
  console.error(`invalid gsx) add it to the SKIP set in`)
  console.error(`scripts/sync-authoritative-corpus.mjs and re-sync.`)
  process.exit(1)
}
