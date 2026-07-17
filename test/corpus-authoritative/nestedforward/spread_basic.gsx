package views


import "github.com/gsxhq/gsx"
component Icon(name string, attrs gsx.Attrs) {
	<span class="icon" data-name={name} { attrs... }>i</span>
}

component SearchIcon(attrs gsx.Attrs) {
	<Icon name="search" class="w-5 h-5" { attrs... }/>
}

component Page() {
	<SearchIcon class="text-red" aria-label="Search"/>
}
