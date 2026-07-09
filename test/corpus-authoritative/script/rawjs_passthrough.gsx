package views

import "github.com/gsxhq/gsx"

component Page() {
	<script>const fn = @{ gsx.RawJS("doThing(1)") };</script>
}
