package views

component Card(w int, userColor string) {
	<style>
		.card {
			width: @{ w }px;
			color: @{ userColor };
		}
	</style>
}
