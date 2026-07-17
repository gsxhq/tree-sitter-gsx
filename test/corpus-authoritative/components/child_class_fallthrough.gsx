package views


import "github.com/gsxhq/gsx"
component Card(title string, attrs gsx.Attrs) { <div { attrs... }>{title}</div> }

component Page(on bool) { <Card class={ "a", "b": on }/> }
