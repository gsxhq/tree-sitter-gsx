package views

func buildHref(id string) (string, error) { return "/u/" + id, nil }
func label(id string) (string, error)     { return "user " + id, nil }

component Link(id string) {
	<a href={ buildHref(id) } title={ label(id) }>profile</a>
}
