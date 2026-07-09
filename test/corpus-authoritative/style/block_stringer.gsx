package views

import "fmt"

type Color struct{ R, G, B int }

func (c Color) String() string { return fmt.Sprintf("#%02x%02x%02x", c.R, c.G, c.B) }

component C(c Color) {
	<style>.a{color:@{ c }}</style>
}
