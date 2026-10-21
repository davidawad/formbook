/// Style the standard unnumbered section heading used by brief templates.
#let section-heading(body, size, leading, above: 1.5em, below: 1.1em) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: leading, justify: false)
  set text(size: size)
  block(width: 100%, sticky: true, above: above, below: below,
    align(center, text(size: 1.15em, strong(upper(body)))))
}

/// Emit a body-sized, bold, left-aligned unnumbered subheading.
#let plain-subheading(body, size, leading, above: 1.2em, below: 0.9em) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: leading, justify: false)
  set text(size: size)
  block(width: 100%, sticky: true, above: above, below: below, strong(body))
}
