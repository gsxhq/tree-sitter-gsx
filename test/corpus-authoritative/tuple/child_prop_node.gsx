package views

import "github.com/gsxhq/gsx"

func makeIcon(name string) (gsx.Node, error) { return gsx.Text("<" + name + ">"), nil }

component Badge(icon gsx.Node) { <div class="badge">{icon}</div> }

component Page(name string) { <Badge icon={makeIcon(name)}/> }
