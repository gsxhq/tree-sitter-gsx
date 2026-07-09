package views

type PanelProps struct {
	UserPanelProps
	GroupPanelProps
}

component UserPanel(name string) {
	<span>user:{ name }</span>
}

component GroupPanel(team string) {
	<span>group:{ team }</span>
}

component Panel(props PanelProps) {
	<div>
		<UserPanel { props.UserPanelProps... }/>
		<GroupPanel { props.GroupPanelProps... }/>
	</div>
}
