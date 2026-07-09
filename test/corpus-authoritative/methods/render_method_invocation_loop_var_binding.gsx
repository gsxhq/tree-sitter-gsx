package views

type User struct {
	Email string
}

type RowProps struct {
	User User
}

type UsersPage struct {
	Users []User
}

component (p UsersPage) Page() {
	<ul>{ for _, u := range p.Users { <p.Row user={u}/> } }</ul>
}

component (p UsersPage) Row(rp RowProps) {
	<li>{rp.User.Email}</li>
}
