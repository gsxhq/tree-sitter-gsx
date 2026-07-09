package views

func twoInts() (int, int) { return 1, 2 }

component Card(x int) { <div>{x}</div> }

component Page() {
	<Card x={twoInts()}/>
	<div>{undefinedSym}</div>
}
