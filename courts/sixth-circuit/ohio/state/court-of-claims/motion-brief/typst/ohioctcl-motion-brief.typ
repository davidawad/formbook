// Court of Claims of Ohio: motion with supporting memorandum (motion-brief). Rule-driven and content-agnostic.
//
// Rules (see ../../rules.md for the cited URLs):
//   L.C.C.R. 4 (A) (1): 8 1/2 x 11 paper, top 1 1/2 in left blank, caption (court, case number, first party
//   plaintiff and defendant, title), counsel name, registration number, address, e-mail and telephone.
//   L.C.C.R. 4 (C): a motion carries its brief statement of reasons and authorities.
//   L.C.C.R. 4 (E): supporting or memorandum briefs do not exceed fifteen pages.
//   EFILE Part VII (D): Times New Roman or Arial, double-spaced, at least 12 point; (F) (a): conformed "/s/" signature.
//
// No case-specific text, no coordinates measured off an exemplar, no forced line breaks. The body is markdown
// rendered by cmarker; the caption, signature and certificate come from the YAML frontmatter of the same sample.
// Frontmatter fields read by this template:
//   court          string   court title, set in capitals (e.g. "In the Court of Claims of Ohio")
//   case_number    string   the case number (L.C.C.R. 4 (A) (1))
//   parties        list     {name, role}; the first two entries are the caption (plaintiff, then defendant)
//   title          string   the title of the paper, set at right of the caption
//   counsel        list     {names, lines}: counsel's names and contact lines, printed under the signature
//   signature      map      {firm: [lines above the signers], signers: [names for /s/ lines], block: [lines under the rule]}
//   service        map      {date, served_on, method, recipients: [strings], closing} or {paragraphs: [strings]}
//   cover_page     bool     true puts the caption on its own page; default false (the court's exemplar form)

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule, or to a stated convention)
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"   // EFILE Part VII (D): Times New Roman or Arial
#let type-size = 12pt                   // EFILE Part VII (D): at least 12 point
// Double spacing (EFILE Part VII (D)): Word "double" for Times New Roman is two 1.15 em single lines, so the
// extra leading between lines is about 2.3 em minus the font's own line height (about 1.1 em).
#let body-leading = 1.2em
#let single-leading = 0.46em           // caption, counsel, headings, block quotations, footnotes (convention); 0.46 em on the cap-height line is a 1.15 em pitch
#let margins = (top: 1.5in, bottom: 1in, x: 1in)   // L.C.C.R. 4 (A) (1): top 1 1/2 in left blank; the rest: convention
#let para-indent = 0.5in
#let sig-indent = 3.25in

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ohioctcl-motion-brief: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohioctcl-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced block for counsel, caption, signature and certificates.
#let single(body) = block(width: 100%, {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, justify: false)
  body
})

/// Lines of text, one per entry, in a single-spaced block (line breaks, no vertical space inside the paragraph).
#let line-block(xs) = single[#for x in xs [ #inl(x) \ ]]

// ---------------------------------------------------------------------------
// Caption: court, then the parties at left and the case number and title at right
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set par(first-line-indent: 0pt)
  align(center, strong(inl(need(meta, "court"))))
  v(1.2em)
  let parties = need(meta, "parties")
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.3in,
    {
      for (i, p) in parties.enumerate() {
        if i > 0 { v(0.8em) }
        single[
          #inl(p.name) \
          #if "role" in p and p.role != "" [ #h(1.5in) #emph(inl(p.role)) ]
        ]
      }
    },
    {
      single[Case No. #inl(need(meta, "case_number"))]
      v(0.8em)
      single[#strong(inl(need(meta, "title")))]
    },
  )
  v(1.2em)
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

/// Conformed signatures, "/s/Name" (EFILE Part VII (F) (a)), then the signature rule.
#let conformed-signers(sig) = {
  single[#for name in sig.at("signers", default: ()) [ /s/#inl(name) \ ]]
  block(above: 0.2em, below: 0.4em, line(length: 3.0in, stroke: 0.6pt))
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let counsel = meta.at("counsel", default: ())
  block(breakable: false, above: 1.2em, {
    par(first-line-indent: 0pt)[Respectfully submitted,]
    v(0.6em)
    pad(left: sig-indent, block(width: 100%, {
      line-block(sig.at("firm", default: ()))
      v(0.6em)
      conformed-signers(sig)
      for g in counsel {
        line-block(g.names)
        line-block(g.lines)
        v(0.6em)
      }
      line-block(sig.at("block", default: ()))
    }))
  })
}

#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  pagebreak(weak: true)
  heading(level: 1, outlined: true)[Certificate of Service]
  if "paragraphs" in svc {
    for p in svc.paragraphs { par(first-line-indent: (amount: para-indent, all: true), inl(p)) }
  } else {
    par(first-line-indent: (amount: para-indent, all: true))[
      On #inl(svc.date), we served this document by #inl(svc.method) on #inl(svc.served_on), at these addresses:
    ]
  }
  for r in svc.at("recipients", default: ()) {
    block(above: 0.6em, below: 0.6em, breakable: false, pad(left: 0.5in, single[#inl(r)]))
  }
  if "closing" in svc { par(first-line-indent: 0pt, inl(svc.closing)) }
  v(0.6em)
  let counsel = meta.at("counsel", default: ())
  pad(left: sig-indent, block(breakable: false, width: 100%, {
    conformed-signers(need(meta, "signature"))
    if counsel.len() > 0 { line-block(counsel.at(0).names) }
  }))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let ohioctcl-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // L.C.C.R. 4 (A) (1): the top 1 1/2 in is left blank; page numbers sit in the bottom margin.
  set page(paper: "us-letter", margin: margins, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), width: 100%, above: 0.8em, below: 1.2em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    it.body
  })
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt)
    text(size: type-size, weight: "bold", it.body)
  })
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    text(size: type-size, weight: "bold", it.body)
  })
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    text(size: type-size, weight: "bold", style: "italic", it.body)
  })

  caption(meta)
  if meta.at("cover_page", default: false) { pagebreak() }

  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature-block(meta)
  certificate-of-service(meta)
}
