package views

import "github.com/gsxhq/gsx"

var calls []string
func bag(mark string) gsx.Attrs { calls = append(calls, mark); return nil }
func hole(mark string) string { calls = append(calls, mark); return mark }

component CSSPage() {
	<div { bag("spread")... } style=css"a:@{hole("first")};b:@{failHole()};c:@{hole("late-hole")}" { bag("late-spread")... }>x</div>
}
component JSPage() {
	<div { bag("spread")... } data-x=js"f(@{hole("first")},@{failHole()},@{hole("late-hole")})" { bag("late-spread")... }>x</div>
}
