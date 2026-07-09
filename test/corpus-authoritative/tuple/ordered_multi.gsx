package views

import "github.com/gsxhq/gsx"

func f(k string) (string, error) { return "f-" + k, nil }
func g(k string) (string, error) { return "g-" + k, nil }

component Card(bag gsx.Attrs) {
	<div { bag... }/>
}

component Page(k string) {
	<Card bag={{ "x-a": f(k), "x-b": g(k) }}/>
}
