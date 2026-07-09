package views

import "github.com/gsxhq/gsx"

component Noop() {
	<span/>
}

func Items(xs []string) gsx.Node {
	return (
		<>
			{ for _, s := range xs {
				<li>{ s }</li>
			} }
		</>
	)
}

component Host() {
	<ul>{ Items([]string{"a", "b"}) }</ul>
}
