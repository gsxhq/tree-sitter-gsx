package views

component Page() {
	<script>const d = @{ load() };</script>
}

func load() (string, error) { return "</script>", nil }
