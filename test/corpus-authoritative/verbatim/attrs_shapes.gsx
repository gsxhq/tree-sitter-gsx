package views

import "github.com/gsxhq/gsx"

component Field(inputAttrs gsx.Attrs) {
	<label><input {inputAttrs...}/><span {inputAttrs...}></span></label>
}

component Shell(attrs gsx.Attrs) {
	<main {attrs...}></main>
}

type LocalAttrs []gsx.Attr

component Defined(attrs LocalAttrs) {
	<aside {gsx.Attrs(attrs)...}></aside>
}

component Variadic(attrs ...gsx.Attr) {
	<nav {gsx.Attrs(attrs)...}></nav>
}

func computedBag() gsx.Attrs {
	return gsx.Attrs{{Key: "data-k", Value: "v"}}
}

component Page() {
	<Field inputAttrs={{ "id": "x" }}/>
	<Field inputAttrs={computedBag()}/>
	<Shell attrs={{ "id": "shell" }} class="wide"/>
	<Shell { if true { attrs={computedBag()} } } id="conditional"/>
	<Defined id="defined"/>
	<Variadic id="variadic"/>
}
