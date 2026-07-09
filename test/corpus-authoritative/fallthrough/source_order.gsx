package views

component Field(label string) {
	<input { attrs... }/>
}

component Page() {
	<Field label="Email" type="email" placeholder="you@co" name="email"/>
}
