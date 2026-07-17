package views


import "github.com/gsxhq/gsx"
component Field(label string, attrs gsx.Attrs) {
	<div data-label={label} { attrs... }></div>
}

component Page(ch <-chan string) {
	<Field data-x=f`@{<-ch}` label={<-ch}/>
}
