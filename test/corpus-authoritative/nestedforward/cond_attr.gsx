package views


import "github.com/gsxhq/gsx"
component Icon(name string, attrs gsx.Attrs) {
	<span data-name={name} { attrs... }>i</span>
}

component Wrapper(attrs gsx.Attrs) {
	<Icon name="x" { if attrs.Has("hot") { data-hot="1" } }/>
}

component Page() {
	<Wrapper hot="1"/>
}
