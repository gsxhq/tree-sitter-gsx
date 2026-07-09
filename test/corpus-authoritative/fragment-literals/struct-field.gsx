package views

var s = slot{Body: <><i>hi</i></>}

component Uses() {
	<div>{ s.Body }</div>
}
