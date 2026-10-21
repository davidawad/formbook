// California Courts of Appeal: motion with memorandum (motion-brief). Rule-driven and content-agnostic.
//
// Rules (rules.md, verified 2026-10-21 against courts.ca.gov): rule 8.74(a)-(b) (electronic documents: font,
// size, spacing, margins, alignment, pagination, cover), rule 8.74(c)(2) (motions supported by matter outside
// the record), rule 8.54(a) (written motion with memorandum), rule 8.25(a)(2) (proof of service). No page or
// word limit is set for a motion (rule 8.54 sets none). No case-specific text, no coordinates measured off an
// exemplar, no forced line breaks. The body is markdown rendered by cmarker; the cover, caption, signature and
// proof of service come from the YAML frontmatter of the same sample file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule, a named substitute, or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"   // CALCTAPP-FORM-002: Century Schoolbook is preferred by rule 8.74(b)(1); Schola is its substitute (docs/FONTS.md)
#let type-size = 13pt                   // CALCTAPP-FORM-003: 13-point or larger, footnotes included (rule 8.74(b)(1))
#let body-leading = 0.49em              // CALCTAPP-FORM-004: lines 1.5 spaced (rule 8.74(b)(2)); about 23.4 pt pitch at 13 pt, as in answering-brief
#let single-leading = 0.42em            // headings, caption, quotations, footnotes: single spaced (rule 8.74(b)(2))
#let margin-side = 1.5in                // CALCTAPP-FORM-005: 1-1/2 inches left and right (rule 8.74(b)(3))
#let margin-tb = 1in                    // CALCTAPP-FORM-005: 1 inch top and bottom (rule 8.74(b)(3))
#let para-indent = 0.5in
#let sig-indent = 3.25in

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("calctapp-motion-brief: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("calctapp-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced lines for counsel, caption, certificates.
#let single(body) = par(leading: single-leading, first-line-indent: 0pt, justify: false, body)
#let lines-of(xs) = single[#for l in xs [ #inl(l) \ ]]

// ---------------------------------------------------------------------------
// Cover: court title, district, case number, caption, title of the motion, counsel
// ---------------------------------------------------------------------------

#let caption-block(meta) = {
  for p in need(meta, "parties") {
    align(center, single[
      #inl(p.name)
      #if p.role != "" [ \ #h(1.5in) #emph(inl(p.role)) ]
    ])
    v(0.5em)
  }
}

#let cover(meta, own-page) = {
  set par(first-line-indent: 0pt)
  align(center, strong[#upper(need(meta, "court"))])
  if "district" in meta {
    align(center, strong[#upper(inl(meta.district))])
  }
  v(0.8em)
  align(center, strong[Case No. #need(meta, "case_number")])
  v(1.2em)
  caption-block(meta)
  if "lower_court_case" in meta {
    v(0.6em)
    align(center, single(inl(meta.lower_court_case)))
  }
  if own-page { v(1fr) } else { v(1.2em) }
  align(center, block(width: 85%, single(strong(upper(inl(need(meta, "title")))))))
  if own-page {
    v(1fr)
    if "counsel" in meta {
      pad(left: sig-indent - 0.75in, {
        for g in meta.counsel {
          block(above: 0.8em, breakable: false, single[
            #for n in g.names [ #strong(inl(n)) \ ]
            #for l in g.lines [ #inl(l) \ ]
          ])
        }
      })
    }
    pagebreak()
  } else {
    v(1.2em)
  }
}

// ---------------------------------------------------------------------------
// Signature block and proof of service
// ---------------------------------------------------------------------------

/// The "/s/" line and the typed name, underlined; the typed name again below the underline.
#let signature-lines(sig, short: false) = {
  underline(inl(need(sig, "signer_line")))
  if "name" in sig { linebreak() + inl(sig.name) }
  let rest = sig.at("signer", default: ())
  for line in (if short { rest.slice(0, calc.min(1, rest.len())) } else { rest }) { linebreak() + inl(line) }
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.2em, {
    if "date" in sig {
      par(first-line-indent: (amount: para-indent, all: true))[Respectfully submitted this #inl(sig.date).]
    }
    v(0.6em)
    pad(left: sig-indent, block(single[
      #for line in sig.at("lines", default: ()) [ #inl(line) \ ]
      #if sig.at("lines", default: ()).len() > 0 [ \ ]
      #signature-lines(sig)
    ]))
  })
}

/// Rule 8.25(a)(2): a proof of service is attached to the document. The heading and paragraphs come from the frontmatter.
#let proof-of-service(meta) = {
  let svc = need(meta, "service")
  let sig = svc.at("declarant", default: need(meta, "signature"))
  pagebreak(weak: true)
  heading(level: 1, outlined: true)[#svc.at("heading", default: "Proof of Service")]
  for p in svc.paragraphs { par(inl(p)) }
  for r in svc.at("recipients", default: ()) {
    block(above: 1em, below: 1em, breakable: false, pad(left: 1in, lines-of(r)))
  }
  if "closing" in svc { par(inl(svc.closing)) }
  v(0.6em)
  pad(left: sig-indent, block(breakable: false, single(signature-lines(sig, short: true))))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let calctapp-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // Rule 8.74(a)(2): every page numbered consecutively in Arabic numerals, the cover being page 1.
  set page(paper: "us-letter", margin: (top: margin-tb, bottom: margin-tb, x: margin-side), numbering: "1", number-align: center + bottom)
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
  show heading.where(level: 1): it => block(width: 100%, above: 1.4em, below: 1em, sticky: true, {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, text(weight: "bold", upper(it.body)))
  })
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true, {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    text(weight: "bold", it.body)
  })
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true, {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    text(weight: "bold", style: "italic", it.body)
  })

  // Rule 8.74(c)(2) and the filed exemplar: a cover page is the default.
  cover(meta, meta.at("cover_page", default: true))

  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature-block(meta)
  proof-of-service(meta)
}
