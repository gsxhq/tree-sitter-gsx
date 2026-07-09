package views

component Badge(n int) {
	<div { if n == 1 { data-a="one" } else if n == 2 { data-a="two" } else { data-a="many" } } { attrs... }>x</div>
}

component Page() {
	<Badge n={2} data-a="caller"/>
}
