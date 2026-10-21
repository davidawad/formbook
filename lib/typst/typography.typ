/// Single-spaced hanging paragraph used by headings, authorities, and outline rows.
#let hanging-paragraph(indent, leading, body) = par(
  hanging-indent: indent,
  first-line-indent: 0pt,
  leading: leading,
  justify: false,
  body,
)

/// Configure footnote entry spacing and type while leaving the court's measurements explicit.
#let footnote-style(size, leading, spacing: 0.4em, gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: none) = {
  set footnote.entry(gap: gap, clearance: clearance, indent: indent, separator: separator)
  show footnote.entry: set text(size: size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: leading, spacing: spacing)
}

/// Render a numbered footnote entry with an explicit marker and court-selected rhythm.
#let footnote-body(body, marker, size, leading, spacing, marker-gap: 0.25em, keep-together: false) = {
  set text(size: size)
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: leading, spacing: spacing)
  let entry = [#super(marker)#h(marker-gap)#body]
  if keep-together { block(breakable: false, entry) } else { entry }
}

/// Apply a centered section heading with caller-selected type size and vertical rhythm.
#let centered-section(body, size, above: 1.5em, below: 1.1em) = block(
  width: 100%, sticky: true, above: above, below: below,
  align(center, text(size: size, strong(upper(body)))),
)
