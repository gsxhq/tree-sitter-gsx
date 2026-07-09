package views

func numErr() (int, error) { return 1, nil }

component Card(title string) { <div>{title}</div> }

component Page() { <Card title={numErr()}/> }
