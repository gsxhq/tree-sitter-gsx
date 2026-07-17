package demo

import (
	"errors"

	"github.com/gsxhq/gsx"
)

func pick(c string) (string, error) {
	if c == "" {
		return "", errors.New("pick: empty input")
	}
	return c, nil
}

func show(s gsx.RawCSS) gsx.Node { return gsx.Raw(string(s)) }

component Page(c string) {
	<div>{ show(css`color:@{pick(c)}`) }</div>
}
