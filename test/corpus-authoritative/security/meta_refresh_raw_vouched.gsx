package views

import "github.com/gsxhq/gsx"

component VouchedRefresh(u gsx.RawURL) {
	<meta http-equiv="refresh" content={u}/>
}
