package views

component Page(name string) {
	<script>const n = @{ name |> upper };</script>
}
