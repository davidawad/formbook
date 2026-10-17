// Motion or brief in a contested matter for the United States Bankruptcy Court for the District of Idaho (idb).
// Rules: Fed. R. Bankr. P. 9013 and 9014 (motions, contested matters), 9004(a)-(b) (legible, paper and type),
// D. Idaho LBR 5005-1(c) (counsel block starting 1 inch from the top, 12-14 point type, caption with the
// case number and judge suffix), LBR 2002-2(d)(1) (negative-notice legend in a box immediately below the
// caption), LBR 9014-1 (witness testimony notice). See ./README.md for every parameter.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LBR 5005-1(c)(2): 12 to 14 point type, no face named; kept per docs/FONTS.md (README)
#let type-size = 13pt              // inside the 12-14 point range; EB Garamond at 13 pt reads like Times 12 pt
#let note-size = 12pt              // footnotes: LBR 5005-1(c)(2) sets 12 pt as the floor for all type
#let body-leading = 1.45em         // double spacing (both filers; no rule sets it): about 2.1 em, 27.5 pt, baseline to baseline
#let single-leading = 0.45em       // single spacing: counsel, caption, signature, block quotes, notice, footnotes
#let para-indent = 0.5in           // first-line indent of paragraphs (both filers)
#let num-width = 0.5in             // paragraph number box: text after "1." and "10." starts at the same tab (both filers)
#let margin-x = 1in
#let margin-top = 1in              // LBR 5005-1(c)(1): counsel information starts 1 inch from the top
#let margin-bottom = 1in
#let caption-left = 3.4in          // width of the party column of the caption
#let sig-indent = 3.0in            // signature column (both filers sign in the right half)
#let counsel-leading = single-leading

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if m == none { panic("idb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names, footnote references, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body (the markdown contract in ./README.md).
#let chunks(body) = body.split(regex("\\n\\s*\\n")).map(c => c.trim()).filter(c => c != "")

/// A footnote definition chunk: `[^id]: text`.
#let fn-def-re = regex("^\\[\\^([^\\]]+)\\]:\\s*")
#let is-fn-def(c) = c.match(fn-def-re) != none

/// Heading text that begins with "1." or "1)" is a heading, not a list item: escape the marker.
#let no-list(s) = s.replace(regex("^(\\d+)([.)])"), m => m.captures.at(0) + "\\" + m.captures.at(1))

#let para-n = counter("idb-para")
#let num-on = state("idb-num-on", true)   // off after the prayer and certificate headings

// ---------------------------------------------------------------------------
// Caption and cover
// ---------------------------------------------------------------------------

/// Party names one per line, then the designation centered under them.
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
  [
    #set par(justify: false, leading: single-leading, spacing: 0.6em)
    #pad(right: 0.2in)[
      #align(left)[In re:] #v(0.6em)
      #party-block(meta.debtors)
    ]
  ],
  [
    #set par(justify: false, leading: single-leading, spacing: 0.6em)
    #pad(left: 0.3in)[
      #v(0.6em)
      Case No. #meta.case_number #v(0.9em)
      Chapter #meta.chapter
      #if "judge" in meta [#v(0.9em) #meta.judge]
    ]
  ],
)

/// Counsel block: upper left, single spaced, from the top margin (LBR 5005-1(c)(1)).
#let counsel-block(lines) = {
  set par(leading: counsel-leading, spacing: 0pt, justify: false)
  for l in lines { inl(l); linebreak() }
}

/// LBR 2002-2(d)(1): the negative-notice legend, immediately below the caption, in a text box
/// (2008 advisory committee note). Its words come from the sample (`meta.notice`).
#let notice-box(n) = block(width: 100%, stroke: 0.75pt, inset: (x: 0.1in, y: 0.1in), breakable: false, {
  set par(leading: single-leading, spacing: 0.9em, justify: true)
  align(center, text(weight: "bold", upper(n.heading)))
  for p in n.paragraphs {
    par(first-line-indent: 0pt, {
      if "label" in p { underline(inl(p.label)); [ ] }
      inl(p.text)
    })
  }
})

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A numbered paragraph: the template numbers them ("1."); the sample does not.
#let numbered(md) = {
  para-n.step()
  context if num-on.get() {
    par(first-line-indent: 0pt)[
      #h(para-indent)#box(width: num-width, context para-n.display("1."))#inl(md)
    ]
  } else {
    par(first-line-indent: 0pt)[#h(para-indent)#inl(md)]
  }
}

/// A bulleted list (`- `); the source's own letters or numbers, if any, stay in the item text.
#let bullets(items) = {
  for it in items {
    block(above: body-leading, below: body-leading, pad(left: para-indent,
      grid(columns: (0.3in, 1fr), gutter: 0pt, [•], inl(it))))
  }
}

/// Body chunks: `# ` centered bold; `## ` centered bold; `### ` bold at the left; `- ` bullets;
/// `> ` block quote; `~ ` unnumbered flush continuation; `: ` unnumbered indented paragraph;
/// `WHEREFORE` unnumbered; `[^id]: ` footnote definitions (set at the foot of the page of their
/// reference); anything else is a numbered paragraph. `md` is the chunk plus the footnote
/// definitions it references (cmarker resolves them).
#let render-chunk(c, md) = {
  if c.starts-with("# ") {
    if c.slice(2).starts-with("PRAYER") or c.slice(2).starts-with("CERTIFICATE") { num-on.update(false) }
    block(width: 100%, sticky: true, above: 2em, below: body-leading,
      align(center, text(weight: "bold", inl(no-list(c.slice(2))))))
  } else if c.starts-with("## ") {
    block(width: 100%, sticky: true, above: 1.4em, below: body-leading,
      align(center, text(weight: "bold", inl(no-list(c.slice(3))))))
  } else if c.starts-with("### ") {
    block(width: 100%, sticky: true, above: body-leading, below: body-leading,
      text(weight: "bold", inl(no-list(c.slice(4)))))
  } else if c.starts-with("- ") {
    bullets(md.split("\n").map(l => l.trim()).filter(l => l.starts-with("- ")).map(l => l.slice(2)))
  } else if c.starts-with("WHEREFORE") {
    par(first-line-indent: 0pt)[#h(para-indent)#inl(md)]
  } else if c.starts-with(": ") {
    par(first-line-indent: 0pt)[#h(para-indent)#inl(md.slice(2))]
  } else if c.starts-with("> ") {
    block(above: 1.4em, below: 1.4em, pad(left: 0.75in, right: 0.5in,
      par(first-line-indent: 0pt, leading: single-leading, inl(md.slice(2)))))
  } else if c.starts-with("~ ") {
    par(first-line-indent: 0pt, inl(md.slice(2)))
  } else {
    numbered(md)
  }
}

/// The date line and signature block (`meta.dated` verbatim). `signature`: `lines_above` (firm, party),
/// `signer`, `by` (prefix before "/s/", default "By "), `lines_below` (firm, party, under the name).
#let signature-block(meta) = {
  let s = meta.signature
  v(1.2em)
  par(first-line-indent: 0pt)[#h(para-indent)#meta.dated]
  v(0.8em)
  // groups of single-spaced lines in the signature column, a blank line between groups
  let group(xs) = block(above: 1em, below: 0pt, {
    set par(leading: counsel-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
    xs.map(l => inl(l)).join(linebreak())
  })
  pad(left: sig-indent, {
    let above = s.at("lines_above", default: ())
    if above.len() > 0 { group(above) }
    group((s.at("by", default: "By ") + "/s/ " + s.signer, s.signer))
    let below = s.at("lines_below", default: ())
    if below.len() > 0 { group(below) }
  })
}

/// The certificate's own signature (`meta.service_signature`: `signer`, optional `name`).
#let service-signature(s) = block(above: 1.2em, breakable: false, pad(left: sig-indent, {
  set par(leading: counsel-leading, spacing: 0pt, justify: false)
  [By /s/ #s.signer]
  linebreak()
  [#s.at("name", default: s.signer)]
}))

// ---------------------------------------------------------------------------
// Entry point: idb-motion-brief(meta, body)
// ---------------------------------------------------------------------------
#let idb-motion-brief(meta, body) = {
  // LBR 5005-1(c): case number with the judge's initials (written "20-40042-JMM" or "24-bk-00388-ngh")
  assert(meta.case_number.match(regex("^\\d{2}-(?:bk-)?\\d{5}-[A-Za-z]{3}$")) != none,
    message: "idb-motion-brief: case_number must end in a three-letter judge suffix")

  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-x, right: margin-x),
    footer: context align(center, text(size: 11pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, justify: true, spacing: body-leading)   // both filers justify; no extra space between paragraphs
  set table(stroke: none)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: note-size)   // typst's default is 0.85em (11 pt here); LBR 5005-1(c)(2) floor is 12 pt
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em, justify: true)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#h(para-indent)#super(num)#h(0.25em)#note.body]
  }

  counsel-block(meta.counsel)
  v(1.2em)
  align(center, {
    set par(leading: single-leading)
    text(weight: "bold")[UNITED STATES BANKRUPTCY COURT #linebreak() FOR THE DISTRICT OF IDAHO]
  })
  v(1.0em)
  caption(meta)
  v(1.0em)
  align(center, { set par(leading: single-leading, justify: false); text(weight: "bold", upper(meta.title)) })
  v(0.8em)
  if "notice" in meta { notice-box(meta.notice); v(0.8em) }
  par(first-line-indent: 0pt)[#h(para-indent)#inl(meta.lead_in)]

  // footnote definitions are pulled out and appended to the chunks that cite them
  let all = chunks(body)
  let defs = (:)
  for c in all.filter(is-fn-def) {
    let m = c.match(fn-def-re)
    defs.insert(m.captures.at(0), c)
  }
  let cs = all.filter(c => not is-fn-def(c))
  let with-defs(c) = {
    let md = c
    for r in c.matches(regex("\\[\\^([^\\]]+)\\]")) {
      let id = r.captures.at(0)
      assert(id in defs, message: "idb-motion-brief: footnote [^" + id + "] has no definition")
      md += "\n\n" + defs.at(id)
    }
    md
  }

  // The signature goes after the body and before the certificate of service. The body's last
  // paragraph is kept on the signature's page (unless it is a heading), so the signature never
  // stands alone.
  let cert = cs.position(c => c.starts-with("# CERTIFICATE"))
  let n-body = if cert == none { cs.len() } else { cert }
  let last = if n-body > 0 and not cs.at(n-body - 1).starts-with("#") { n-body - 1 } else { none }
  for (i, c) in cs.slice(0, n-body).enumerate() {
    if i != last { render-chunk(c, with-defs(c)) }
  }
  if last != none {
    let c = cs.at(last)
    block(breakable: false, width: 100%, { render-chunk(c, with-defs(c)); signature-block(meta) })
  } else {
    block(breakable: false, width: 100%, signature-block(meta))
  }
  for c in cs.slice(n-body) { render-chunk(c, with-defs(c)) }
  if cert != none and "service_signature" in meta { service-signature(meta.service_signature) }
}
