package views

component Status(n int) {
	<p>{ if n > 0 { <span>pos</span> } else if n < 0 { <span>neg</span> } else { <span>zero</span> } }</p>
}
