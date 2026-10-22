// Florida Fourth District Court of Appeal (fladistctapp4): petition for review (petition-for-review).
//
// Rule-driven and content-agnostic. Requirement IDs (FLADISTCTAPP4-...) refer to ../../rules.md.
// Governing form: Fla. R. App. P. 9.045 (form of documents, as amended eff. July 1, 2026): double-spaced
// black type; footnotes and quotations may be single-spaced but are in the same 14-point size as the body;
// headings at least as large as the text; computer-generated documents in Arial 14 or Bookman Old Style 14.
// Page size and margins: Rule 9.210(a)(1)-(2) (2020 text): 8.5 x 11 inches, margins of at least 1 inch.
// No case-specific text, no coordinates measured off an exemplar, no forced line breaks. The body is
// markdown rendered by cmarker; the caption, signature and certificates come from the YAML frontmatter
// of the same sample file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule, a named substitute, or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Sans"    // Rule 9.045(b): Arial 14 (metric clone of Arial; docs/FONTS.md)
#let type-size = 14pt                    // Rule 9.045(b): 14-point; footnotes and quotations are the same size
#let body-leading = 1.62em               // Rule 9.045(b): double-spaced (measured: Typst line box for Liberation Sans 14 pt is 9.6 pt; 1.62 em of leading gives the 32.3 pt pitch of Arial 14 double spacing)
#let single-leading = 0.47em            // Rule 9.045(b) exclusions: quotations, footnotes, headings, caption and certificates may be single-spaced (16.1 pt pitch, single Arial 14)
#let margins = (top: 1in + 3pt, bottom: 1in + 3pt, x: 1in)  // Rule 9.210(a)(2) (2020 text): margins no less than 1 inch; 3 pt more keeps the cap height of the first line and the last descender inside the 1 in margin
#let para-indent = 0.5in                 // style parameter, not rule-mandated (conventional first-line indent)
#let sig-indent = 2.5in                  // style parameter, not rule-mandated: signature block set right of the text block (no coordinate of the exemplar is used)
#let caption-right = 4.0in               // style parameter, not rule-mandated: the case-number column of the caption
#let quote-indent = 0.5in                // style parameter, not rule-mandated: block quotations indented on both sides

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("fladistctapp4-petition-for-review: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fladistctapp4-petition-for-review: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced block of lines (signature blocks, caption entries, counsel).
#let single(body) = block(width: 100%, {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, justify: false)
  body
})

// ---------------------------------------------------------------------------
// Cover block (page 1, unnumbered): court heading, caption, case numbers, title.
// The petition's opening paragraph follows the title on the same page.
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let parties = need(meta, "parties")
  grid(
    columns: (caption-right, 1fr),
    column-gutter: 0pt,
    single[
      #for p in parties {
        block(width: 100%, above: 0.9em, inl(p.name))
        if p.role != "" {
          pad(left: 0.5in, block(inl(p.role)))
        }
      }
      #v(0.9em)
      #need(meta, "caption_end")
    ],
    align(horizon, single[
      CASE NO:#need(meta, "case_number") \
      #need(meta, "lower_court_case")
    ]),
  )
}

#let cover(meta) = {
  set par(first-line-indent: 0pt)
  single(align(center, strong[#for l in need(meta, "court") [#upper(l) \ ]]))
  v(1.4em)
  caption(meta)
  v(1.4em)
  single(align(center, block(width: 92%, underline(strong(upper(inl(need(meta, "title"))))))))
  v(1.2em)
}

// ---------------------------------------------------------------------------
// Signature block (after the body) and the certificates that follow it.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.2em, pad(left: sig-indent, single[
    #inl(sig.at("closing", default: "Respectfully submitted,")) \
    #v(1.0em)
    #underline(inl(sig.signer_line)) \
    #for line in sig.at("lines", default: ()) [ #inl(line) \ ]
  ]))
}

#let certificate(heading, statement, signer-line, signer-role) = {
  block(width: 100%, breakable: false, above: 1.4em, below: 0.9em, align(center, strong(underline(upper(heading)))))
  par(first-line-indent: para-indent, inl(statement))
  block(breakable: false, above: 0.8em, pad(left: sig-indent, single[
    #underline(inl(signer-line)) \
    #inl(signer-role)
  ]))
}

#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  certificate(svc.at("heading", default: "CERTIFICATE OF SERVICE"), svc.statement, svc.signer_line, svc.at("signer_role", default: "Attorney"))
}

#let certificate-of-compliance(meta) = {
  if "compliance" in meta {
    let c = meta.compliance
    certificate(c.at("heading", default: "CERTIFICATE OF COMPLIANCE"), c.statement, c.signer_line, c.at("signer_role", default: "Attorney"))
  }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let fladistctapp4-petition-for-review(meta, body) = {
  set document(title: need(meta, "title"), author: "")
  // Page 1 (the caption page) is not numbered; every later page carries an Arabic numeral, centered at the bottom.
  set page(
    paper: "us-letter",
    margin: margins,
    footer: context {
      let n = counter(page).get().first()
      if n > 1 { align(center, counter(page).display()) }
    },
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true))

  // Headings: level 1 bold capitals at the margin; level 2 bold with a hanging indent; level 3 bold.
  // Headings are set at the text size (FLADISTCTAPP4-FORM-006) and may be single-spaced.
  show heading: set text(size: type-size)
  show heading: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1.0em, sticky: true, text(weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => block(width: 100%, above: 1.0em, below: 1.0em, sticky: true, {
    set par(hanging-indent: 0.5in)
    text(weight: "bold", it.body)
  })
  show heading.where(level: 3): it => block(width: 100%, above: 1.0em, below: 1.0em, sticky: true, {
    set par(hanging-indent: 0.5in)
    text(weight: "bold", it.body)
  })

  // Block quotations are single-spaced and indented on both sides, at the text size.
  show quote.where(block: true): it => block(width: 100%, above: 0.6em, below: 1.2em, inset: (left: quote-indent, right: quote-indent), {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    it.body
  })

  // Footnotes: the same 14-point size as the body, single-spaced.
  show footnote: set text(font: font-family)
  set list(marker: ([•], [–]))
  show footnote.entry: set text(font: font-family, size: type-size)
  show footnote.entry: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)

  // No hyperlinks in the e-filed text (no Florida rule is cited for this; not verified).
  // A link keeps its text and loses its target.
  show link: it => it.body

  cover(meta)

  // The body: paragraphs double-spaced with a first-line indent; the petition's own headings follow.
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature-block(meta)
  certificate-of-service(meta)
  certificate-of-compliance(meta)
}
