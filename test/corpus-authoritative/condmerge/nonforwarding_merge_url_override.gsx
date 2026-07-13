package views

component Link() { <a { attrs... }>component</a> }

component Cases(dangerous string, on bool) {
	<a href="javascript:static-first()" href={ dangerous } class="base" { if on { class="on" } }>dynamic-wins</a>
	<a href={ dangerous } href="javascript:static-last()" class="base" { if on { class="on" } }>static-wins</a>
	<a href="javascript:first()" href="javascript:second()" class="base" { if on { class="on" } }>two-statics</a>
	<a href={ dangerous } class="base" { if on { href="javascript:conditional()" class="on" } }>conditional</a>
	<img src="data:image/png;base64,AA" class="base" { if on { class="on" } }/>
	<img srcset="javascript:one 1x, javascript:two 2x" class="base" { if on { class="on" } }/>
	<div data-url-go="javascript:custom()" class="base" { if on { class="on" } }>prefix</div>
	<a href="javascript:void(0)?a=1&amp;b=&#34;x&#34;" class="base" { if on { class="on" } }>html</a>
	<Link { if on { href="javascript:component()" } }/>
}
