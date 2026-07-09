package views

component C(n uint64) {
	<span class={ switch n {
	case 1 << 63: "big"
	default: "small"
	} }>x</span>
}
