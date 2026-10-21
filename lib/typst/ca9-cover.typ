/// Ninth Circuit Form 1 cover body. Inline rendering and required-field checks come from the brief overlay.
#let cover-body(meta, gap, leading, need-fn, inline-fn) = {
  set par(first-line-indent: 0pt, leading: leading, spacing: 0.35em, justify: false)
  set align(center)
  v(gap * 0.6)
  strong[No. #need-fn(meta, "case_number")]
  v(gap)
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
  v(gap)
  strong[IN THE UNITED STATES COURT OF APPEALS\ FOR THE NINTH CIRCUIT]
  v(gap)
  align(center, line(length: 2in, stroke: 0.7pt))
  v(gap)
  let sides = need-fn(meta, "caption")
  for (i, side) in sides.enumerate() {
    for name in side.names { inline-fn(name); parbreak() }
    align(left, pad(left: 50%, inline-fn(side.designation)))
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  align(center, line(length: 2in, stroke: 0.7pt))
  v(gap)
  inline-fn(need-fn(meta, "proceeding"))
  if "district_court_case" in meta or "judge" in meta {
    parbreak()
    [#if "district_court_case" in meta [D.C. No. #meta.district_court_case]#if "district_court_case" in meta and "judge" in meta [; ]#if "judge" in meta [#inline-fn(meta.judge)]]
  }
  v(gap)
  align(center, line(length: 2in, stroke: 0.7pt))
  v(gap)
  strong(upper(inline-fn(need-fn(meta, "brief_title"))))
  v(gap)
  align(center, line(length: 2in, stroke: 0.7pt))
  v(gap)
  align(left, pad(left: 50%, {
    set par(hanging-indent: 0pt, spacing: 0.5em)
    let groups = need-fn(meta, "counsel")
    for (gi, g) in groups.enumerate() {
      let lines = g.at("lines", default: ())
      let display-lines = if "phone" in g {
        lines + (g.phone,)
      } else if gi == groups.len() - 1 {
        lines + (need-fn(meta, "phone"),)
      } else {
        lines
      }
      block(breakable: false, {
        for n in g.names { n; linebreak() }
        for l in display-lines { h(0.5em); emph(inline-fn(l)); linebreak() }
      })
    }
  }))
  v(gap)
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
}

/// One-page cover using the largest trial spacing that fits without shrinking the type.
#let ca9-cover(meta, leading, need-fn, inline-fn, error-prefix: "ca9-brief") = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em, leading, need-fn, inline-fn))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic(error-prefix + ": the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em, leading, need-fn, inline-fn)
}))
