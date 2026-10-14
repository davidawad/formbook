// N.D. Ohio bankruptcy court: motion with memorandum (FRBP 9013, 9014, 9004, 7010 caption; LBR 5005-1,
// 9013-1 (notice, response), 9013-2 (20-page limit, 12-point type), 9013-3 (certificate of service)).
// Content-agnostic: case facts come from the frontmatter (`meta`) and the markdown body. Sizes that the
// rules do not set are conventions, cited in README.md.
#import "@preview/cmarker:0.1.10"

// ---- page and type ----
#let page-margin = 1in          // convention: no N.D. Ohio margin rule (LBR 5005-1 sets paper size only)
#let type-size = 12pt          // LBR 9013-2(a): at least 12 point, footnotes included (mandated)
#let leading = 1.4em           // convention: double spacing, as the filed exemplars; see README
#let serif = "EB Garamond"     // vendored (fonts/eb-garamond); --ignore-system-fonts makes any other face an error

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Caption per FRBP 9004(b) and 7010 (court, title, case and adversary numbers, designation).
#let caption(meta) = {
  align(center)[
    #upper[#meta.court.at(0)] \
    #upper[#meta.court.at(1)]
    #if "division" in meta [ \ #upper[#meta.division] ]
  ]
  v(1.2em)

  let left = ()
  for d in meta.debtor-caption { left.push(d) }
  left.push("Debtor.")
  if "parties" in meta {
    left.push("")
    left.push("____________________________________")
    left.push("")
    for p in meta.parties.plaintiffs { left.push(upper(p)) }
    left.push(meta.parties.plaintiff-designation)
    left.push("")
    left.push("v.")
    left.push("")
    for d in meta.parties.defendants { left.push(upper(d)) }
    left.push(meta.parties.defendant-designation)
  }

  let right = ("Case No. " + meta.case-number, "")
  if "chapter" in meta { right.push("Chapter " + meta.chapter) ; right.push("") }
  if "judge" in meta { right.push("Judge " + meta.judge) ; right.push("") }
  if "adversary-number" in meta { right.push("Adv. Pro. No. " + meta.adversary-number) }

  let n = calc.max(left.len(), right.len())
  let cells = ()
  for i in range(n) {
    cells.push(if i < left.len() { left.at(i) } else { "" })
    cells.push(align(center)[)])
    cells.push(if i < right.len() { right.at(i) } else { "" })
  }
  set par(first-line-indent: 0pt, leading: 0.6em)
  grid(
    columns: (1.3fr, 0.3in, 1fr),
    row-gutter: 0.35em,
    ..cells,
  )
  v(1.2em)
  align(center)[#text(weight: "bold")[#meta.title]]
  v(1.2em)
}

/// Signature block (LBR 5005-1(c)): "s/" name, typewritten name, firm, address, phone, e-mail, bar number.
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

/// Notice and certificate of service: the notice wording is LBR 9013-1(a)(2) (14 days; the court may
/// grant without further notice). The certificate content is LBR 9013-3(1)-(4).
#let certificate(meta) = {
  block(breakable: false)[
    #v(1.5em)
    #align(center)[#text(weight: "bold")[NOTICE OF MOTION]]
    #v(0.6em)
    Any objection to this motion must be filed within 14 days, or such other time as specified by applicable Federal Rule of Bankruptcy Procedure or statute or as the Court may order, from the date of service as set forth on the certificate of service below, if the relief sought is opposed. The Court is authorized to grant the relief requested without further notice unless a timely objection is filed.
  ]
  block(breakable: false)[
    #v(1.5em)
    #align(center)[#text(weight: "bold")[CERTIFICATE OF SERVICE]]
    #v(0.6em)
    I hereby certify that on #meta.service.date, a true copy of the foregoing #meta.service.document was served #meta.service.method-ecf #meta.service.method-mail
    #for e in meta.service.entities [ \ #e ]
    #v(1.2em)
    #block(width: 3.3in)[
      s/ #meta.signature.signer
      #v(0.2em)
      #meta.signature.signer-name-printed
    ]
  ]
}

#let ohnb-motion-brief(meta, body) = {
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

  // Headings: centered, bold, capitals at levels 1 and 2 (section and memorandum headings).
  show heading: set par(first-line-indent: 0pt)
  show heading.where(level: 1): it => block(above: 1.4em, below: 1em, width: 100%, align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(above: 1.2em, below: 0.8em, width: 100%, align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 3): it => block(above: 1em, below: 0.6em, text(size: type-size, weight: "bold", it.body))

  caption(meta)

  // The motion runs to the first "# MEMORANDUM" heading; the memorandum follows it. Each part is signed.
  let at = body.position("# MEMORANDUM")
  if at == none { panic("ohnb-motion-brief: the sample needs a '# MEMORANDUM' heading") }
  cmarker.render(body.slice(0, at), raw-typst: false, smart-punctuation: true, h1-level: 1)
  signature(meta.signature)
  cmarker.render(body.slice(at), raw-typst: false, smart-punctuation: true, h1-level: 1)
  signature(meta.signature)
  certificate(meta)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohnb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}
