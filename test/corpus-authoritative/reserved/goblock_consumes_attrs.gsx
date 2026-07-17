package views


import "github.com/gsxhq/gsx"
component Field(name string, attrs gsx.Attrs) {
	{{ d := attrs.Has("class") }}
	<input name={name} data-has-class={d}/>
}
