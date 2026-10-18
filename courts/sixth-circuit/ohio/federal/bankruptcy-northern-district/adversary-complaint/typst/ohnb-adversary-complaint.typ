// N.D. Ohio bankruptcy court: adversary complaint (FRBP 7001, 7003, 7008, 7010; LBR 5005-1, 7003-1).
// Content-agnostic: everything case-specific comes from the frontmatter of the sample (`meta`) or the
// markdown body. Numbers and sizes below are the court's rules or project conventions, cited in README.md.
#import "@preview/cmarker:0.1.10"

// ---- page and type (LBR 5005-1(a)(1): 8 1/2 x 11 inch, one side) ----
#let page-margin = 1in          // convention: no N.D. Ohio margin rule for complaints (LBR 5005-1 silent)
#let type-size = 12pt          // convention: LBR 9013-2(a) sets 12 pt for motions and briefs; complaints follow
#let leading = 1.4em           // double spacing: 24 pt line pitch at 12 pt type (matches the filed exemplar); see README
#let serif = ("Times New Roman", "Liberation Serif") // Times New Roman substitute, the default per docs/FONTS.md (fonts/liberation-serif)

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Caption per FRBP 9004(b) (court name, title, case number and adversary number, designation of the
/// document) and FRBP 7010 (the caption substantially conforms to Official Form 416A).
#let caption(meta) = {
  align(center)[
    #upper[#meta.court.at(0)] \
    #upper[#meta.court.at(1)]
    #if "division" in meta [ \ #upper[#meta.division] ]
  ]
  v(1.2em)

  let left = ()
  for d in meta.debtor-caption { left.push(d) }
  left.push("")
  left.push("Debtor.")
  left.push("")
  left.push("____________________________________")
  left.push("")
  for p in meta.plaintiffs { left.push(upper(p)) }
  left.push("Plaintiff,")
  left.push("")
  left.push("v.")
  left.push("")
  for d in meta.defendants { left.push(upper(d)) }
  left.push("Defendant.")

  let right = (
    "Case No. " + meta.case-number,
    "",
    "Chapter " + meta.chapter,
    "",
    "Judge " + meta.judge,
    "",
    "Adv. Pro. No. " + meta.adversary-number,
    "",
  )
  let n = calc.max(left.len(), right.len())
  let rows = ()
  for i in range(n) {
    rows.push((
      if i < left.len() { left.at(i) } else { "" },
      ")",
      if i < right.len() { right.at(i) } else { "" },
    ))
  }
  set par(first-line-indent: 0pt, leading: 0.6em)
  grid(
    columns: (1.3fr, 0.3in, 1fr),
    row-gutter: 0.35em,
    ..rows.flatten().map(c => if c == ")" { align(center)[)] } else { c }),
  )
  v(1.2em)
  align(center)[#text(weight: "bold")[#meta.title]]
  v(1.2em)
}

/// Signature block (LBR 5005-1(c): typewritten name, firm, address, phone, e-mail, bar number, "s/name").
#let signature(sig) = {
  v(1.5em)
  block(width: 3.3in, breakable: false)[
    Respectfully submitted,
    #v(1em)
    s/ #sig.signer
    #v(0.2em)
    #sig.signer-name-printed
    #for l in sig.lines [ \ #inl(l) ]
  ]
}

#let ohnb-adversary-complaint(meta, body) = {
  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    number-align: center,
    footer-descent: 30%,
  )
  set text(font: serif, size: type-size, lang: "en")
  set par(justify: false, leading: leading, first-line-indent: (amount: 0.5in, all: true), spacing: 0.9em)

  // Headings: centered, bold, capitals at levels 1 and 2 (count and section headings).
  show heading: set par(first-line-indent: 0pt)
  show heading.where(level: 1): it => block(above: 1.4em, below: 1em, width: 100%, align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(above: 1.2em, below: 0.8em, width: 100%, align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 3): it => block(above: 1em, below: 0.6em, text(size: type-size, weight: "bold", it.body))


  caption(meta)

  let md = cmarker.render(
    body,
    raw-typst: false,
    smart-punctuation: true,
    h1-level: 1,
  )
  md

  signature(meta.signature)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}
