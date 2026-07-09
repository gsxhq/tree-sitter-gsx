package views

func count(n int) (int, error) { return n * 2, nil }

component Counter(val int) { <span>{val}</span> }

component Page(n int) { <Counter val={count(n)}/> }
