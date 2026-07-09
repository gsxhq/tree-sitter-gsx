package views

import "github.com/gsxhq/gsx"

component Box(body gsx.Node) {
	<div>{body}</div>
}

component Page(userStr string) {
	<Box body={userStr}/>
}
