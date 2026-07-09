package views

type User struct {
	Email string
}

type UsersPage struct {
	Title string
	Sort  string
	Users []User
}

component (p UsersPage) Page() {
	<div><p.Content/></div>
}

component (p UsersPage) Content() {
	<h1>{p.Title}</h1><p.Grid sort={p.Sort}/>
}

component (p UsersPage) Grid(sort string) {
	<ul>{ for _, u := range p.Users { <p.Row user={u} sort={sort}/> } }</ul>
}

component (p UsersPage) Row(user User, sort string) {
	<li>{user.Email}-{sort}</li>
}
