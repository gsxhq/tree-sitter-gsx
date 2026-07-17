package views


import "github.com/gsxhq/gsx"
component Field(label string, attrs gsx.Attrs) {
	<input { attrs... }/>
}

component Page() {
	<Field label="Email" type="email" placeholder="you@co" name="email"/>
}
