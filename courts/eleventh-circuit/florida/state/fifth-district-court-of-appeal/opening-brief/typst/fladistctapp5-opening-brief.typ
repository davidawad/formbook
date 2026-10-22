// Florida Fifth District Court of Appeal (fladistctapp5): appellant's initial brief (opening-brief).
// Rule-driven and content-agnostic.
//
// Rules: Fla. R. App. P. 9.045 (form of documents; as amended eff. July 1, 2026) and 9.210 (2020 text: 8.5 x 11,
// margins no less than 1 inch); see ../../rules.md (FLADISTCTAPP5-FORM-001 to -010, BRIEF-001).
// No case-specific text, no coordinates measured off an exemplar, no forced line breaks. The body is
// markdown rendered by cmarker; the cover, caption, signature and certificates come from the YAML
// frontmatter of the same sample file.

#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/tables.typ": leader-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule, a named substitute, or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Bonum"    // Rule 9.045(b): Arial 14 or Bookman Old Style 14; Bookman is named here (docs/FONTS.md: TeX Gyre Bonum, visual clone)
#let type-size = 14pt                   // Rule 9.045(b): 14-point computer-generated text; footnotes and quotations the same size (9.045(b))
#let body-leading = 1.65em              // Rule 9.045(b): double-spaced (baseline pitch about 2 x the single line at 14 pt)
#let single-leading = 0.35em            // Rule 9.045(b) exclusions: headings, footnotes, quotations may be single-spaced
#let margins = (top: 1in + 4pt, bottom: 1in + 4pt, x: 1in)  // Rule 9.210(a)(2) (2020 text): margins no less than 1 inch; 4 pt more keeps a footnote marker or descender inside the margin
#let para-indent = 0.5in
#let sig-indent = 3in
#let toc-depth = 3

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("fladistctapp5-opening-brief: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fladistctapp5-opening-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced lines for counsel, caption, certificates.
#let single(body) = par(leading: single-leading, first-line-indent: 0pt, justify: false, body)
#let lines-of(xs) = single[#for l in xs [ #inl(l) \ ]]

// ---------------------------------------------------------------------------
// Cover: court title, case number, caption, title of the brief, counsel
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
  let court-lines = need(meta, "court")
  align(center, strong[#for l in (if type(court-lines) == array { court-lines } else { (court-lines,) }) [#upper(l) \ ]])
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
// Table of authorities (optional; the form of a Rule 9.045 document governs, no separate Florida table rule)
// Each entry's `find` string is marked wherever it appears in the body; the table lists the pages.
// ---------------------------------------------------------------------------

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + [#metadata(key)<fladistctapp5-toa>]
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<fladistctapp5-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  // Many pages are set as "passim" (the convention of the filed tables); a long list would not fit the column.
  if pages.len() == 0 { [--] } else if pages.len() > 6 { [passim] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false,
        // The page reference keeps level with the entry's last line, after the leaders (DEF-TOC-001).
        leader-row(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") },
          hang: 1.5em, dot-gap: 2pt, lead-gap: 0.25em, gutter: 4pt))
    }
  }
}

// ---------------------------------------------------------------------------
// Certificates and signature block
// ---------------------------------------------------------------------------

/// Signature: "/s/" and the typed name, the typed name again below the underline (Rule 9.045 sets no signature form).
#let signature-lines(sig, short: false) = {
  let rest = sig.at("signer", default: ())
  if "signer_line" in sig {
    underline(inl(sig.signer_line))
    if "name" in sig { linebreak() + inl(sig.name) }
  } else if "name" in sig {
    inl(sig.name)
  }
  for line in (if short { rest.slice(0, calc.min(1, rest.len())) } else { rest }) { linebreak() + inl(line) }
}

// The signature block: the lead counsel's block, then any `also` counsel (a second firm, set off by "-and-").
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let blocks = (sig,) + sig.at("also", default: ())
  block(breakable: false, above: 1.2em, {
    v(0.6em)
    if "date" in sig {
      par(first-line-indent: (amount: para-indent, all: true))[Respectfully submitted this #inl(sig.date).]
    } else {
      par(first-line-indent: 0pt)[Respectfully submitted,]
    }
    v(0.6em)
    for (i, s) in blocks.enumerate() {
      if i > 0 {
        v(0.6em)
        pad(left: sig-indent, single[-and-])
        v(0.6em)
      }
      pad(left: sig-indent, block(single[
        #for line in s.at("lines", default: ()) [ #inl(line) \ ]
        #if s.at("lines", default: ()).len() > 0 [ \ ]
        #signature-lines(s)
      ]))
    }
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

// Rule 9.045(e) certificate of compliance (FLADISTCTAPP5-FORM-008): only when the sample carries one.
// It sits immediately after the certificate of service, so it follows without a page break.
#let certificate-of-compliance(meta) = {
  let sig = need(meta, "signature")
  heading(level: 1, outlined: true)[Certificate of Compliance]
  par(inl(need(meta.compliance, "text")))
  v(0.6em)
  pad(left: sig-indent, block(breakable: false, single(signature-lines(sig, short: true))))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let fladistctapp5-opening-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // Pages numbered in Arabic numerals at the bottom (Rule 9.045 sets no numbering rule; convention per exemplars).
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
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 1.1em, sticky: true, {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    text(weight: "bold", it.body)
  })
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 1.1em, sticky: true, {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    text(weight: "bold", it.body)
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
  if "compliance" in meta { certificate-of-compliance(meta) }
}
