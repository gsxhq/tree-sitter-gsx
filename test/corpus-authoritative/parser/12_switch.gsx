package examples

component Badge(kind string) {
	<span>
		{ switch kind {
		case "warn":
			<b>warn</b>
		default:
			<b>info</b>
		} }
	</span>
}
