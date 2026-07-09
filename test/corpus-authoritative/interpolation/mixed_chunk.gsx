package views

import "fmt"

type Money int

func (m Money) String() string { return fmt.Sprintf("$%d", int(m)) }

func label() string { return "price:" }

component Receipt(price Money) {
	<p>{label()}{price}</p>
}
