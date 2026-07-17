package demo

import "github.com/gsxhq/gsx"

component Page(path string) {
	<script>@{gsx.RawJS(path)} = 1;</script>
}
