package views

component Pic(u string) {
	<img srcset=f"@{u} 1x, fallback.jpg 2x"/>
}
