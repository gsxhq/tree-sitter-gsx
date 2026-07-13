package views

import "corpustest/cases/renderers_script_hole/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Tag(val pg.Text) {
	<script>const s = "x@{ val }";</script>
}
