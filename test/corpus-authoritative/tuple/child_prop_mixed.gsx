package views

func greeting(name string) (string, error) { return "Hello " + name, nil }

component Card(msg string, count int) { <div>{msg} x{count}</div> }

component Page(name string, n int) { <Card msg={greeting(name)} count={n}/> }
