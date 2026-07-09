package demo

var item = NavItem{Label: "Home", Icon: (
	<svg class="w-5 h-5">
		<path d="M0 0"/>
	</svg>
)}

component Uses() {
	<div>{ item.Label }{ item.Icon }</div>
}
