package p

type Page struct{}

component (p Page) Body() { <main>x</main> }

component Shell(p Page) { <p.Body/> }
