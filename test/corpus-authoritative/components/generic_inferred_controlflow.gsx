package views

component Box[T string | int](value T) {
	<span>{value}</span>
}

component Page() {
	{ for _, x := range []int{1, 2} { <Box value={x} /> } }
	{ if true { <Box value={"yes"} /> } else { <Box value={"no"} /> } }
}
