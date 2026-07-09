package views

func href(id string) (string, error)  { return "/u/" + id, nil }
func label(id string) (string, error) { return "user " + id, nil }

component Card(id string) {
	<div>
		<a href={ href(id) } title={ label(id) }>profile</a>
	</div>
}
