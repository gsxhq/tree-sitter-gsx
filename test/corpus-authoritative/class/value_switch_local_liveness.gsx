package views

component C() {
	{{ level := 2 }}
	{{ hi := 2 }}
	<span class={ "base", switch level {
	case hi: "high"
	default: "low"
	} }>x</span>
}
