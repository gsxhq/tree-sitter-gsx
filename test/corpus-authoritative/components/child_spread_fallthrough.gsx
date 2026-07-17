package views

import "github.com/gsxhq/gsx"

component Card(title string, attrs gsx.Attrs) { <div { attrs... }>{title}</div> }

component Page(bag gsx.Attrs) { <Card { bag... }/> }
