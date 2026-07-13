package views

import "github.com/gsxhq/gsx"

component Field[T string | int](value T, a gsx.Attrs, b gsx.Attrs) {
	<div { a... } title=f"value=@{value}" { b... }>x</div>
}

component Page() {
	<Field[string] value={"a<b"} a={nil} b={nil} />
	<Field[int] value={7} a={nil} b={nil} />
}
