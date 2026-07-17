package views


import "github.com/gsxhq/gsx"
component Bad(ctx string, children gsx.Node) { <div>{children}</div> }

component Good() { <Bad>hi</Bad> }
