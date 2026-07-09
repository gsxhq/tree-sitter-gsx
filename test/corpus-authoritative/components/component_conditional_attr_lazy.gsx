package views

import "github.com/gsxhq/gsx"

type User struct {
	Name string
}

component Card(title gsx.Node) { <div class="card" { attrs... }>{title}</div> }

component Page(u *User) {
	<Card title="Hi" { if u != nil { data-name={ u.Name } } } />
}
