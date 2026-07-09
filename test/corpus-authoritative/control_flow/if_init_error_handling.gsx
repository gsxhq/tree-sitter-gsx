package views

func load(id string) (string, error) { return "loaded:" + id, nil }

component Profile(id string) {
	<div>{ if v, err := load(id); err != nil { <span class="err">{ err.Error() }</span> } else { <span>{ v }</span> } }</div>
}
