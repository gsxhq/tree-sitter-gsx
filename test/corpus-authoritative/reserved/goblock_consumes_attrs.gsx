package views

component Field(name string) {
	{{ d := attrs.Has("class") }}
	<input name={name} data-has-class={d}/>
}
