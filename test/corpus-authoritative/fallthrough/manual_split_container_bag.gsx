package views

import "github.com/gsxhq/gsx"

component Field(label string, containerAttrs gsx.Attrs) {
	<div class="field" { containerAttrs... }>
		<label>{label}</label>
		<input class="field-input" { attrs... }/>
	</div>
}

component Page() {
	<Field
		label="Email"
		container-attrs={gsx.Attrs{{Key: "data-testid", Value: "email-field"}}}
		type="email"
		placeholder="you@co"
		required
	/>
}
