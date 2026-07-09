package views

component C(v int) {
	<span class={ "base", bad(v) }>x</span>
}

func bad(v int) (int, string) { return 0, "" }
