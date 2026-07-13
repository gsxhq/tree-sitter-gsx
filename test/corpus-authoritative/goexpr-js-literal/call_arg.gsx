package demo

component Host(formID string) {
	<div>{ consume(js`submit(@{formID})`) }</div>
}
