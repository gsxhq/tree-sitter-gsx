package views


import "github.com/gsxhq/gsx"
component Inner(title string, attrs gsx.Attrs) { <div { attrs... }>{title}</div> }

component Page() { <Inner class={ "a" } title="y"/> }
