#import "@preview/cmarker:0.1.10"
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if m == none { panic("sample must start with YAML frontmatter") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}
#let render(meta, body) = {
  set page(paper: "us-letter", margin: 1in, numbering: "1", footer: context align(center)[#counter(page).display("1")])
  set text(font: "EB Garamond", size: 14pt, lang: "en")
  set par(leading: 0.94em, spacing: 0.94em, justify: true, first-line-indent: 0.5in)
  show par: set par(leading: 0.94em, spacing: 0.94em, first-line-indent: 0.5in)
  show block: set par(leading: 0.94em, spacing: 0.94em, first-line-indent: 0.5in)
  let title = meta.at("title")
  let sides = meta.at("caption")
  let lead = meta.at("lead_counsel")
  align(center)[No. #meta.at("case_number")
  #v(0.35in)
  #text(weight: "bold")[IN THE SUPREME COURT OF TEXAS]
  #v(0.25in)
  #sides.at(0) #v(0.08in) #align(center)[v.] #v(0.08in) #sides.at(1)
  #v(0.25in)
  #line(length: 100%)
  #v(0.2in)
  #text(weight: "bold")[#title]
  #v(0.15in)
  #line(length: 100%)
  #v(0.5in)
  #lead.at("name") #linebreak() #lead.at("office") #linebreak() #lead.at("address") #linebreak() #lead.at("phone") #linebreak() #lead.at("email") #linebreak() Texas Bar No. #lead.at("bar_number")
  ]
  pagebreak()
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
}
