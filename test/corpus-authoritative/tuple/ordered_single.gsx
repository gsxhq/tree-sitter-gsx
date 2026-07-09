package views

import "github.com/gsxhq/gsx"

func sig(name string) (string, error) { return "{" + name + ":0}", nil }

component Card(bag gsx.Attrs) {
	<div { bag... }>x</div>
}

component Page(t string) {
	<Card bag={{ "data-signals": sig(t) }}/>
}
