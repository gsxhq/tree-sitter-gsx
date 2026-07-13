package views

component Field(label string) {
	<div data-label={label} { attrs... }></div>
}

component Page(ch <-chan string) {
	<Field data-x=f`@{<-ch}` label={<-ch}/>
}
