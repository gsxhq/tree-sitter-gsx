package views

import "corpustest/cases/filterimport_user_plain_import_and_filter/filters"

var label = filters.Label

component Tag(name string) {
	<div>{ label }: { name |> upper }</div>
}
