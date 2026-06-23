// line comment
/* block comment */

component Card(title string) {
  <div class="container">
    <h1>{ title |> upper }</h1>
    <Button label="click me" disabled />
    <nav.Link href="/home">home</nav.Link>
    {/* content comment */}
    <!-- html comment -->
    <>
      <span>fragment child</span>
    </>
    { title |> upper? }
  </div>
}
