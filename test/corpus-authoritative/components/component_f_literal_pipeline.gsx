package views

import "fmt"

component Generic[T any](value T) {
	<p>{ fmt.Sprint(value) }</p>
}

component Header(subtitle string) {
	<h1>{ subtitle }</h1>
}

component Page(n int, label string) {
	<Generic value=f`item-@{n}`/>
	<Header subtitle={f`item-@{n}` |> upper}/>
	<Header subtitle=f`label-@{label |> upper}`/>
	<Header subtitle={f`checked-@{n}` |> check}/>
}
