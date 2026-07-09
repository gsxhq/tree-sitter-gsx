package views

type ID string

type Flag bool

component Tag(id ID, flag Flag) {
	<p>{id}|{flag}</p>
}
