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

/// Dot leader and page reference glued so the reference always ends the entry's last line
/// after the leaders, never alone on a line. A short fixed run of dots keeps the leader from
/// shrinking to nothing; word joiners forbid a break around the fill; the page list's own
/// spaces are made non-breaking. `page` is a string or text content.
#let leader-page-glued(dot-gap, page, min-leader: 1.5em, page-gap: 0.3em) = {
  let page = if type(page) == str { page.replace(" ", "\u{a0}") } else { page }
  box(width: min-leader, repeat[.#h(dot-gap)])
  sym.wj
  dot-leader(dot-gap)
  sym.wj
  h(page-gap)
  sym.wj
  page
}

/// One table-of-contents or table-of-authorities entry whose page reference can never wrap alone (DEF-TOC-001).
/// The title wraps under `hang`, dot leaders fill the rest of its last line, and the page reference sits in its
/// own column, level with that last line. `page-width` (auto: the reference's own width) also narrows every
/// line of the title, as LaTeX's \@tocrmarg does. `leading: auto` inherits the paragraph leading. A
/// `min-leader` above 0pt keeps at least that much leader, glued to the title's last word (which moves down
/// with it when the line is full), so the entry always prints some dots.
#let leader-row(title, page, hang: 0pt, dot-gap: 0.16em, lead-gap: 0.6em, gutter: 0.3em, page-width: auto,
  leading: auto, min-leader: 0pt) = grid(
  columns: (1fr, page-width), column-gutter: gutter, align: (left, right + bottom),
  {
    set par(leading: leading) if leading != auto
    par(hanging-indent: hang, first-line-indent: 0pt, justify: false, {
      title
      if min-leader > 0pt {
        sym.wj
        box({ h(lead-gap); box(width: min-leader, repeat[.#h(dot-gap)]) })
      } else {
        h(lead-gap)
      }
      dot-leader(dot-gap)
    })
  },
  page,
)
