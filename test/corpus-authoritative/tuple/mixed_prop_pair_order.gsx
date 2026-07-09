package views

import "github.com/gsxhq/gsx"

func f(k string) (string, error) { return "f-" + k, nil }
func g(k string) (string, error) { return "g-" + k, nil }
func h(k string) (string, error) { return "h-" + k, nil }

component Card(a string, bag gsx.Attrs, b string) {
	<div>{a}<span { bag... }/>{b}</div>
}

component Page(k string) {
	<Card a={f(k)} bag={{ "x": g(k) }} b={h(k)}/>
}
