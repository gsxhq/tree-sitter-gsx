package views

type UsersPage struct {
	Title string
}

component Card(label string) {
	<div class="card">{label}</div>
}

component (p UsersPage) Page() {
	<section><p.Content/><Card label="hello"/></section>
}

component (p UsersPage) Content() {
	<h1>{p.Title}</h1>
}
