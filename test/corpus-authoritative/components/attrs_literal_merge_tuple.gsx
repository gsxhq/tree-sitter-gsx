package views

func f() (string, error) { return "2", nil }

component Panel() {
	<section { attrs... }>x</section>
}

component Page() {
	<Panel data-a="1" attrs={{ "data-b": f() }}/>
}
