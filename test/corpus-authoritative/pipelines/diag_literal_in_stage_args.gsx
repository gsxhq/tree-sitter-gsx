package views

component Hi(who string) { <p>{ who |> printf(f`%s!`) }</p> }
