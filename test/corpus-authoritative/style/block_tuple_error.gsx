package views

component C() {
	<style>.a{content:@{ theme() }}</style>
}

func theme() (string, error) { return "x", nil }
