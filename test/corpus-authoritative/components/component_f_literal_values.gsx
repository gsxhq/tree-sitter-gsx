package views

import "github.com/gsxhq/gsx"

component PageHeader(title string, subtitle string) {
	<header><h1>{title}</h1><p>{subtitle}</p></header>
}

component Field(label string) {
	<label>{label}<input { attrs... }/></label>
}

component Slot(body gsx.Node) {
	<section>{body}</section>
}

component Page(count int) {
	<PageHeader title="Tickets" subtitle=f`@{count} tickets`/>
	<Field label="Ticket" data-ticket=f`ticket-@{count}`/>
	<Slot body=f`@{count} open`/>
	<div data-count=f`@{count} direct`></div>
}
