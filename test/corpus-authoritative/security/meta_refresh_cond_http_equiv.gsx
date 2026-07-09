package views

component CondRefresh(legacy bool, to string) {
	<meta { if legacy { http-equiv="refresh" } } content={"0;url=" + to}/>
}
