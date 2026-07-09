package views

component Hi(s string) { <p>{ s |> trim |> truncate(5) }</p> }
