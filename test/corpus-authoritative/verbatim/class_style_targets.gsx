package views

import "github.com/gsxhq/gsx"

component Badge(class string, style string) {
	<span class={class} style={style}>x</span>
}

component Plain(attrs gsx.Attrs) {
	<span {attrs...}>y</span>
}

component Page() {
	<Badge class="a b" style="color: red"/>
	<Badge class={ "a", "b": true } style={ "color: blue" }/>
	<Plain class="c"/>
}
