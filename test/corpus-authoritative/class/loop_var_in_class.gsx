package views

component Bars(vals []int) {
	<div>
		{ for _, v := range vals {
			<span class={ "bar", "hot": v > 5 }>x</span>
		} }
	</div>
}
