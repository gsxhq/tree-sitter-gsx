package views

component Card(title string) { <div { attrs... }>{title}</div> }

component Page() { <Card title="Hi" data-x="1"/> }
