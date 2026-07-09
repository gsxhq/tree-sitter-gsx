package views

component Page() {
	<div x-data="{ d: @{ load() } }">x</div>
}

func load() (string, error) { return "</script>\"", nil }
