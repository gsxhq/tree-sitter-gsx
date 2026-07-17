package views

type UserPanelInput struct {
	Name string
}

type GroupPanelInput struct {
	Team string
}

type PanelInput struct {
	User  UserPanelInput
	Group GroupPanelInput
}

component UserPanel(input UserPanelInput) {
	<span>user:{ input.Name }</span>
}

component GroupPanel(input GroupPanelInput) {
	<span>group:{ input.Team }</span>
}

component Panel(input PanelInput) {
	<div>
		<UserPanel input={input.User}/>
		<GroupPanel input={input.Group}/>
	</div>
}
