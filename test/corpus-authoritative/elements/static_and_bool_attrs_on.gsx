package views

component Field(on bool) {
	<input type="text" class="form-control" required disabled={on}/>
}
