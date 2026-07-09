package views

func helper() string { return "x" }

import "fmt"

var _ = fmt.Sprintf

component Bad() {
	<p>{helper()}</p>
}
