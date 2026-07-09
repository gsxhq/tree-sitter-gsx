package views

component Page(name string) {
	<script>const n = @{ name |> truncate(3) };</script>
}
