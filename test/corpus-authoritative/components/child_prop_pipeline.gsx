package views

component Card(title string) { <div>{title}</div> }

component Page(t string) { <Card title={t |> upper}/> }
