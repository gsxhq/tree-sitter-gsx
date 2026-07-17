package views

import "github.com/gsxhq/gsx"

component PipelineTarget(first string, after string, attrs gsx.Attrs) {
	<div { attrs... }>{first}{after}</div>
}

component Page() {
	<PipelineTarget
		first={markPipeline("pipe-first", "A")}
		after={markPipeline("pipe-after", "Z")}
		data-mid={markPipeline("pipe", "x") |> check |> upper}
	/>
	<PipelineTarget
		first={markPipeline("pipe-first-2", "B")}
		after={markPipeline("pipe-after-2", "Y")}
		data-mid={markPipeline("pipe-2", "y") |> check |> upper}
	/>
}
