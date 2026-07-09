package examples

component List(rows []string) {
	<ul>
		{ for _, r := range rows {
			<li>{r}</li>
		} }
	</ul>
}
