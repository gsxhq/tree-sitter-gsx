package p


import "github.com/gsxhq/gsx"
component Card(title string, children gsx.Node) { <div>{children}</div> }

component Page() { <Card title="x"><b>kid</b></Card> }
