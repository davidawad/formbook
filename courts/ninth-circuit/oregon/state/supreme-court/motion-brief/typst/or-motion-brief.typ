// Oregon Supreme Court (or): motion, with an optional supporting memorandum and certificate of filing and service.
//
// ORAP 7.10 (motion titles, OR-MOT-001) and 1.45 (caption, type, OR-FORM-010, -011); the printed area of ORAP
// 5.05(3)(a)(ii) (OR-FORM-002) applies to every document the court receives. Motions carry no word or page limit
// (OR-MOT-004). ORAP 5.05(3)(c) top page numbering is a brief rule, so a motion is numbered at the bottom centre.
// Content-agnostic: no case-specific text, no measured coordinates, no forced line breaks.
// The body is markdown: `#` a section heading (centred, bold, capitals). The signature block and the certificate
// of filing and service come from the frontmatter.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // OR-FORM-003: Times New Roman; the court's eval.yaml sets 14 pt for every document.
#let type-size = 14pt
#let body-leading = 1.65em                 // double-spaced text (OR-FORM-006 is a brief rule; the exemplar's motion body is double-spaced)
#let single-leading = 0.45em
#let margin-top = 0.75in                   // OR-FORM-002: the printed area of a brief, applied to every document.
#let margin-bottom = 0.75in
#let margin-inside = 1.25in
#let margin-outside = 1in
#let para-indent = 0.5in
#let sig-indent = 3.2in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("or-motion-brief: the input must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("or-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A caption line: each leading "~" indents it by half an inch.
#let cap-line(s) = {
  let n = s.len() - s.trim("~", at: start).len()
  if n > 0 { h(0.5in * n) + inl(s.slice(n)) } else { inl(s) }
}

/// Signature block (ORAP 1.45(1)(b): name, address and telephone number of the signer): the date at the left, the
/// closing and the signer's lines right of centre, never split.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    grid(columns: (sig-indent - margin-inside + 1in, 1fr),
      if "date" in sig [ #inl(sig.date) ] else [],
      [
        #for (i, l) in sig.lines.enumerate() [ #if i > 0 [ \ ] #inl(l) ]
      ])
  })
}

/// Caption (OR-FORM-010, ORAP 1.45(1)): the case number and the court between rules, the parties at the left, a
/// column of parentheses, the lower-court and appellate case numbers at the right, then the title between rules.
#let caption-block(meta, title) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center)[#need(meta, "case_number")]
  v(0.5em)
  line(length: 100%, stroke: 0.5pt)
  v(0.3em)
  align(center)[#need(meta, "court_line")]
  v(0.3em)
  line(length: 100%, stroke: 0.5pt)
  v(0.3em)
  let cap = need(meta, "caption")
  let n = calc.max(cap.left.len(), cap.right.len())
  grid(columns: (1fr, 0.3in, 1fr), row-gutter: single-leading,
    ..for i in range(n) {
      (if i < cap.left.len() { cap-line(cap.left.at(i)) } else { [] }, [)], if i < cap.right.len() { cap-line(cap.right.at(i)) } else { [] })
    })
  v(0.3em)
  line(length: 100%, stroke: 0.5pt)
  v(0.5em)
  align(center, text(weight: "bold", upper(inl(title))))
  v(0.3em)
  line(length: 100%, stroke: 0.5pt)
  v(0.8em)
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let or-motion-brief(meta, body) = {
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
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.9em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show footnote.entry: it => {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    it
  }

  caption-block(meta, need(meta, "brief_title"))
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  v(0.3in)
  signature-block(need(meta, "signature"))

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
    v(0.4em)
    signature-block(svc.at("signature", default: need(meta, "signature")))
  }
}
