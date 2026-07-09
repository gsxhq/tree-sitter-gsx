package views

component Card(csv string) {
	<style>.card{color:@{ csv |> parse |> pick(0) }}</style>
}
