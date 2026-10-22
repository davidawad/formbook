// Court of Appeals of Oregon (orctapp): motion with its supporting memorandum, exhibit and certificate.
//
// ORAP 7.10 (motion titles, ORCTAPP-MOT-001) and 1.45 (caption, type, ORCTAPP-MOT-005). Motions carry no word
// or page limit in ORAP 7.10 (ORCTAPP-MOT-004). ORAP 5.05(3)(c) top page numbering is a brief rule, so a
// motion is numbered at the bottom centre (the filed exemplar prints no page numbers).
// Content-agnostic: no case-specific text, no measured coordinates, no forced line breaks.
// The body is split into parts by the markers "# MEMORANDUM OF ADDITIONAL AUTHORITIES" and "# EXHIBIT A";
// each part starts on a new page. The certificate of service comes from the frontmatter.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // ORCTAPP-FORM-003 applies to briefs; ORCTAPP-FORM-011 and the court's eval.yaml set 14 pt here too.
#let type-size = 14pt
#let body-leading = 1.65em                 // double-spaced text (ORCTAPP-FORM-006 is a brief rule; the exemplar's motion body is double-spaced)
#let single-leading = 0.45em
#let margin-top = 0.75in                   // ORCTAPP-FORM-002: the same printed area as a brief, applied to every document in the court.
#let margin-bottom = 0.75in
#let margin-inside = 1.25in
#let margin-outside = 1in
#let para-indent = 0.5in
#let sig-indent = 3.2in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let cm(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("orctapp-motion-brief: the input must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("orctapp-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split at the first occurrence of a marker line; returns (before, after) with after = none when absent.
#let split-part(s, marker) = {
  let i = s.position(marker)
  if i == none { (s, none) } else { (s.slice(0, i), s.slice(i + marker.len())) }
}

#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "closing" in sig [ #inl(sig.closing) #v(0.8em) ]
    #underline[/s/ #emph(sig.signer)]
    #for l in sig.at("lines", default: ()) [ \ #inl(l) ]
  ])
}

/// Caption (ORCTAPP-FORM-010, ORAP 1.45(1)): court, parties on the left; the lower court, the appellate
/// number and the title on the right.
#let caption-block(meta, title) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center)[#text(weight: "bold")[IN THE COURT OF APPEALS OF THE STATE OF OREGON]]
  v(0.3in)
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.25in,
    [
      #for (i, side) in meta.caption.enumerate() {
        if i > 0 {
          v(0.5em)
          align(center)[v.]
          v(0.5em)
        }
        for n in side.names [ #inl(n) ]
        [ #emph(side.designation) ]
      }
    ],
    [
      #for l in meta.at("lower_court", default: ()) [ #inl(l) \ ]
      #v(0.3in)
      Appellate Court No. #need(meta, "case_number")
      #v(0.3in)
      #text(weight: "bold", upper(inl(title)))
    ],
  )
  v(0.4in)
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

#let counsel-grid(meta) = {
  if "counsel" in meta {
    v(0.4em)
    grid(columns: (1fr, 1fr), column-gutter: 0.3in, ..meta.counsel.map(g => counsel-group(g)))
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let orctapp-motion-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-inside, right: margin-outside),
    footer-descent: 0.3in,
    footer: context align(center, counter(page).display()),
    numbering: "1",
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show footnote.entry: it => {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Part 1: the motion ----
  caption-block(meta, need(meta, "brief_title"))
  let (motion, rest) = split-part(body, "\n# MEMORANDUM OF ADDITIONAL AUTHORITIES\n")
  cm(motion)
  v(0.3in)
  block(width: 100%, breakable: false)[#signature-block(need(meta, "signature"))]
  counsel-grid(meta)

  // ---- Part 2: the memorandum ----
  if rest != none {
    let (memo, rest2) = split-part(rest, "\n# EXHIBIT A\n")
    pagebreak(weak: true)
    caption-block(meta, need(meta, "memorandum_title"))
    cm(memo)
    v(0.3in)
    block(width: 100%, breakable: false)[#signature-block(meta.at("memo_signature", default: need(meta, "signature")))]
    counsel-grid(meta)

    // ---- Part 3: the exhibit (heading generated; its text follows) ----
    if rest2 != none {
      pagebreak(weak: true)
      heading(level: 1, outlined: false)[Exhibit A]
      cm(rest2)
    }
  }

  // ---- Certificate of filing and service (ORAP 16.45) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[#inl(svc.at("heading", default: "Certificate of Filing and Service"))]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    v(0.4em)
    block(width: 100%, breakable: false)[#signature-block(svc.at("signature", default: need(meta, "signature")))]
  }
}
