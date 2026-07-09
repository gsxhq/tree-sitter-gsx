package views

component C(p *int) {
	<span class={ "base", switch p {
	case nil: "none"
	default: "some"
	} }>x</span>
}
