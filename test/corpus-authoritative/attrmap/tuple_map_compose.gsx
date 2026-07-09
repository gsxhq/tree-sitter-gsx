package views

import "github.com/gsxhq/gsx"

func attrsOf(id string) (map[string]any, error) {
	return map[string]any{"id": id, "class": "c"}, nil
}

component Card(bag gsx.Attrs) {
	<div { bag... }>x</div>
}

component Page() {
	<Card bag={attrsOf("e1")}/>
}
