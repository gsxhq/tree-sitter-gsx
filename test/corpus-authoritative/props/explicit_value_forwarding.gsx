package views

type cardData struct {
	Title string
}

type pageData struct {
	Heading string
}

type Home struct{}

component Card(d cardData) {
	<div>{ d.Title }</div>
}

component Page(d pageData) {
	<Card d={cardData{Title: d.Heading}}/>
}

component (p Home) Content(pd pageData) {
	<h1>{ pd.Heading }</h1>
}

component (p Home) Shell(pd pageData) {
	<p.Content pd={pd}/>
}
