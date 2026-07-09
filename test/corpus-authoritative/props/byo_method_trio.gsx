package views

type pageData struct {
	Title   string
	Section string
}

type home struct{}

component (p home) Page(d pageData) {
	<html>
		<body>
			<h1>{ d.Title }</h1>
			<p.Content { d... }/>
		</body>
	</html>
}

component (p home) Content(d pageData) {
	<main>
		<h2>{ d.Title }</h2>
		<p.Partial { d... }/>
	</main>
}

component (p home) Partial(d pageData) {
	<section>{ d.Section }</section>
}
