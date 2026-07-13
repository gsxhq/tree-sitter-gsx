package views

import (
	"errors"

	"corpustest/cases/renderers_tuple_then_renderer/pg"
)

func load(s string, valid bool) (pg.Text, error) {
	if s == "" {
		return pg.Text{}, errors.New("load: empty input")
	}
	return pg.Text{String: s, Valid: valid}, nil
}

component Tag(s string, valid bool) {
	<div>{ load(s, valid) }</div>
}
