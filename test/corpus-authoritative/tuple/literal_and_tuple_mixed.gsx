package views

func lookup(key string) (string, error) { return "title-" + key, nil }

component Card(value float64, title string) { <div>{title} {value}</div> }

component Page(t string) { <Card value={100} title={lookup(t)}/> }
