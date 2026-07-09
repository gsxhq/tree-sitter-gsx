package views

component Page(show bool, xs []int) {
	<div>{ if show { <Divider/> } }{ for range xs { <Divider/> } }</div>
}
