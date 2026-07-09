package views

import "github.com/gsxhq/gsx"

component Theme(themeColor gsx.RawCSS, userInput string) {
	<div style={ "border: " + userInput, "color: " + themeColor }>content</div>
}
