package views

component Card(userColor string) {
	<style>.card{color:@{ userColor |> upper }}</style>
}
