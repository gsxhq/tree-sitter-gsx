package views

import "github.com/gsxhq/gsx"

component Counter(signals gsx.Attrs, children gsx.Node) {
	<button { signals... }>{children}</button>
}

component Page() {
	<Counter signals={{ "data-signals": "{count:0}", "data-text": "$count", "data-on-click": "$count++" }}>Count</Counter>
}
