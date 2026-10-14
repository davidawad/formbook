// Adversary complaint for the United States Bankruptcy Court for the District of Idaho (idb).
// Rules: Fed. R. Bankr. P. 7001, 7003, 7010 (Fed. R. Civ. P. 10 applies; the caption must substantially
// conform to Official Form 416), 9004(a)-(b) (legible; caption content); D. Idaho LBR 5005-1(c) (counsel
// block, 12-14 point type, caption form), LBR 7003-1 (cover sheet; judge suffix on the case and adversary
// numbers). See ../README.md for the meaning of every parameter.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"   // LBR 5005-1(c)(2): 12 to 14 point type; the only vendored face (README)
#let type-size = 13pt              // inside the 12-14 point range; EB Garamond at 13 pt reads like Times 12 pt
#let body-leading = 0.85em         // double-spaced body (the exemplar's body); pitch measured in README
#let para-indent = 0.5in           // first-line indent of numbered allegations
#let margin-x = 1in
#let margin-top = 1in              // LBR 5005-1(c)(1): counsel information starts 1 inch from the top
#let margin-bottom = 1in
#let caption-left = 3.4in          // width of the party column of the caption
#let counsel-leading = 0.45em      // single spacing for counsel, caption, signature

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if m == none { panic("idb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body (the markdown contract in ../README.md).
#let chunks(body) = body.split(regex("\\n\\s*\\n")).map(c => c.trim()).filter(c => c != "")

#let para-n = counter("idb-para")
#let num-on = state("idb-num-on", true)   // off after the prayer heading: the prayer is not numbered
#let letters = "abcdefghijklmnopqrstuvwxyz"

// ---------------------------------------------------------------------------
// Caption and cover
// ---------------------------------------------------------------------------

/// Party names one per line, then the designation centered under them (the exemplar's layout).
#let party-block(p) = {
  for n in p.names { align(left, inl(n)) }
  v(0.3em)
  align(center, p.designation)
}

#let caption(meta) = table(
  columns: (caption-left, 1fr),
  stroke: none,
  inset: (x: 0pt, y: 0pt),
  gutter: 0pt,
  table.vline(x: 1, stroke: 0.75pt),
  // left column: the debtor(s), a rule, then the plaintiff and the defendants
  [
    #pad(right: 0.2in)[
      #align(left)[In re:] #v(0.6em)
      #party-block(meta.debtors)
      #v(0.6em)
      #line(length: 100%, stroke: 0.75pt)
      #v(0.6em)
      #for p in meta.parties {
        party-block(p)
        v(0.6em)
      }
    ]
  ],
  // right column: case identifiers
  [
    #pad(left: 0.3in)[
      #v(0.6em)
      Case No. #meta.case_number #v(0.9em)
      Chapter #meta.chapter #v(0.9em)
      Adv. No. #if meta.at("adv_number", default: "") != "" [#meta.adv_number] #v(0.9em)
    ]
  ],
)

/// Counsel block: upper left, single spaced, from the top margin (LBR 5005-1(c)(1)).
#let counsel-block(lines) = {
  set par(leading: counsel-leading, spacing: 0pt)
  for l in lines { inl(l); linebreak() }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A numbered allegation (Fed. R. Civ. P. 10(b)): the template numbers them; the sample does not.
#let numbered(c) = {
  para-n.step()
  context if num-on.get() {
    par(first-line-indent: 0pt)[
      #h(para-indent) #context para-n.display()#h(0.25in)#inl(c)
    ]
  } else {
    par(first-line-indent: 0pt)[#h(para-indent) #inl(c)]
  }
}

/// A list of lettered items (the prayer and similar lists); item text is markdown.
#let lettered(items) = {
  for (i, it) in items.enumerate() {
    grid(columns: (0.75in, 1fr), gutter: 0pt, [#h(para-indent)#("(" + letters.at(i) + ")")], inl(it))
  }
}

/// Body chunks: `# ` centered bold caps; `## ` centered bold; `### ` bold at the left;
/// `- ` lettered items; anything else is a numbered allegation.
#let render-chunk(c) = {
  if c.starts-with("# ") {
    if c.slice(2).starts-with("PRAYER") { num-on.update(false) }
    block(width: 100%, sticky: true, above: 1.2em, below: 0.6em,
      align(center, text(weight: "bold", inl(c.slice(2)))))
  } else if c.starts-with("## ") {
    block(width: 100%, sticky: true, above: 0.9em, below: 0.6em,
      align(center, text(weight: "bold", inl(c.slice(3)))))
  } else if c.starts-with("### ") {
    block(width: 100%, sticky: true, above: 0.9em, below: 0.4em,
      text(weight: "bold", inl(c.slice(4))))
  } else if c.starts-with("- ") {
    lettered(c.split("\n").map(l => l.trim()).filter(l => l != "").map(l => l.slice(2)))
  } else {
    numbered(c)
  }
}

#let signature-block(meta) = {
  let s = meta.signature
  block(width: 100%, sticky: true, {
    v(1.2em)
    par(first-line-indent: 0pt)[Date: #meta.date]
    v(0.8em)
    pad(left: 3.0in, {
      set par(leading: counsel-leading, spacing: 0pt)
      for l in s.at("lines_above", default: ()) { inl(l); linebreak() }
      v(0.6em)
      [/s/ #s.signer]
      linebreak()
      [#upper(s.signer)]
      linebreak()
      for l in s.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// Entry point: idb-adversary-complaint(meta, body)
// ---------------------------------------------------------------------------
#let idb-adversary-complaint(meta, body) = {
  // judge suffix on the case and adversary numbers (LBR 7003-1(b)(1), (c)(1))
  assert(meta.case_number.match(regex("^\\d{2}-\\d{5}-[A-Z]{3}$")) != none,
    message: "idb-adversary-complaint: case_number must end in a three-letter judge suffix (LBR 7003-1(b)(1))")
  if meta.at("adv_number", default: "") != "" {
    assert(meta.adv_number.match(regex("^\\d{2}-\\d{4,5}-[A-Z]{3}$")) != none,
      message: "idb-adversary-complaint: adv_number must end in a three-letter judge suffix (LBR 7003-1(c)(1))")
  }

  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-x, right: margin-x),
    footer: context align(center, text(size: 11pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, justify: false, spacing: 0.6em)
  set table(stroke: none)

  counsel-block(meta.counsel)
  v(1.2em)
  align(center)[
    #text(weight: "bold")[UNITED STATES BANKRUPTCY COURT] #linebreak()
    #text(weight: "bold")[DISTRICT OF IDAHO]
  ]
  v(1.0em)
  caption(meta)
  v(1.0em)
  align(center, text(weight: "bold", upper(meta.title)))
  v(0.8em)
  par(first-line-indent: 0pt)[
    #h(para-indent) #inl(meta.lead_in)
  ]

  for c in chunks(body) {
    render-chunk(c)
  }

  signature-block(meta)
}
