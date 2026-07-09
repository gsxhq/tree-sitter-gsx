package views

type UsersPage struct {
	Title string
	Sort  string
}

component (p UsersPage) Page() {
	<h1>{p.Title}</h1>
}
