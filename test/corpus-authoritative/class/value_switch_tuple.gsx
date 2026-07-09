package views

component Badge(variant int) {
	<span class={ "base", switch variant {
	case 1: cls(variant)
	default: "gray"
	} }>x</span>
}

func cls(v int) (string, error) { return "green", nil }
