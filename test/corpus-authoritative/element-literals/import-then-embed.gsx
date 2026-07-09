package demo

import "github.com/gsxhq/gsx"

func render() gsx.Node {
	return <div>inline JSX</div>
}

component Index() {
	<section>{ render() }</section>
}
