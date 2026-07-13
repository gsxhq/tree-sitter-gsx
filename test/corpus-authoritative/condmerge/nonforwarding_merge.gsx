package views

component Box(a bool) {
	<div class="base" { if a { class="on" } } style="color:red" { if a { style="margin:0" } }>x</div>
}
