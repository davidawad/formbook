// Georgia Court of Appeals: motion for reconsideration (petition-for-rehearing; Rule 37). Rule-driven and content-agnostic.
//
// Rules: Court of Appeals of Georgia Rules, effective March 26, 2026,
// https://www.gaappeals.gov/wp-content/uploads/2026/03/COA-Rules-Complete-Eff-26-March-26.pdf
// (read 2026-10-16 from the Wayback Machine copy; see ../README.md). Rule 37 (a): motions for reconsideration are
// prepared in accordance with Rule 24 (preparation of briefs) and limited to 4,200 words as
// certified just above the signature block. No case-specific text, no coordinates measured off an exemplar, no
// forced line breaks. The body is markdown rendered by cmarker; the cover, caption, signature
// and certificates come from the YAML frontmatter of the same sample file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule, a named substitute, or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // Rule 2 (c) (3) names Times New Roman as a compliant face; Liberation Serif is its metric-compatible substitute (docs/FONTS.md)
#let type-size = 14pt                   // Rule 2 (c) (3): serif, proportionally spaced, 14-point or larger, footnotes included
#let body-leading = 1.65em              // Rule 2 (c) (2): no less than double spacing (baseline pitch about 32.3 pt = 2 x the 1.15 em single line at 14 pt)
#let single-leading = 0.35em            // Rule 2 (c) (2) exclusions: caption, headings, block quotations, footnotes
#let margins = (top: 1in, bottom: 1in, x: 1in)  // Rule 24 (c): not less than one inch at top, sides and bottom
#let para-indent = 0.5in
#let sig-indent = 3.25in
#let toc-depth = 3
#let word-count-text = "This submission does not exceed the word count limit imposed by Rule 24."  // Rules 24 (f) (1), 37 (a): mandated wording

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("gactapp-petition-for-rehearing: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gactapp-petition-for-rehearing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced lines for counsel, caption, certificates.
#let single(body) = par(leading: single-leading, first-line-indent: 0pt, justify: false, body)
#let lines-of(xs) = single[#for l in xs [ #inl(l) \ ]]

// ---------------------------------------------------------------------------
// Cover: court title, case number, caption, title of the motion, counsel
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
// Table of authorities (optional; Rule 25 (a) (1) by analogy through Rule 41 (b) -> Rule 24)
// Each entry's `find` string is marked wherever it appears in the body; the table lists the pages.
// ---------------------------------------------------------------------------

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + [#metadata(key)<gactapp-toa>]
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<gactapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Certificates and signature block
// ---------------------------------------------------------------------------

/// Rule 2 (a) (2) (ii): "/s/" and the typed name, underlined; the typed name again below the underline.
#let signature-lines(sig, short: false) = {
  underline(inl(need(sig, "signer_line")))
  if "name" in sig { linebreak() + inl(sig.name) }
  let rest = sig.at("signer", default: ())
  for line in (if short { rest.slice(0, calc.min(1, rest.len())) } else { rest }) { linebreak() + inl(line) }
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.2em, {
    // Rule 24 (f) (1) / Rule 41 (b): the certification sits just above the signature block.
    par(first-line-indent: (amount: para-indent, all: true))[#word-count-text]
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

#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  let sig = need(meta, "signature")
  pagebreak(weak: true)
  heading(level: 1, outlined: true)[Certificate of Service]
  if "paragraphs" in svc {
    for p in svc.paragraphs { par(inl(p)) }
  } else {
    par[
      I certify that on #svc.date, I served a copy of this #svc.doc_type on #svc.served_on by
      #svc.method, addressed as follows:
    ]
  }
  let recips = if "recipients" in svc { svc.recipients } else { (svc.at("address", default: ()),) }
  for r in recips {
    block(above: 1em, below: 1em, breakable: false, pad(left: 1in, lines-of(r)))
  }
  if "closing" in svc { par(inl(svc.closing)) }
  v(0.6em)
  // The certificate is signed by the signer alone: /s/ line, name and first line (bar number).
  pad(left: sig-indent, block(breakable: false, single(signature-lines(sig, short: true))))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let gactapp-petition-for-rehearing(meta, body) = {
  set document(title: need(meta, "title"))
  // Rule 24 (e): every page numbered sequentially with an Arabic numeral at the bottom.
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
    mark-authorities(meta, it)
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

  // A separate cover page is the default (both filed exemplars use one); `cover_page: false`
  // starts the body under the caption instead.
  cover(meta, meta.at("cover_page", default: true))

  if meta.at("toc", default: false) {
    align(center, strong[TABLE OF CONTENTS])
    v(0.5em)
    {
      set par(leading: single-leading, first-line-indent: 0pt)
      show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      outline(title: none, depth: toc-depth, indent: 1.5em)
    }
    pagebreak()
  }
  if "authorities" in meta {
    authorities-table(meta)
    pagebreak()
  }

  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  signature-block(meta)
  certificate-of-service(meta)
}
