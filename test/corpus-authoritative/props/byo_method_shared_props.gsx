package views

type pageData struct {
	Title   string
	Heading string
}

type home struct{}

component (p home) Page(d pageData) {
	<html>
		<body>
			<h1>{ d.Title }</h1>
			<p.Content d={d}/>
		</body>
	</html>
}

component (p home) Content(d pageData) {
	<h1>{ d.Heading }</h1>
}
