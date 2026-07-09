package views

import "github.com/gsxhq/gsx"

func f(k string) (string, error) { return "f-" + k, nil }

component Card(bag gsx.Attrs) {
	<div { bag... }/>
}

component Page(k string) {
	<Card bag={{ "x-a": f(k), "x-b": "lit" }}/>
}
