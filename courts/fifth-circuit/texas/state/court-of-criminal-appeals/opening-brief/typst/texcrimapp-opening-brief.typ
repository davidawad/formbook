#import "@preview/cmarker:0.1.10"

#let opening-brief(source) = {
  let fm = source.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if fm == none { panic("opening brief sample requires YAML frontmatter") }
  let meta = yaml(bytes(fm.captures.at(0)))
  let body = source.slice(fm.end)
  let required = ("case_number", "style_petitioner", "style_respondent", "filing_party", "brief_title", "appeal_from", "lead_counsel", "counsel_lines")
  for key in required { if key not in meta { panic("opening brief sample missing frontmatter field: " + key) } }
  set document(title: meta.brief_title, author: meta.filing_party)
  set page(paper: "us-letter", margin: 1in, numbering: "1", footer: context align(center)[#counter(page).display()])
  set text(font: "EB Garamond", size: 14pt, lang: "en")
  set par(leading: 0.95em, first-line-indent: 0.5in, justify: true)
  show heading.where(level: 1): it => { set text(hyphenate: false); set par(first-line-indent: 0pt, leading: 0.15em); block(width: 100%, sticky: true, above: 0.6em, below: 0.4em, align(center, strong(upper(it.body)))) }
  show heading.where(level: 2): it => { set par(first-line-indent: 0pt, leading: 0.15em); block(sticky: true, above: 0.5em, below: 0.25em, strong(it.body)) }
  show heading.where(level: 3): it => { set par(first-line-indent: 0pt, leading: 0.15em); block(sticky: true, above: 0.4em, below: 0.25em, emph(it.body)) }
  align(center)[
    #v(0.35in)
    #text(size: 14pt, weight: "bold")[IN THE TEXAS COURT OF CRIMINAL APPEALS]
    #v(0.3in)
    #text(size: 14pt)[No. #meta.case_number]
    #v(0.2in)
    #strong(meta.style_petitioner)
    #v(0.08in)
    v.
    #v(0.08in)
    #strong(meta.style_respondent)
    #v(0.2in)
    #meta.appeal_from
    #v(0.32in)
    #text(size: 16pt, weight: "bold")[#upper(meta.brief_title)]
    #v(0.35in)
    #meta.filing_party
    #v(0.12in)
    #meta.lead_counsel
    #for line in meta.counsel_lines { linebreak(); line }
    #if "filed_date" in meta { v(0.25in); meta.filed_date }
  ]
  pagebreak()
  cmarker.render(body, smart-punctuation: false, raw-typst: false)
}
