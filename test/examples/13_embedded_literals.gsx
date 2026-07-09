package examples

// Element/fragment literals are Go values in top-level Go and func bodies too
// (the element-literals feature), not just inside { }.
var defaultIcon = <span class="icon"/>

func fallback() gsx.Node { return <>—</> }

// Interpolation is opt-in behind an f/js/css prefix. A bare `…` / "…" is a plain
// Go string with no @{ } holes; only a prefixed literal interpolates.
component Showcase(variant string, count int, url string) {
	// f`…` / f"…": generic auto-escaped interpolating text (no sublanguage).
	<span class=f`badge badge-@{variant}`>
		{ f`You have @{count} items` }
	</span>

	// A bare backtick attribute value is a plain Go raw string — @{…} is literal.
	<span data-tpl=`literal @{not-a-hole}`/>

	// js`…` / css`…` embed a sublanguage; the "…" delimiter is the escape hatch
	// for content that itself contains a backtick.
	<button @click=js`track(@{count})` style=css`--n:@{count}`>Track</button>
	<button @click=js"emit(`@{variant}`)">Quoted</button>

	// Element and fragment values mid-expression inside a Go interpolation.
	<div>{ wrap(<a href={url}>link</a>) }</div>
	<div>{ join(<b/>, <i/>) }</div>
	<div>{ list(<>one</>, <>two</>) }</div>
}
