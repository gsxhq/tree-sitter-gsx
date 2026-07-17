package examples


import "github.com/gsxhq/gsx"
component Button(id string, attrs gsx.Attrs) {
	<button { if id != "" { id={id} } } { attrs... }>x</button>
}
