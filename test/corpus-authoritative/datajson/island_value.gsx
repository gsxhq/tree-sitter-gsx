package views

type Cfg struct {
	Env  string
	Beta bool
}

component Page(cfg Cfg) {
	<script type="application/json" id="cfg">@{ cfg }</script>
}
