package views

import "github.com/gsxhq/gsx"

func makeLabel(s string) (myLabel, error) { return myLabel{text: "[" + s + "]"}, nil }

component Badge(icon gsx.Node) { <span>{icon}</span> }

component Page(s string) { <Badge icon={makeLabel(s)}/> }
