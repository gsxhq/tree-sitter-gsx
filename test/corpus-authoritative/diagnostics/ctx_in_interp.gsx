package views

import "context"

func fromCtx(ctx context.Context) string {
	if ctx == nil {
		return "nil-ctx"
	}
	return "ok"
}

component C() {
	<p>{ fromCtx(ctx) }</p>
}
