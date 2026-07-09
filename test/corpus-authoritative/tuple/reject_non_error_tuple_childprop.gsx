package views

func twoVals() (int, string) { return 1, "x" }

component Card(x int) { <div>{x}</div> }

component Page() { <Card x={twoVals()}/> }
