package views

component C(extra string, on bool) {
	<div><span class={ "btn", extra, "active": on }>y</span></div>
}
