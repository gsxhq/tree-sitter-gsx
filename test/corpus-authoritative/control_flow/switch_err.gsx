package views

component Badge(kind string) {
	<span>{ switch kind {
	case "warn":
		<b>warning</b>
	case "err":
		<b>error</b>
	default:
		<b>info</b>
	} }</span>
}
