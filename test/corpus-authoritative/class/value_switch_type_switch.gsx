package views

component C(v any) {
	<span class={ switch v.(type) {
	case string: "str"
	default: "other"
	} }>x</span>
}
