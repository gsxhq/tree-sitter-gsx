package views

component Filter(entityType string, extra map[string]string) {
	<input hx-vals=js`{"entity_type": @{entityType}, "extra": @{extra}}`/>
}
