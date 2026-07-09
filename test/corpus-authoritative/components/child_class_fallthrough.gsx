package views

component Card(title string) { <div { attrs... }>{title}</div> }

component Page(on bool) { <Card class={ "a", "b": on }/> }
