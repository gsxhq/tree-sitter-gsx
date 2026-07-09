package views

import "github.com/gsxhq/gsx"

component Page() {
	<button @click={ gsx.RawJS("toggle()") }>x</button>
}
