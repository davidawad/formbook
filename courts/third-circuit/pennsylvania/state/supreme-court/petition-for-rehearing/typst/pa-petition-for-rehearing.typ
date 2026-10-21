// Supreme Court of Pennsylvania: application for reargument (petition-for-rehearing). Rule-driven and content-agnostic.
// Rules: Pa.R.A.P. 124 (form), 127 (public access certification), 2543 and 2544 (reargument; 3,000 words, certificate).
// Source and dates: ../../rules.md (PA-FORM-*, PA-LEN-004, PA-CERT-007, PA-CONT-019). The body is markdown rendered by
// cmarker; the cover, caption, signature and certificates come from the YAML frontmatter of the sample file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule or a named choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif") // Pa.R.A.P. 124 Official Note: Times New Roman is satisfactory; Liberation Serif is its metric substitute (docs/FONTS.md)
#let type-size = 14pt                // Pa.R.A.P. 124(a)(4): lettering no smaller than 14 point in the text
#let note-size = 14pt                // Pa.R.A.P. 124(a)(4): footnotes 12 point minimum; 14 pt used for uniform type
#let margin = 1in                    // Pa.R.A.P. 124(a)(2): at least one inch on all four sides
#let top-first-page = 3in            // Pa.R.A.P. 124(a)(3): three-inch space at the top of the first page
#let body-leading = 1.645em          // Pa.R.A.P. 124(a)(3): double spaced (about 32 pt pitch at 14 pt)
#let single-leading = 0.5em          // quotations, headings, caption, signature lines, footnotes (124(a)(3) exclusions)
#let para-indent = 0.5in
#let sig-indent = 3.25in
#let word-limit = 3000               // Pa.R.A.P. 2544(c): application for reargument, except by permission of the court
#let word-cert-pages = 8             // Pa.R.A.P. 2544(d)(1): 8 pages or fewer on a word processor are deemed to comply
#let public-access-text = "I certify that this filing complies with the provisions of the Case Records Public Access Policy of the Unified Judicial System of Pennsylvania that require filing confidential information and documents differently than non-confidential information and documents."

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("pa-petition-for-rehearing: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pa-petition-for-rehearing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced block for counsel, caption and certificates.
#let single(body) = par(leading: single-leading, first-line-indent: 0pt, justify: false, body)
#let lines-of(xs) = single[#for l in xs [ #inl(l) \ ]]

// ---------------------------------------------------------------------------
// Cover: court title, docket, caption, title of the application, counsel
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

#let cover(meta) = {
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
  v(1fr)
  align(center, block(width: 85%, single(strong(upper(inl(need(meta, "title")))))))
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
}

// ---------------------------------------------------------------------------
// Table of authorities (optional). Each entry's `find` string is marked wherever it appears in the body.
// ---------------------------------------------------------------------------

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + [#metadata(key)<pa-toa>]
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<pa-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: false)[Table of Citations]
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
// Signature block, certificates
// ---------------------------------------------------------------------------

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
      par(first-line-indent: 0pt)[Date: #inl(sig.date)]
    }
    v(0.6em)
    par(first-line-indent: 0pt)[Respectfully submitted,]
    v(0.4em)
    pad(left: sig-indent, block(single[
      #for line in sig.at("lines", default: ()) [ #inl(line) \ ]
      #if sig.at("lines", default: ()).len() > 0 [ \ ]
      #signature-lines(sig)
    ]))
  })
}

// Pa.R.A.P. 2544(d): the word count certificate is required for an application of more than 8 pages;
// Pa.R.A.P. 127(a) and its Comment: the Public Access Policy certification is required on every filing.
#let compliance-certificate(meta, words) = {
  pagebreak(weak: true)
  heading(level: 1, outlined: true)[Certificate of Compliance]
  par(first-line-indent: para-indent)[
    I hereby certify that this application complies with the word-count limit of Pa.R.A.P. 2544(c) and that, excluding the cover, tables, proof of service and signature block, it contains #str(words) words.
  ]
  par(first-line-indent: para-indent)[#public-access-text]
  v(0.6em)
  pad(left: sig-indent, block(breakable: false, single(signature-lines(meta.signature, short: true))))
}

#let certificate-of-service(meta) = {
  let svc = meta.service
  pagebreak(weak: true)
  heading(level: 1, outlined: true)[Certificate of Service]
  par(first-line-indent: para-indent)[
    I certify that on #svc.date I served a true and correct copy of this application for reargument on the following counsel of record by #svc.method:
  ]
  for r in svc.recipients {
    block(above: 1em, below: 1em, breakable: false, pad(left: 1in, lines-of(r.names + r.lines)))
  }
  v(0.6em)
  pad(left: sig-indent, block(breakable: false, single(signature-lines(meta.signature, short: true))))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let pa-petition-for-rehearing(meta, body) = {
  let words = body.split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
  assert(words <= word-limit, message: "Pa.R.A.P. 2544(c): " + str(words) + " words; the limit is " + str(word-limit))
  set document(title: need(meta, "title"))
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)

  // First page: the cover, with the three-inch space at the top (Pa.R.A.P. 124(a)(3)); no folio.
  page(paper: "us-letter", margin: (top: top-first-page, rest: margin), numbering: none)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #cover(meta)
  ]

  // Body: one-inch margins, Arabic folio at the bottom centre (Pa.R.A.P. 124(a)(3)), restarting at 1.
  set page(paper: "us-letter", margin: margin, numbering: "1", number-align: center + bottom, footer-descent: 0.4in)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), width: 100%, above: 0.8em, below: 1.2em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    it.body
  })
  show footnote.entry: it => {
    set text(size: note-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }
  show heading.where(level: 1): it => block(width: 100%, above: 1.4em, below: 1em, sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, text(weight: "bold", upper(it.body)))
  })
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    text(weight: "bold", it.body)
  })
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    text(weight: "bold", style: "italic", it.body)
  })

  counter(page).update(1)
  if "authorities" in meta {
    authorities-table(meta)
    pagebreak()
  }

  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1))

  signature-block(meta)
  compliance-certificate(meta, words)
  if "service" in meta { certificate-of-service(meta) }
}
