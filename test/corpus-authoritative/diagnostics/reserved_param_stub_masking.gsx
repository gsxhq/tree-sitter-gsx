package views

component Bad(ctx string) { <div>{children}</div> }

component Good() { <Bad>hi</Bad> }
