package p

component Panel(header interface{}) { <div>{header}</div> }

component Demo() { <Panel header={<h1>Hi</h1>}></Panel> }
