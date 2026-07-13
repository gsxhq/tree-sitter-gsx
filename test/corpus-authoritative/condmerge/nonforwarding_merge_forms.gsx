package views

import "strings"

func decl(s string) (string, error) { return s, nil }

component Forms(which int, gap string) {
	<div style="color:red" style="margin:0" style="color:blue">top</div>
	<div class="base" { if which == 1 { class="one" } else if which == 2 { class="two" } else { class="other" } }>branch</div>
	<div style=css"color:red" { if which > 0 { style=css"margin:@{gap}" } }>css</div>
	<div class={ "base" } { if which > 0 { class={ strings.ToUpper("on") } } }>class</div>
	<div style="color:red" { if which > 0 { style={ decl("margin:0") } } }>tuple</div>
	<div style="color:red" { if which > 0 { style={ "margin:" + gap |> upper } } }>pipeline</div>
}
