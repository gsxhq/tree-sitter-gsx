#include "tree_sitter/parser.h"
#include <stdbool.h>

enum TokenType {
  EMBEDDED_TEXT,
  EMBEDDED_TEXT_DQ,
  RAW_TEXT,
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
    if (l->lookahead == '`') {
      l->mark_end(l);
      return consumed;
    }
    if (l->lookahead == '@') {
      l->mark_end(l);
      advance(l);
      if (l->lookahead == '{') return consumed;
      consumed = true;
      continue;
    }
    if (l->lookahead == '\\') {
      // A backslash escapes the next char as literal text: `\`` (escaped
      // delimiter), `\@` (so `\@{` is literal `@{`, not a hole), `\\`
      // (escaped backslash). Consuming `\X` as a PAIR also gives correct
      // backslash-parity: `\\` + backtick leaves the backtick unescaped so
      // it terminates. Matches the real gsx parser (parser/attrs.go
      // embeddedDelimEscaped/embeddedAtBraceEscaped).
      advance(l);
      if (!l->eof(l)) advance(l);
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
    if (l->lookahead == '"') {
      l->mark_end(l);
      return consumed;
    }
    if (l->lookahead == '@') {
      l->mark_end(l);
      advance(l);
      if (l->lookahead == '{') return consumed;
      consumed = true;
      continue;
    }
    if (l->lookahead == '\\') {
      // `\X` consumed as a pair — see scan_embedded_text for the rationale
      // (escaped delimiter/`@`, correct backslash-parity).
      advance(l);
      if (!l->eof(l)) advance(l);
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

// ── raw_text (inside <script>/<style>) ──────────────────────────────────
// Lifted near-verbatim from the pre-existing shipped scanner. Raw text that
// stops BEFORE an '@{' interpolation hole or a matching </script>/</style>
// close tag; a bare '@' and a non-close '<' are ordinary raw content.
static bool is_ident_char(int32_t c) {
  return (c == '_' || (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9'));
}

static int peek_raw(TSLexer *l, int32_t *buf, int maxn) {
  int n = 0;
  while (!l->eof(l) && n < maxn) {
    int32_t c = l->lookahead;
    if (c == '<') break;
    buf[n++] = c;
    advance(l);
  }
  return n;
}

static bool matches_close_tag(const int32_t *buf, int len, const char *tag) {
  int j = 0;
  while (tag[j]) {
    if (j >= len) return false;
    int32_t c = buf[j];
    if (c >= 'A' && c <= 'Z') c += 32;
    if (c != (int32_t)(unsigned char)tag[j]) return false;
    j++;
  }
  if (j < len && is_ident_char(buf[j])) return false;
  return true;
}

static bool scan_raw_text(TSLexer *l) {
  bool consumed = false;
  while (!l->eof(l)) {
    if (l->lookahead == '@') {
      l->mark_end(l);
      advance(l);
      if (l->lookahead == '{') return consumed;
      consumed = true;
      continue;
    }
    if (l->lookahead == '<') {
      l->mark_end(l);
      advance(l);
      if (l->lookahead != '/') {
        consumed = true;
        continue;
      }
      advance(l);
      int32_t peek[7];
      int peek_len = peek_raw(l, peek, 7);
      if (matches_close_tag(peek, peek_len, "script") ||
          matches_close_tag(peek, peek_len, "style")) {
        return consumed;
      }
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
  if (valid[RAW_TEXT]) {
    if (scan_raw_text(l)) { l->result_symbol = RAW_TEXT; return true; }
  }
  return false;
}
