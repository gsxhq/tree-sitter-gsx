package views

component List(items []Item) {
	<ul>{ for _, it := range items { <li>{it.Name}: {it.Count}</li> } }</ul>
}
