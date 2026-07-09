package views

var trace []string

component C() {
	<span class={ first(), tuplePart(), last() }>x</span>
}

func first() string {
	trace = append(trace, "first")
	return "first"
}

func tuplePart() (string, error) {
	if len(trace) != 1 || trace[0] != "first" {
		return "tuple-out-of-order", nil
	}
	trace = append(trace, "tuple")
	return "tuple", nil
}

func last() string {
	if len(trace) != 2 || trace[1] != "tuple" {
		return "last-out-of-order"
	}
	trace = append(trace, "last")
	return "last"
}
