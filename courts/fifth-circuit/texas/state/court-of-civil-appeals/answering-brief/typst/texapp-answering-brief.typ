#import "@preview/cmarker:0.1.10"
#let render(src) = {
  let fm = src.match(regex("(?s)^---\\n(.*?)\\n---\\n"))
  if fm == none { panic("sample requires YAML frontmatter") }
  let meta = yaml(bytes(fm.captures.at(0)))
  let body = src.slice(fm.end)
  set page(paper: "us-letter", margin: 1in)
  set text(font: "EB Garamond", size: 14pt, lang: "en")
  set par(leading: 0.94em, justify: true, first-line-indent: 0.5in)
  align(center)[
    #text(weight: "bold")[IN THE COURT OF APPEALS]
    #linebreak()
    #text(weight: "bold")[FIFTH DISTRICT OF TEXAS AT DALLAS]
  ]
  v(0.25in)
  align(right)[No. #meta.case_number]
  v(0.3in)
  align(center)[#meta.parties]
  v(0.2in)
  align(center)[
    On Appeal from the #meta.trial_court
    #linebreak()
    #meta.county County, Texas
    #linebreak()
    Trial Court Cause No. #meta.trial_cause
  ]
  v(0.4in)
  align(center)[#text(weight: "bold")[#upper(meta.brief_title)]]
  v(0.3in)
  align(center)[#meta.counsel]
  pagebreak()
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
}
