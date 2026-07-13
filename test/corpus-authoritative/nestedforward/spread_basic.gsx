package views

component Icon(name string) {
	<span class="icon" data-name={name} { attrs... }>i</span>
}

component SearchIcon() {
	<Icon name="search" class="w-5 h-5" { attrs... }/>
}

component Page() {
	<SearchIcon class="text-red" aria-label="Search"/>
}
