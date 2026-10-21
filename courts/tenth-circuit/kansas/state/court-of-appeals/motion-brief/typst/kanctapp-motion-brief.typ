// Court of Appeals of Kansas (kanctapp): motion (motion-brief). Content-agnostic; every number is a named parameter below.
// No case-specific text, no coordinates measured off an exemplar, no forced line breaks. Kansas rule text was not
// retrieved (rules.md); numbers follow the filed exemplar and the default eval. The body is markdown rendered by cmarker;
// the cover, caption, signature and certificates come from the YAML frontmatter of the INPUT.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule, a named substitute, or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // Times New Roman is the standard face (docs/FONTS.md); Liberation Serif is its metric-compatible substitute.
#let type-size = 13pt                  // Body text in the Kansas exemplars is Times at about 13 pt (see rules.md).
#let body-leading = 1.65em              // Double-spaced text (Kansas exemplars).
#let single-leading = 0.45em            // Single-spaced: caption, headings, block quotations, footnotes.
#let margins = (top: 1in, bottom: 1in, x: 1in)  // One inch on every side (Kansas exemplars; see rules.md).
#let para-indent = 0.5in
#let sig-indent = 3.25in
#let toc-depth = 3

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("kanctapp-motion-brief: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kanctapp-motion-brief: the sample must start with a YAML frontmatter block") }
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
  align(center, strong[No. #need(meta, "case_number")])
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
// Table of authorities (optional).
// Each entry's `find` string is marked wherever it appears in the body; the table lists the pages.
// ---------------------------------------------------------------------------

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + [#metadata(key)<kanctapp-toa>]
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<kanctapp-toa>)
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
        #grid(columns: (1fr, auto), column-gutter: 4pt,
          [#inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)])],
          [#if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }])
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Certificates and signature block
// ---------------------------------------------------------------------------

/// "/s/" and the typed name, underlined; the typed name again below the underline.
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

#let kanctapp-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // Every page numbered with an Arabic numeral at the bottom (exemplar).
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
