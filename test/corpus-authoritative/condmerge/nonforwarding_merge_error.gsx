package views

import "errors"

func maybeDecl(ok bool) (string, error) {
	if !ok { return "", errors.New("decl failed") }
	return "margin:0", nil
}

component Box(on bool, ok bool) {
	<div style="color:red" { if on { style={ maybeDecl(ok) } } }>x</div>
}
