#include "tree_sitter/parser.h"
#include <string.h>

// Token order must match externals array in grammar.js.
enum TokenType { GO_TEXT, RAW_TEXT, PIPE, GO_COND_TEXT, GO_INTERP_TEXT, GO_SPREAD_TEXT };

void *tree_sitter_gsx_external_scanner_create(void) { return NULL; }
void tree_sitter_gsx_external_scanner_destroy(void *p) {}
unsigned tree_sitter_gsx_external_scanner_serialize(void *p, char *b) { return 0; }
void tree_sitter_gsx_external_scanner_deserialize(void *p, const char *b, unsigned n) {}

static void advance(TSLexer *l) { l->advance(l, false); }
static void skip_ws(TSLexer *l) { l->advance(l, true); }

// Returns true if c is an identifier character (a-z, A-Z, 0-9, _).
static bool is_ident_char(int32_t c) {
  return (c == '_' || (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9'));
}

// ─────────────────────────────────────────────────────────────────────────────
// Scan a go_text / go_cond_text / go_interp_text / go_spread_text token.
//
// Parameters:
//   stop_open_brace  — stop at depth-0 '{' (go_cond_text mode).
//   refuse_keywords  — refuse when content (after optional WS) begins with a
//                      Go control-flow keyword (if / for / switch).  Set for
//                      GO_INTERP_TEXT and GO_SPREAD_TEXT so that `{ if … }`
//                      becomes a control_flow node rather than an interpolation
//                      or spread, and `{ if … }` in attr position becomes a
//                      conditional_attribute rather than a spread_attribute.
//   stop_spread_dots — stop at depth-0 '...' (go_spread_text mode), allowing
//                      the grammar rule seq('{', go_spread_expr, '...', '}') to
//                      match the trailing literal '...'.
//
// Keyword-refusal with multi-char lookahead:
//   TSLexer provides only one-char lookahead (l->lookahead).  To detect a
//   keyword we need to consume up to 6 chars ("switch") speculatively.  We
//   accumulate them in a local peek[] buffer.
//
//   • If a keyword is detected  → return false.  tree-sitter resets the lexer
//     to the start of this call (discarding all advances); the internal lexer
//     then matches the keyword for the control_flow rule.
//
//   • If no keyword             → the peeked chars are already consumed from
//     the TSLexer; they cannot be "un-advanced".  We feed them into the main
//     scan loop via a replay mechanism so they end up in the emitted token.
//
// Peek stop conditions: stop peeking at any delimiter that cannot be part of a
// bare keyword (`{`, `}`, `?`, `<`, whitespace, quotes, `(`, `)`).  This
// ensures that these chars are never "stuck" in the replay buffer where
// mark_end semantics become tricky.
// ─────────────────────────────────────────────────────────────────────────────

#define PEEK_BUF_CAP 16

static bool scan_go_text_impl(TSLexer *l, bool stop_open_brace, bool refuse_keywords, bool stop_spread_dots) {
  int32_t peek[PEEK_BUF_CAP];
  int     peek_len = 0;

  if (refuse_keywords) {
    // Skip leading whitespace (these become extras on emit, discarded on false).
    while (l->lookahead == ' '  || l->lookahead == '\t' ||
           l->lookahead == '\r' || l->lookahead == '\n') {
      skip_ws(l);
    }
    if (l->eof(l)) return false;  // nothing to emit

    // In attribute values, {js`...`} and {css`...`} are explicit embedded
    // language literals, not Go expressions. Refuse here so the internal
    // embedded_attribute rule can match them.
    if (l->lookahead == 'j') {
      peek[peek_len++] = 'j';
      advance(l);
      if (l->lookahead == 's') {
        peek[peek_len++] = 's';
        advance(l);
        if (l->lookahead == '`') return false;
      }
    } else if (l->lookahead == 'c') {
      peek[peek_len++] = 'c';
      advance(l);
      if (l->lookahead == 's') {
        peek[peek_len++] = 's';
        advance(l);
        if (l->lookahead == 's') {
          peek[peek_len++] = 's';
          advance(l);
          if (l->lookahead == '`') return false;
        }
      }
    }

    // If the first non-whitespace char is '<', check if it's markup:
    //   - '<' followed by a letter → tag start like <div
    //   - '<' followed by '>'      → fragment <>
    // In those cases, refuse so the markup alternative in _hole_body wins.
    // But '<' followed by '-' (channel receive <-ch) or anything else is
    // valid Go and should be scanned normally.
    if (l->lookahead == '<') {
      advance(l);  // consume '<' speculatively
      int32_t next = l->lookahead;
      bool is_markup = (next == '>' ||
                        (next >= 'A' && next <= 'Z') ||
                        (next >= 'a' && next <= 'z'));
      if (is_markup) return false;
      // Not markup — replay '<' plus next char via peek buffer.
      peek[peek_len++] = '<';
      if (!l->eof(l)) {
        peek[peek_len++] = next;
        advance(l);
      }
    }

    // Consume up to PEEK_BUF_CAP chars that cannot be inside a bare keyword.
    // Stop at delimiters so they stay in the lexer for the main loop.
    // NOTE: '|' is excluded from the peek buffer so that |> detection always
    // happens from the live lexer (where mark_end can correctly point before '|').
    // NOTE: '.' is excluded when stop_spread_dots is set so that '...' is never
    // consumed into the peek buffer and always reaches the main loop '.' case.
    while (!l->eof(l) && peek_len < PEEK_BUF_CAP) {
      int32_t c = l->lookahead;
      if (c == ' ' || c == '\t' || c == '\r' || c == '\n' ||
          c == '<' || c == '{' || c == '}' || c == '?' ||
          c == '(' || c == ')' || c == '"' || c == '\'' || c == '`' ||
          c == '|' || (stop_spread_dots && c == '.')) {
        break;
      }
      peek[peek_len++] = c;
      advance(l);
    }

    // Detect keyword in peek[].
    bool is_kw = false;
    if (peek_len >= 2 && peek[0]=='i' && peek[1]=='f' &&
        (peek_len == 2 || !is_ident_char(peek[2]))) {
      is_kw = true;
    } else if (peek_len >= 3 &&
               peek[0]=='f' && peek[1]=='o' && peek[2]=='r' &&
               (peek_len == 3 || !is_ident_char(peek[3]))) {
      is_kw = true;
    } else if (peek_len >= 6 &&
               peek[0]=='s' && peek[1]=='w' && peek[2]=='i' &&
               peek[3]=='t' && peek[4]=='c' && peek[5]=='h' &&
               (peek_len == 6 || !is_ident_char(peek[6]))) {
      is_kw = true;
    }
    if (is_kw) return false;  // let internal lexer match the keyword
    // No keyword — replay peek[] in main loop below.
  }

  // ── Main scan loop ─────────────────────────────────────────────────────────
  // Replays peek[0..peek_len) before reading directly from the lexer.
  //
  // IMPORTANT: after the peek phase the TSLexer position is already PAST the
  // peeked chars.  mark_end(l) therefore always marks AFTER the peeked region.
  // Since our peek stop conditions ensure that no special stop-char ({, }, ?)
  // is ever in peek[], the stop-condition branches in the main loop only fire
  // for chars read directly from the lexer — at which point mark_end is valid.
  int     peek_pos    = 0;
  int     depth       = 0;   // brace depth
  int     paren_depth = 0;   // paren and bracket depth — gates |> splitting
  bool    consumed  = false;
  int32_t prev_c    = 0;

#define CUR()    (peek_pos < peek_len ? peek[peek_pos] : l->lookahead)
#define IS_EOF() (peek_pos >= peek_len && l->eof(l))
#define ADV() do {                            \
    if (peek_pos < peek_len) { peek_pos++; } \
    else { advance(l); }                      \
  } while(0)

  for (;;) {
    if (IS_EOF()) break;
    int32_t c = CUR();

    // Detect `component` keyword at depth 0 (needs left word boundary).
    if (depth == 0 && c == 'c' && !is_ident_char(prev_c)) {
      // mark_end: if still in peek buf, mark_end is already past peeked chars
      // (the lexer consumed them in the peek phase).  That is fine: if we stop
      // here the token ends before 'c' which is peeked → the peeked chars
      // before 'c' were already emitted as part of the token up to mark_end.
      // Actually: mark_end BEFORE consuming 'c' means token ends just before c.
      if (peek_pos >= peek_len) l->mark_end(l);
      // else: mark_end already past peeked region; 'c' is peeked, previous
      // peeked chars are already implicitly inside the token boundary.
      // We cannot finely control mark_end inside the peek region, so just
      // set it now (at the lexer's current position = after all peeked chars).
      else l->mark_end(l); // same call, just for clarity

      const char *kw = "component";
      size_t i = 0;
      while (kw[i]) {
        if (IS_EOF() || (int32_t)(unsigned char)kw[i] != CUR()) break;
        ADV(); i++;
      }
      if (kw[i] == 0 && !is_ident_char(CUR())) {
        return consumed;
      }
      prev_c = (i > 0) ? (int32_t)(unsigned char)kw[i-1] : c;
      consumed = true;
      if (peek_pos >= peek_len) l->mark_end(l);
      continue;
    }

    switch (c) {
      case '"': {
        ADV();
        while (!IS_EOF() && CUR() != '"') { if (CUR()=='\\') ADV(); ADV(); }
        if (!IS_EOF()) ADV();
        break;
      }
      case '`': {
        ADV();
        while (!IS_EOF() && CUR() != '`') ADV();
        if (!IS_EOF()) ADV();
        break;
      }
      case '\'': {
        ADV();
        while (!IS_EOF() && CUR() != '\'') { if (CUR()=='\\') ADV(); ADV(); }
        if (!IS_EOF()) ADV();
        break;
      }
      case '/': {
        ADV();
        if (!IS_EOF()) {
          if (CUR() == '/') { while (!IS_EOF() && CUR()!='\n') ADV(); }
          else if (CUR() == '*') {
            ADV();
            int32_t pbc = 0;
            while (!IS_EOF() && !(pbc=='*' && CUR()=='/')) { pbc=CUR(); ADV(); }
            if (!IS_EOF()) ADV();
          }
        }
        break;
      }
      case '{': {
        if (stop_open_brace && depth == 0) { l->mark_end(l); return consumed; }
        depth++; ADV();
        break;
      }
      case '|': {
        // stop at a top-level |> so the PIPE token can match.
        // "top-level" means outside all braces, parens, and brackets.
        // '|' is excluded from the peek buffer (see peek-fill stop conditions),
        // so this case always fires from the live lexer (peek_pos >= peek_len).
        if (depth == 0 && paren_depth == 0) {
          l->mark_end(l);
          advance(l); // consume '|' speculatively
          if (l->lookahead == '>') {
            // it's a |> pipe — stop BEFORE it (mark_end set before '|')
            return consumed;
          }
          // not |> — just a bare '|', include it in the token
          consumed = true;
          l->mark_end(l);
          continue;
        }
        ADV();
        break;
      }
      case '(': case '[': {
        paren_depth++; ADV();
        break;
      }
      case ')': case ']': {
        if (paren_depth > 0) paren_depth--;
        ADV();
        break;
      }
      case '?': {
        if (depth == 0) { l->mark_end(l); return consumed; }
        ADV();
        break;
      }
      case '.': {
        // In go_spread_text mode: stop at depth-0 '...' so the grammar rule
        // seq('{', go_spread_expr, '...', '}') can match the literal '...'.
        // A single '.' or '..' is valid Go (field access, float literal) and
        // must NOT split — only a depth-0 triple-dot is a stop.
        // This case fires only from the live lexer (peek_pos >= peek_len) since
        // '.' is not a peek-stop char, but we guard anyway.
        if (stop_spread_dots && depth == 0 && paren_depth == 0 && peek_pos >= peek_len) {
          l->mark_end(l);       // candidate end: just before first '.'
          advance(l);           // consume first '.'
          if (l->lookahead == '.') {
            advance(l);         // consume second '.'
            if (l->lookahead == '.') {
              // it IS '...' — stop before it (mark_end already set)
              return consumed;
            }
            // was '..' — not a splat; include both dots and continue
            consumed = true;
            l->mark_end(l);
            continue;
          }
          // was single '.' — include it and continue
          consumed = true;
          l->mark_end(l);
          continue;
        }
        ADV();
        break;
      }
      case '}': {
        if (depth == 0) { l->mark_end(l); return consumed; }
        depth--; ADV();
        break;
      }
      default:
        ADV();
        break;
    }
    prev_c = c;
    consumed = true;
    if (peek_pos >= peek_len) l->mark_end(l);
  }
  if (peek_pos >= peek_len) l->mark_end(l);
  return consumed;

#undef CUR
#undef IS_EOF
#undef ADV
}

static bool scan_pipe(TSLexer *l) {
  if (l->lookahead != '|') return false;
  advance(l);
  if (l->lookahead != '>') return false;
  advance(l);
  l->mark_end(l);
  return true;
}

// Peek up to `maxn` chars from the lexer into buf[], stopping early if a '<'
// is encountered (so the main loop can re-check it as a potential close tag).
// Returns the number of chars placed in buf[].  All chars placed are already
// advanced past in the lexer.
static int peek_raw(TSLexer *l, int32_t *buf, int maxn) {
  int n = 0;
  while (!l->eof(l) && n < maxn) {
    int32_t c = l->lookahead;
    if (c == '<') break; // stop before '<' so main loop can handle it
    buf[n++] = c;
    advance(l);
  }
  return n;
}

// Case-insensitive ASCII match: does buf[0..len) start with the NUL-terminated
// string tag, followed by a non-ident char (or end of buffer)?
static bool matches_close_tag(const int32_t *buf, int len, const char *tag) {
  int j = 0;
  while (tag[j]) {
    if (j >= len) return false;
    int32_t c = buf[j];
    if (c >= 'A' && c <= 'Z') c += 32; // tolower
    if (c != (int32_t)(unsigned char)tag[j]) return false;
    j++;
  }
  // must be followed by non-ident char or end of buffer
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
      // Mark end BEFORE '<' — if we stop here raw_text ends before '<'.
      l->mark_end(l);
      advance(l); // consume '<'
      if (l->lookahead != '/') {
        // Plain '<' (not followed by '/') — include it and keep going.
        consumed = true;
        continue;
      }
      // We see '</'. Peek the tag name chars (up to 7), stopping at '<'.
      advance(l); // consume '/'
      int32_t peek[7];
      int peek_len = peek_raw(l, peek, 7);
      // Check for </script or </style (case-insensitive).
      if (matches_close_tag(peek, peek_len, "script") ||
          matches_close_tag(peek, peek_len, "style")) {
        // Terminate raw_text BEFORE the '<' (mark_end was set there).
        return consumed;
      }
      // Not a matching close tag: '</', and the peeked chars are all raw content.
      // mark_end is currently before '<'; advance it past everything consumed.
      consumed = true;
      l->mark_end(l);
      // The main loop continues from wherever the lexer now sits (after peek_raw
      // stopped — either EOF, a '<', or 7 chars consumed).
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
  if (valid[PIPE]) {
    if (scan_pipe(l)) { l->result_symbol = PIPE; return true; }
  }
  if (valid[GO_COND_TEXT]) {
    if (scan_go_text_impl(l, true, false, false)) { l->result_symbol = GO_COND_TEXT; return true; }
  }
  if (valid[GO_INTERP_TEXT]) {
    if (scan_go_text_impl(l, false, true, false)) { l->result_symbol = GO_INTERP_TEXT; return true; }
  }
  if (valid[GO_SPREAD_TEXT]) {
    if (scan_go_text_impl(l, false, true, true)) { l->result_symbol = GO_SPREAD_TEXT; return true; }
  }
  if (valid[RAW_TEXT]) {
    if (scan_raw_text(l)) { l->result_symbol = RAW_TEXT; return true; }
  }
  if (valid[GO_TEXT]) {
    if (scan_go_text_impl(l, false, false, false)) { l->result_symbol = GO_TEXT; return true; }
  }
  return false;
}
