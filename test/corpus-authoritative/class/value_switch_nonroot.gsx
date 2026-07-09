package views

component Widget(variant int) {
	<div><span class={ "x", switch variant {
	case 1: "a"
	default: "b"
	} }>y</span></div>
}
