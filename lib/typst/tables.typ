/// Repeating dot leader used in tables of contents and authorities.
#let dot-leader(gap) = box(width: 1fr, repeat[.#h(gap)])

/// A linked outline row. Its page number follows the leader on the final wrapped line.
/// Courts supply their own labels, indentation, display title, and page label.
#let outline-row(target, title, label, indent, label-width, page, leading, dot-gap,
  above: 0.35em, page-width: 2.6em) = link(target, block(
  width: 100%, above: above, below: 0pt,
  par(hanging-indent: indent + label-width, first-line-indent: 0pt,
    leading: leading, justify: false, {
      h(indent)
      if label != none { box(width: label-width, label) }
      title
      h(0.8em)
      dot-leader(dot-gap)
      box(width: page-width, align(right, page))
    }),
))

/// A linked outline row with a separate page column, for courts that keep page labels on the bottom edge.
#let grid-outline-row(target, title, label, indent, label-width, page, leading, dot-gap,
  above: 0.45em, page-gap: 0.4em, page-width: 2em) = link(target, block(
  width: 100%, above: above, below: 0pt,
  grid(columns: (1fr, auto), column-gutter: page-gap,
    par(hanging-indent: indent + label-width, first-line-indent: 0pt,
      leading: leading, justify: false, {
        h(indent)
        if label != none { box(width: label-width, label) }
        title
        h(0.2em)
        dot-leader(dot-gap)
      }),
    align(right + bottom, box(width: page-width, align(right, page))),
  ),
))

/// Dot leaders and a page reference that end an entry together, set inline after its text. Word joiners
/// glue the leader to the page reference, so the page never wraps onto a line alone; at least `min` of
/// leader always precedes it (the entry's last line moves down whole, as leaders and page, when it would not fit).
#let leader-page(page, dot-gap, before: 0.4em, min: 1em, gap: 0.3em) = {
  h(before)
  box(width: min, repeat[.#h(dot-gap)])
  sym.wj
  box(width: 1fr, repeat[.#h(dot-gap)])
  sym.wj
  box[#h(gap)#page]
}
