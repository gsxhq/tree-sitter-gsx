package views

component Label(rank int) {
	<span class={ "label", if rank == 1 { "gold" } else if rank == 2 { "silver" } else { "bronze" } }>ok</span>
}
