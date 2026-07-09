package demo

func makeGreeting(who string) string {
	return f`hi @{who}`
}

component Greeting(who string) {
	<p>{ makeGreeting(who) }</p>
}
