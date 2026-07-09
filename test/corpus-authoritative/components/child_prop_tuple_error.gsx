package views

func lookup(s string) (string, error) { return s, nil }

component Card(title string) { <div>{title}</div> }

component Page(t string) { <Card title={lookup(t)}/> }
