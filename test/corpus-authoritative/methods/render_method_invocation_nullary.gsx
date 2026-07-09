package views

type UsersPage struct {
	Title string
}

component (p UsersPage) Page() {
	<div><p.Content/></div>
}

component (p UsersPage) Content() {
	<h1>{p.Title}</h1>
}
