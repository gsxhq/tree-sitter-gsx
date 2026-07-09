package views

component Inner(title string) { <div { attrs... }>{title}</div> }

component Page() { <Inner class={ "a" } title="y"/> }
