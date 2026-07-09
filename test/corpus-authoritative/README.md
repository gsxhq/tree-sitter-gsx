# Authoritative corpus (vendored parse gate)

`.gsx` snippets synced from the sibling gsx repo's codegen corpus
(`internal/corpus/testdata/cases/**/*.txtar`, the canonical syntax
reference) by `scripts/sync-authoritative-corpus.mjs`. Re-run that script
(with the gsx checkout at `../gsx` or `$GSX_REPO`) to refresh.

These are a **parse gate**: every file must parse with zero tree-sitter
ERROR/MISSING nodes (`npm run test:authoritative`). They are NOT hand-
maintained and have no tree goldens — they exist to catch grammar gaps
against the full real-world syntax surface. Do not edit by hand.
