package views

type A struct{ S string }
type B struct{ N int }

component (a A) Row() { <i>{a.S}</i> }
component (b B) Row() { <b>{b.N}</b> }
