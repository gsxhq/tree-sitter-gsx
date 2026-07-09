package views

component Card(m map[string]any) {
	<div { m... }>x</div>
}

component Page() {
	<Card m={map[string]any{"z": "1", "a": "2"}}/>
}
