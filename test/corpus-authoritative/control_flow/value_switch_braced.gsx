package views

component Badge(variant int) {
	<span class={ switch variant {
	case 1:
		{ "green" |> upper }
	default:
		{ "gray" }
	} }>x</span>
}
