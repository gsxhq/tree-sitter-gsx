package views

component Tags(tags []string) { <p>{ tags |> join(", ") }</p> }
