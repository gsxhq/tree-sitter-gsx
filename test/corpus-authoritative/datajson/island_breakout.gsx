package views

type Cfg struct {
	Note string
}

component Page(cfg Cfg) {
	<script type="application/json" id="cfg">@{ cfg }</script>
}
