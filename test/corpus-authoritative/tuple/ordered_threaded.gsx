package views

import "github.com/gsxhq/gsx"

func sig(name string) (string, error) { return "{" + name + ":0}", nil }

component Inner(bag gsx.Attrs) {
	<span { bag... }/>
}

component Outer(bag gsx.Attrs) {
	<Inner bag={bag}/>
}

component Page(t string) {
	<Outer bag={{ "data-signals": sig(t) }}/>
}
