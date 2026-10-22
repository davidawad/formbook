// Florida District Courts of Appeal (fladistctapp): petition for writ (prohibition, mandamus, certiorari, habeas).
// Rules: ../../rules.md (FLADISTCTAPP-* IDs cited beside each parameter). The petition is word-limited
// (FLADISTCTAPP-LEN-003), so a certificate of compliance follows the certificate of service (FLADISTCTAPP-CERT-001,
// -002); the caption names the court and all parties and omits the judge (FLADISTCTAPP-CONT-002).
//
// Content-agnostic. Every value comes from the INPUT frontmatter; no case text, no measured coordinates,
// no forced line breaks. The markdown body is rendered by cmarker. The exemplar
// (usage/FILED-EXAMPLE-petition-for-writ.pdf) opens with the caption on page 1 and the body follows on the same
// page; the template does the same, with no separate cover, table of contents or table of authorities.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Liberation Sans",)  // FLADISTCTAPP-FORM-003: Arial 14-point (Rule 9.045(b)). Arial is not vendored and typst warns on an unknown family (warnings fail), so the vendored metric twin Liberation Sans is declared alone (docs/FONTS.md, Arial row).
#let type-size = 14pt                            // FLADISTCTAPP-FORM-003: 14-point; footnotes and quotations are the same size (FLADISTCTAPP-FORM-005).
#let body-leading = 1.25em                       // FLADISTCTAPP-FORM-004: double-spaced. Liberation Sans single line is about 1.12 em, so this is about double.
#let single-leading = 0.2em                      // FLADISTCTAPP-FORM-005, -006: footnotes, quotations and headings may be single-spaced.
#let page-margin = 1in                           // FLADISTCTAPP-FORM-002: at least one inch on all four sides.
#let para-indent = 0.5in                         // Tier 2: first-line indent of body paragraphs, as in the exemplars.
#let caption-indent = 0.3in                      // Tier 2: party designations ("Appellant,") set in from the party names.
#let sig-indent = 0.5in                          // Tier 2: counsel and signature block at the paragraph indent, as in the exemplars.
#let cert-sig-indent = 3.5in                     // Tier 2: certificate signature set right of centre.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fladistctapp-petition: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("fladistctapp-petition: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Signer entry: "By:" then a signature line (or "/s/ name" when the INPUT carries a signature), the typed
/// name, then the lines beneath (Florida Bar number, address, telephone, e-mail as filed).
#let signer-entry(s) = {
  if "sig" in s {
    [By: /s/ #s.sig]
  } else {
    grid(
      columns: (0.5in, 2.8in),
      align: (left + bottom, left + bottom),
      [By:], line(length: 100%, stroke: 0.6pt),
    )
  }
  v(0.5em)
  [#s.at("typed", default: s.name)]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

/// Signature block: firm (if any), counsel lines, then each signer.
#let signature-block(sig, indent) = {
  block(width: 100%, breakable: false, pad(left: indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig [ #strong(sig.firm) #v(0.5em) ]
    #for l in sig.at("lines", default: ()) { inl(l) + linebreak() }
    #for s in sig.at("signers", default: ()) {
      v(0.9em)
      signer-entry(s)
    }
  ])
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let fladistctapp-petition(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // FLADISTCTAPP-FORM-002: 1 in margins. The extra 4 pt at the foot keeps footnote descents inside the margin.
  // FLADISTCTAPP-FORM-007: pages consecutively numbered; page 1 (the caption page) carries no number, as in the exemplar.
  set page(
    paper: "us-letter",
    margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt),
    numbering: (num, ..rest) => if num > 1 { str(num) },
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a centred capitalised heading (I. BASIS FOR JURISDICTION);
  // level 2 and 3 are sub-headings (bold, hanging).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented and single-spaced (FLADISTCTAPP-FORM-005: same size as the body).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt like the text (FLADISTCTAPP-FORM-005), single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }
  // Lists: single-spaced items at the paragraph indent, with a space between items.
  show list: it => block(above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.9em)
    #it
  ]

  // ---- Caption (FLADISTCTAPP-CONT-002: the court, and all parties with their designations; the judge is not named) ----
  {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    align(center)[
      #text(weight: "bold")[IN THE DISTRICT COURT OF APPEAL OF FLORIDA, #upper(need(meta, "district")) DISTRICT]
      #v(0.6em)
      #if "case_number" in meta and meta.case_number != "" [
        CASE NO. #meta.case_number \
      ] else [
        CASE NO. #box(width: 2.2in, line(length: 2.2in, stroke: 0.6pt)) \
      ]
      L.T. CASE NO. #need(meta, "lt_case_number")
    ]
    v(0.6em)
    for (i, side) in need(meta, "caption").enumerate() {
      if i > 0 { v(0.6em); pad(left: caption-indent)[v.]; v(0.6em) }
      block(width: 100%)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #block(width: 85%, inl(side.names))
        #v(0.2em)
        #pad(left: caption-indent)[#emph(side.designation)]
      ]
    }
    v(0.4em)
    pad(right: 20%, line(length: 100%, stroke: 0.6pt))
    v(0.6em)
    align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    v(0.6em)
  }

  // ---- Body ----
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Date, signature block (FLADISTCTAPP-CONT-002 petitioner's name and address as filed) ----
  if "signature" in meta or "date" in meta {
    block(width: 100%, breakable: false)[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #v(0.6em)
      #pad(left: sig-indent)[
        #if "date" in meta [ Dated: #inl(meta.date) \ ]
        #v(0.6em)
        Respectfully submitted,
      ]
      #if "signature" in meta { v(0.6em); signature-block(meta.signature, sig-indent) }
    ]
  }

  // ---- Certificate of service, then certificate of compliance (FLADISTCTAPP-CERT-001, -002) ----
  if "service" in meta {
    let c = meta.service
    v(1.2em)
    block(width: 100%, breakable: false, sticky: true)[
      #align(center, text(weight: "bold", upper[Certificate of Service]))
      #v(0.6em)
    ]
    par(first-line-indent: para-indent, inl(c.text))
    if "signer" in c {
      block(width: 100%, breakable: false)[
        #v(0.6em)
        #pad(left: cert-sig-indent)[
          #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
          #signer-entry(c.signer)
        ]
      ]
    }
  }
  if "compliance" in meta {
    let c = meta.compliance
    v(1.2em)
    block(width: 100%, breakable: false, sticky: true)[
      #align(center, text(weight: "bold", upper[Certificate of Compliance]))
      #v(0.6em)
    ]
    par(first-line-indent: para-indent, inl(c.text))
    if "signer" in c {
      block(width: 100%, breakable: false)[
        #v(0.6em)
        #pad(left: cert-sig-indent)[
          #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
          #signer-entry(c.signer)
        ]
      ]
    }
  }
}
