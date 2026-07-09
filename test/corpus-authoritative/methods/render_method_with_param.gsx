package views

type UsersPage struct {
	Title string
	Sort  string
}

component (p UsersPage) Grid(sort string) {
	<div>{sort}-{p.Title}</div>
}
