package views

import "github.com/gsxhq/gsx"

func trustedJS() gsx.RawJS { return gsx.RawJS("trusted()") }
func trustedCSS() gsx.RawCSS { return gsx.RawCSS("color:red") }

component Page(v string, rawJS gsx.RawJS, rawCSS gsx.RawCSS, a gsx.Attrs, b gsx.Attrs) {
	<div data-x=js`v=@{v};s='@{v}';t=\`@{v}\`;r=/@{v}/`>inline</div>
	<div { a... } data-x=js`v=@{v};s='@{v}';t=\`@{v}\`;r=/@{v}/` { b... }>fold</div>
	<div style=css`content:@{v}`>inline</div>
	<div { a... } style=css`content:@{v}` { b... }>fold</div>
	<div style=css`content:@{v};x:@{rawCSS}`>inline-adjacent</div>
	<div { a... } style=css`content:@{v};x:@{rawCSS}` { b... }>fold-adjacent</div>
	<div data-raw=js`v=@{rawJS}`>inline-raw-js</div>
	<div { a... } data-raw=js`v=@{rawJS}` { b... }>fold-raw-js</div>
	<div style=css`@{rawCSS}`>inline-raw-css</div>
	<div { a... } style=css`@{rawCSS}` { b... }>fold-raw-css</div>
}
