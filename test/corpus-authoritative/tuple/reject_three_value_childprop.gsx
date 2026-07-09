package views

func triple() (int, string, bool) { return 1, "x", true }

component Card(x int) { <div>{x}</div> }

component Page() { <Card x={triple()}/> }
