package views

component ExprRefresh(to string) {
	<meta http-equiv={"refresh"} content={"0;url=" + to}/>
}
