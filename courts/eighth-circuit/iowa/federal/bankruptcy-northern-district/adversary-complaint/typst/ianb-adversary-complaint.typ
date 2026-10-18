// Adversary complaint, United States Bankruptcy Court, N.D. Iowa.
// Governing rules and the reading of each: ../README.md. Entry point: main.typ.
// The markdown body (usage/<id>.md) is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (fields listed in ../README.md).
#import "@preview/cmarker:0.1.10"

#let font-family = "EB Garamond"   // vendored in fonts/. No N.D. Iowa rule names a font (README, gap 1).
#let type-size = 13pt              // EB Garamond at 13 pt sets close to Times 12 pt (README, gap 2).
#let body-leading = 1.2em          // gap between lines of body text; double-spaced (README, gap 3).
#let para-indent = 0.5in
#let page-margin = 1in
#let heading-space = 12pt

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("(?s)^---\n(.*?)\n---\n"))
  assert(m != none, message: "sample needs YAML frontmatter")
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  assert(key in meta, message: "frontmatter field missing: " + key)
  meta.at(key)
}

#let para-no = counter("para-no")

/// The caption: court name, then party block on the left and case numbers and title on the right
/// (FRBP 7010 and 9004(b); the form follows the exemplars).
#let caption(meta) = {
  align(center, stack(
    dir: ttb,
    spacing: 0.3em,
    text(weight: "bold")[IN THE UNITED STATES BANKRUPTCY COURT],
    text(weight: "bold")[FOR THE NORTHERN DISTRICT OF IOWA],
  ))
  v(1.5em)
  grid(
    columns: (3.3in, 1fr),
    block(width: 100%, inset: (right: 12pt, bottom: 10pt), stroke: (right: 0.75pt, bottom: 0.75pt))[
      In re:
      #v(0.6em)
      #pad(left: 0.5in)[#need(meta, "debtor")]
      #v(0.6em)
      #align(right)[Debtor.]
      #v(0.8em)
      #pad(left: 0.5in)[#need(meta, "plaintiff")]
      #v(0.6em)
      #align(right)[Plaintiff,]
      #v(0.6em)
      #pad(left: 0.5in)[v.]
      #v(0.6em)
      #pad(left: 0.5in)[#need(meta, "defendant")]
      #v(0.6em)
      #align(right)[Defendant.]
    ],
    block(width: 100%, inset: (left: 16pt, top: 2em))[
      #need(meta, "chapter")
      #v(0.4em)
      #need(meta, "case_no")
      #v(1.6em)
      #meta.at("adversary_no", default: "Adversary Case No. ____________")
      #v(1.6em)
      #text(weight: "bold")[#need(meta, "title")]
    ],
  )
  v(1.2em)
}

#let heading-block(t) = {
  v(heading-space, weak: true)
  block(sticky: true, width: 100%, align(center, text(weight: "bold", inl(t))))
  v(0.7em)
}

/// Numbered allegation (FRCP 10(b)): the template numbers every body paragraph; the
/// sample does not type the number.
#let numbered-para(c) = block(width: 100%, par(first-line-indent: 0pt)[
  #h(para-indent) #para-no.step()#context para-no.display()#h(0.25in) #inl(c)
])

#let plain-para(c) = block(width: 100%, below: 0.6em, par(first-line-indent: 0pt)[#h(para-indent) #inl(c)])

/// Items of a markdown ordered list, one string per item (continuation lines are joined).
#let list-items(c) = {
  let out = ()
  for line in c.split("\n") {
    let m = line.match(regex("^\\s*\\d+\\.\\s+(.*)$"))
    if m != none {
      out.push(m.captures.at(0))
    } else if out.len() > 0 {
      let k = out.len() - 1
      out.at(k) = out.at(k) + " " + line.trim()
    }
  }
  out
}

/// Prayer items: lettered (a), (b), ... by the template.
#let lettered-list(c) = {
  for (i, it) in list-items(c).enumerate() {
    grid(
      columns: (1in, 1fr),
      row-gutter: 0.6em,
      [#h(0.5in) (#numbering("a", i + 1))],
      block(width: 100%, par(first-line-indent: 0pt, inl(it))),
    )
  }
}

/// Body chunks are blank-line separated. A `#` or `##` chunk is a centered bold heading.
/// A numbered-list chunk is lettered. Other paragraphs are numbered, except those before
/// the first heading and those starting with COMES NOW or WHEREFORE (unnumbered by rule).
#let render-body(md) = {
  let front = true
  for c in md.split("\n\n").map(x => x.trim()).filter(x => x != "") {
    if c.starts-with("## ") {
      front = false
      heading-block(c.slice(3))
    } else if c.starts-with("# ") {
      front = false
      heading-block(c.slice(2))
    } else if c.match(regex("^\\d+\\. ")) != none {
      lettered-list(c)
    } else if front or c.starts-with("COMES NOW") or c.starts-with("WHEREFORE") {
      plain-para(c)
    } else {
      numbered-para(c)
    }
  }
}

/// Signature block (FRBP 9011; N.D. Iowa L.R. 9010-1(b): business address, telephone,
/// e-mail and FAX below the signature).
#let signature(meta) = {
  let s = need(meta, "signature")
  block(breakable: false, above: 1.8em, grid(
    columns: (1fr, 3.9in),
    [Dated: #s.date],
    stack(
      dir: ttb,
      spacing: 0.25em,
      [Respectfully submitted,],
      v(2.4em),
      [#text(style: "italic")[/s/ #s.signer]],
      [#s.signer, #s.bar],
      ..s.address.map(l => [#l]),
      [#s.firm],
      [Telephone: #s.phone],
      [Fax: #s.fax],
      [E-mail: #s.email],
      v(1em),
      [#s.role],
    ),
  ))
}

#let complaint(meta, md) = {
  // FRBP 7008(a): the complaint must say whether the pleader consents to final orders.
  assert(md.contains("consent"), message: "FRBP 7008(a): the complaint must state whether the pleader consents to final orders or judgment by the bankruptcy court")
  assert(not md.contains("[^"), message: "footnotes are not supported in the adversary complaint template")
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: 10pt)[
      Page #counter(page).display() of #counter(page).final().first()
    ]),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, justify: false, linebreaks: "optimized")
  caption(meta)
  render-body(md)
  signature(meta)
}
