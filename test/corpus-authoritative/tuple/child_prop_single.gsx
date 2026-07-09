package views

func lookup(key string) (string, error) { return "val-" + key, nil }

component Row(label string) { <span>{label}</span> }

component Page(k string) { <Row label={lookup(k)}/> }
