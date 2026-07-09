package views

type Count int

type Toggle bool

component Gauge(value float64, n int8, c Count, on Toggle) { <div>{value}</div> }

component Page() { <Gauge value={100} n={3} c={5} on={true}/> }
