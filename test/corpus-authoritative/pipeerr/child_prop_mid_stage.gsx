package views

component Label(text string) { <span>{text}</span> }

component Page(csv string) { <Label text={ csv |> parse |> pick(0) }/> }
