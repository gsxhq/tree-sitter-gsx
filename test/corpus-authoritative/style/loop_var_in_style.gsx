package views

component Bars(vals []int) {
	<div>
		{ for _, v := range vals {
			<span style={ "color: red", "font-weight: bold": v > 5 }>x</span>
		} }
	</div>
}
