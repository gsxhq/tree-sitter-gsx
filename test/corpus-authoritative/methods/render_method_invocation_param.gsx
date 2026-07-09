package views

type UsersPage struct {
	Sort string
}

component (p UsersPage) Page() {
	<div><p.Grid sort={p.Sort}/></div>
}

component (p UsersPage) Grid(sort string) {
	<span>{sort}</span>
}
