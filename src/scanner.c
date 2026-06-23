#include "tree_sitter/parser.h"
#include <string.h>

enum TokenType { GO_TEXT, RAW_TEXT, PIPE };

void *tree_sitter_gsx_external_scanner_create(void) { return NULL; }
void tree_sitter_gsx_external_scanner_destroy(void *p) {}
unsigned tree_sitter_gsx_external_scanner_serialize(void *p, char *b) { return 0; }
void tree_sitter_gsx_external_scanner_deserialize(void *p, const char *b, unsigned n) {}

static void advance(TSLexer *l) { l->advance(l, false); }

// Returns true if the upcoming input is the `component` keyword at a word boundary.
static bool at_component_kw(TSLexer *l) {
  const char *kw = "component";
  // NOTE: TSLexer cannot peek multiple chars without consuming; this helper is
  // only correct when called at a position the scanner controls. We instead detect
  // `component` by consuming into go_text and bailing — see scan_go_text.
  return false; // unused; real logic in scan_go_text
}

// Consume Go source until brace-depth 0 AND the next token would start a `component`
// declaration, or EOF. Respects strings/runes/comments/braces. Marks end before the
// `component` keyword. Returns true if it consumed at least one byte.
static bool scan_go_text(TSLexer *l) {
  int depth = 0;
  bool consumed = false;
  for (;;) {
    if (l->eof(l)) break;
    int32_t c = l->lookahead;

    // At depth 0 and a word boundary, check for `component`.
    if (depth == 0 && c == 'c') {
      l->mark_end(l);            // candidate stop point (before `component`)
      // Try to match the keyword by consuming; if it matches and is followed by a
      // non-identifier char, stop here (do not include `component`).
      const char *kw = "component";
      size_t i = 0;
      while (kw[i] && (int32_t)kw[i] == l->lookahead) { advance(l); i++; }
      if (kw[i] == 0) {
        int32_t after = l->lookahead;
        bool ident = (after=='_'||(after>='A'&&after<='Z')||(after>='a'&&after<='z')||(after>='0'&&after<='9'));
        if (!ident) {
          // `component` keyword found at depth 0: stop BEFORE it (mark_end already set).
          return consumed;       // go_text ends just before `component`
        }
      }
      // Not the keyword (or an identifier like `components`): the consumed chars are
      // part of go_text; continue. (mark_end will be reset by the normal path below.)
      consumed = true;
      continue;
    }

    switch (c) {
      case '"': { advance(l); while (!l->eof(l) && l->lookahead!='"') { if (l->lookahead=='\\') advance(l); advance(l);} if(!l->eof(l)) advance(l); break; }
      case '`': { advance(l); while (!l->eof(l) && l->lookahead!='`') advance(l); if(!l->eof(l)) advance(l); break; }
      case '\'':{ advance(l); while (!l->eof(l) && l->lookahead!='\'') { if (l->lookahead=='\\') advance(l); advance(l);} if(!l->eof(l)) advance(l); break; }
      case '/': { advance(l); if (l->lookahead=='/') { while(!l->eof(l)&&l->lookahead!='\n') advance(l);} else if (l->lookahead=='*'){ advance(l); int32_t prev=0; while(!l->eof(l)&&!(prev=='*'&&l->lookahead=='/')){prev=l->lookahead;advance(l);} if(!l->eof(l)) advance(l);} break; }
      case '{': depth++; advance(l); break;
      case '}': if (depth>0) depth--; advance(l); break;
      default: advance(l); break;
    }
    consumed = true;
    l->mark_end(l);
  }
  l->mark_end(l);
  return consumed;
}

bool tree_sitter_gsx_external_scanner_scan(void *payload, TSLexer *l, const bool *valid) {
  if (valid[GO_TEXT]) {
    if (scan_go_text(l)) { l->result_symbol = GO_TEXT; return true; }
  }
  return false; // RAW_TEXT (Task 8), PIPE (Task 9) added later
}
