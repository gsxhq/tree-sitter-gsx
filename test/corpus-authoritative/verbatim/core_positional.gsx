package views

import (
	"strconv"

	"github.com/gsxhq/gsx"
)

type Level int
type Letter rune

var seq int

func tick() (string, error) {
	seq++
	return strconv.Itoa(seq), nil
}

component Row(level Level, first string, second string) {
	<div data-level={level}><i>{first}</i><b>{second}</b></div>
}

component Action(script gsx.RawJS, label string) {
	<script>@{script}</script><p>{label}</p>
}

component RuneTarget(letter Letter) {
	<span>{string(letter)}</span>
}

component Page() {
	<Row second={tick()} level={min(1, 2)} first={tick()} />
	<Action script={js`alert(1)`} label={f`go`}/>
	<RuneTarget letter={'x'}/>
}
