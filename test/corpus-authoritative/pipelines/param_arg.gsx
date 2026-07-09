package views

component Tags(tags []string, sep string) { <p>{ tags |> join(sep) }</p> }
