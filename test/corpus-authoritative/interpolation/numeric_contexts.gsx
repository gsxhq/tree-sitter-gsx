package views

component Nums(items []int, flag bool) {
	<div>
		<p>{ len(items) }</p>
		{ if flag {
			<span>{ items[0] }</span>
		} }
		<ul>{ for i, v := range items {
			<li>{ i }: { v }</li>
		} }</ul>
		<>{ len(items) }</>
	</div>
}
