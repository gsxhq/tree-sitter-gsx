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
