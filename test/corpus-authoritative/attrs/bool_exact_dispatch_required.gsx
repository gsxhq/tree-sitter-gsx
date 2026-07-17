package views

import (
	"strconv"

	"github.com/gsxhq/gsx"
)

type Flag bool

var anyFalse any = false

component Plain(req bool) {
	<input required={req} />
}

component Mixed[T string | bool](req T) {
	<input required={req} />
}

component Sink(extra gsx.Attrs) {
	<input { extra... } />
}

component Aria(hidden bool) {
	<div aria-hidden={hidden} />
	<div aria-hidden={strconv.FormatBool(hidden)} />
}

component Page() {
	<Plain req={false} />
	<Mixed[bool] req={false} />
	<Sink extra={gsx.Attrs{{Key: "required", Value: Flag(false)}}} />
	<Sink extra={gsx.Attrs{{Key: "required", Value: anyFalse}}} />
	<Aria hidden={true} />
}
