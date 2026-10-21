/// Numbered line column and pleading rules for U.S. letter pleading paper.
/// All dimensions are caller-supplied from the applicable local rule.
#let line-numbers(left-margin, top-margin, pitch, count, type-size, top-edge: none, bottom-edge: none) = {
  for i in range(1, count + 1) {
    let label = if top-edge == none and bottom-edge == none {
      text(size: type-size, str(i))
    } else {
      text(size: type-size, top-edge: top-edge, bottom-edge: bottom-edge, str(i))
    }
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.5in, height: pitch,
        align(right, label)))
  }
}

#let pleading-rules(page-width, page-height, left-margin, right-margin) = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-height), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-height), stroke: 0.75pt))
  place(top + left, dx: page-width - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-height), stroke: 0.75pt))
}

#let background(page-width, page-height, left-margin, right-margin, top-margin, pitch, count, type-size,
  top-edge: none, bottom-edge: none) = {
  line-numbers(left-margin, top-margin, pitch, count, type-size, top-edge: top-edge, bottom-edge: bottom-edge)
  pleading-rules(page-width, page-height, left-margin, right-margin)
}
