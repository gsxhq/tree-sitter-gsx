package views

import "github.com/gsxhq/gsx"

type props struct {
  label gsx.Node
}
var items = []props{{label: <p>x</p>}}

component C(p props) { <div>{p.label}</div> }
component page() {
  { for _, item := range items {
    <C {item...} />
  } }
}
