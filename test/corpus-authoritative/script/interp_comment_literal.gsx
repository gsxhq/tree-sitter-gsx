package views

type Config struct {
	Tab string
}

component Page(cfg Config) {
	<script>
		const data = @{ cfg };  // note: @{ rawNote }
	</script>
}
