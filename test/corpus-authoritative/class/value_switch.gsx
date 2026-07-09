package views

component Badge(variant int) {
	<span class={ "base", switch variant {
	case 1: "green"
	case 2, 3: "amber"
	default: "gray"
	} }>x</span>
}
