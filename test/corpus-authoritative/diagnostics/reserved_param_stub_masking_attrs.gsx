package views

component Bad(ctx string) { <div></div> }

component Good() { <Bad ctx="x"/> }
