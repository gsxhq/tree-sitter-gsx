package views

component Label(text string) { <span>{text}</span> }

component Page(name string) { <Label text={ name |> upper }/> }
