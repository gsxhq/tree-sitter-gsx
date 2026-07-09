package views

component DynamicRefresh(kind string, to string) {
	<meta http-equiv={kind} content={"0;url=" + to}/>
}
