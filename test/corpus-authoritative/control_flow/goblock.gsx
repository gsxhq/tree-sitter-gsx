package views

component Chip(first string, last string) {
	<div>{{ full := first + " " + last }}<span>{full}</span></div>
}
