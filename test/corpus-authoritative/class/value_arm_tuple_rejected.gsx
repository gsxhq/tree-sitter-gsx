package views

component C(v int) {
	<span class={ switch v {
	case 1: bad(v)
	default: "x"
	} }>y</span>
}

func bad(v int) (int, string) { return 0, "" }
