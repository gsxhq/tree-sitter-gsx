package views

component Pic(a string, b string) {
	<img srcset={ a } alt="x"/>
	<source srcset={ b }/>
}
