package views

component L(xs []string) { <ul>{ for _, x := range xs { <li>{ x |> upper }</li> } }</ul> }
