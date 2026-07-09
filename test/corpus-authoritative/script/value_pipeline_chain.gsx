package views

component Page(name string) {
	<script>const n = @{ name |> trim |> truncate(4) };</script>
}
