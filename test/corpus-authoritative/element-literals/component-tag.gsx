package demo

component Badge(count int) {
	<span class="badge">{ count }</span>
}

var badge = <Badge count={12}/>

component Uses() {
	<div>{ badge }</div>
}
