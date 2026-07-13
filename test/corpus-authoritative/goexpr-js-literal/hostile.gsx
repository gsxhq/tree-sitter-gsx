package demo

import "github.com/gsxhq/gsx"

func mk(v string) gsx.RawJS {
	return js`f(@{v}, '@{v}', \`@{v}\`, /@{v}/)`
}

component Page() {
	<button @click={mk("'\"</script><x>${`}\nend")}>x</button>
}
