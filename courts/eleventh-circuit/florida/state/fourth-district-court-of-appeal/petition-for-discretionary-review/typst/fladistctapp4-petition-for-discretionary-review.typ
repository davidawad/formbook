// Florida Fourth District Court of Appeal (fladistctapp4): petition for writ of certiorari to the
// court's discretionary review (petition-for-discretionary-review). Fla. R. App. P. 9.030(b)(2), 9.100.
//
// Form: Fla. R. App. P. 9.045 (as amended eff. July 1, 2026: 14-point double-spaced type, footnotes and
// quotations single-spaced in the same size, headings at least as large as the text, Arial or Bookman
// Old Style 14 for computer-generated documents; certificate of compliance after the certificate of
// service, 9.045(e)) and 9.210 (2020 text: 8.5 x 11, margins no less than 1 inch). See ../../rules.md
// (FLADISTCTAPP4-FORM-001 to -010, PET-001). Rules 9.030 and 9.100 content requirements were not
// retrieved and are not applied here.
//
// Content-agnostic: no case text, no coordinates measured off an exemplar, no forced line breaks. The
// body is markdown rendered by cmarker; the caption, signature and certificates come from the YAML
// frontmatter of the same sample file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule, a named substitute, or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Sans"     // Rule 9.045(b): Arial 14 (Bookman Old Style 14 is the alternative). Liberation Sans is the metric clone of Arial (docs/FONTS.md).
#let cert-face = "Arial"                  // Name the filer's certificate gives the face. The file is set in Liberation Sans, Arial's metric clone; the filer's word processor must use Arial.
#let type-size = 14pt                     // Rule 9.045(b): 14-point; footnotes and quotations are the same size.
#let body-leading = 1.62em                // Rule 9.045(b): double-spaced. Liberation Sans sets a natural line of about 0.67 em in typst 0.15, so 1.62 em of leading gives the 32 pt pitch of 14-point double spacing (measured against the exemplar: 48 units of 1.5 scale).
#let single-leading = 0.48em                // Rule 9.045(b): headings, footnotes, quotations may be single-spaced; 0.48 em gives a 16 pt pitch (exemplar: 24 units).
#let margins = (top: 1in + 4pt, bottom: 1in + 4pt, x: 1in)  // Rule 9.210(a)(2) (2020 text): margins no less than 1 inch; 4 pt more keeps a footnote marker or descender inside the margin.
#let para-indent = 0.5in
#let sig-indent = 3in
#let label-indent = 0.75in                // Party role lines in the caption sit under the party name.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("fladistctapp4-petition-for-discretionary-review: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fladistctapp4-petition-for-discretionary-review: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced block of lines (signature, counsel, service addresses).
#let single(body) = par(leading: single-leading, first-line-indent: 0pt, justify: false, body)

/// Heading numbers for argument points: level 2 "I.", level 3 "A.". Level-1 sections are unnumbered.
#let heading-number(..nums) = {
  let v = nums.pos()
  let k = v.len()
  if k == 2 { numbering("I.", v.at(1)) }
  else if k == 3 { numbering("A.", v.at(2)) }
  else { "" }
}

// ---------------------------------------------------------------------------
// Caption and title (Florida form: court heading, parties on the left, proceeding and numbers on the right)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let court-lines = need(meta, "court")
  align(center, strong[#for l in (if type(court-lines) == array { court-lines } else { (court-lines,) }) [#upper(l) \ ]])
  v(1.2em)
  grid(
    columns: (3.0in, 1fr),
    column-gutter: 0.2in,
    {
      set par(leading: single-leading, first-line-indent: 0pt)
      for p in need(meta, "parties") {
        block(above: 0pt, below: 0.9em, breakable: false, {
          inl(p.name)
          if p.role != "" { linebreak(); h(label-indent); inl(p.role) }
        })
      }
      if "caption_close" in meta { align(right, meta.caption_close) }
    },
    {
      set par(leading: single-leading, first-line-indent: 0pt)
      if "proceeding" in meta { [#meta.proceeding] + [ \ ] }
      v(1.3em)
      [CASE NO.: #need(meta, "case_number")]
      if "lower_court_case" in meta { [ \ ] + [#meta.lower_court_case] }
    },
  )
  v(1.2em)
  align(center, block(width: 85%, single(strong(upper(inl(need(meta, "title")))))))
  v(1.2em)
}

// ---------------------------------------------------------------------------
// Certificates and signature block
// ---------------------------------------------------------------------------

/// Signature: the "/s/" line and the typed name below it (Rule 9.045 sets no signature form).
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: 1.2em, {
    pad(left: sig-indent, single[Respectfully submitted,])
    v(0.8em)
    pad(left: sig-indent, block(single[
      #inl(need(sig, "signer_line")) \
      #inl(need(sig, "name")) \
      #for line in sig.at("signer", default: ()) [ #inl(line) \ ]
    ]))
  })
}

#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  pagebreak(weak: true)
  heading(level: 1, numbering: none)[Certificate of Service]
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
    block(above: 1em, below: 1em, breakable: false, single[#for l in r [ #inl(l) \ ]])
  }
  if "closing" in svc { par(inl(svc.closing)) }
}

/// Certificate of compliance (Rule 9.045(e)): immediately after the certificate of service. Printed only
/// when the frontmatter gives the word count; the count is the filer's.
#let certificate-of-compliance(meta) = {
  if "word_count" not in meta { return }
  let sig = need(meta, "signature")
  pagebreak(weak: true)
  heading(level: 1, numbering: none)[Certificate of Compliance]
  par[I HEREBY CERTIFY that this computer-generated document complies with the applicable font requirements of Rule 9.045(b) by production in #cert-face font, size 14-point, and that it complies with the applicable word count limit and contains #meta.word_count words.]
  v(0.8em)
  pad(left: sig-indent, block(breakable: false, single[
    #inl(need(sig, "signer_line")) \
    #inl(need(sig, "name"))
  ]))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let fladistctapp4-petition(meta, body) = {
  set document(title: need(meta, "title"))
  // Pages numbered in Arabic numerals at the bottom (Rule 9.045 sets no numbering rule).
  set page(paper: "us-letter", margin: margins, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: heading-number)

  // Level 1: a section, centred, bold, capitals. Levels 2 and 3: argument points, numbered automatically.
  show heading.where(level: 1): it => block(width: 100%, above: 1.4em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]

  // Block quotations: indented on both sides, single-spaced, same size (Rule 9.045(b)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #it.body
  ]
  // Footnotes: at the text size and single-spaced (Rule 9.045(b)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  caption(meta)

  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  certificate-of-service(meta)
  signature-block(meta)
  certificate-of-compliance(meta)
}
