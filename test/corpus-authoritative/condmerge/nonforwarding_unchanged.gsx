package views

component Box(a bool) {
	<div { if a { class="on" } }>x</div>
	<div class="base" { if a { style="color:red" } }>y</div>
	<div { if a { class="on" } else { class="off" } }>z</div>
}
