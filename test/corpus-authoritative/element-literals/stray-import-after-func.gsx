package demo

import "github.com/gsxhq/gsx"

func render() gsx.Node {
	return <div>inline JSX</div>
}

import "strings"

component Index() {
	<section>{ render() }</section>
}
