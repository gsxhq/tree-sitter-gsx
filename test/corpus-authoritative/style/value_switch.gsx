package views

component Box(tone int) {
	<div style={ "padding: 4px", switch tone {
	case 1: "color: red"
	default: "color: gray"
	} }>x</div>
}
