package views

component Link(on bool) {
	<a href="javascript:void(0)" class="base" { if on { class="on" } }>x</a>
	<a href="javascript:void(0)" class="base">y</a>
}
