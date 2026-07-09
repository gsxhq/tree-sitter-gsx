package views

func firstName(id string) (string, error) { return "First-" + id, nil }
func lastName(id string) (string, error)  { return "Last-" + id, nil }

component Name(first string, last string) { <div>{first} {last}</div> }

component Page(id string) { <Name first={firstName(id)} last={lastName(id)}/> }
