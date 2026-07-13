package views

component Icon(name string) {
	<span data-name={name} { attrs... }>i</span>
}

component Wrapper() {
	<Icon name="x" { if attrs.Has("hot") { data-hot="1" } }/>
}

component Page() {
	<Wrapper hot="1"/>
}
