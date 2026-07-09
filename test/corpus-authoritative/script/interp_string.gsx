package views

component Page(id string) {
	<script>
		const url = "/api/@{ id }";
	</script>
}
