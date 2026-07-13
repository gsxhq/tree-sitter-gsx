package views

import "github.com/gsxhq/gsx"

component Field(sync gsx.Attrs, extra gsx.Attrs) {
	<input type="hidden" name="n" class="base" { sync... } { extra... }/>
}
