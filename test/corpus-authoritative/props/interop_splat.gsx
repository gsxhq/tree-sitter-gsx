package views

component Page() {
	{{ p := PickerProps{Name: "status", Label: "Status"} }}
	<Picker { p... }/>
}
