package views

component Badge(title string) { <b>{title}</b> }

component Page(y int, z string) {
	<div><Divider/>{y}<Badge title={z}/><Divider/>{z}</div>
}
