package demo

var strconv = "shadowed"

component Uses(b bool) {
	<b>{ b }{ strconv }</b>
}
