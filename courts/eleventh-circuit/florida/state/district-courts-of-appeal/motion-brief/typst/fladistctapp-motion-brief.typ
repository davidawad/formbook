// Florida District Courts of Appeal (fladistctapp): motion and supporting memorandum.
// Rules: ../../rules.md (FLADISTCTAPP-* IDs cited beside each parameter). Motions carry no word limit
// (FLADISTCTAPP-MOT-002), so there is no certificate of compliance; the certificate of service is required
// (FLADISTCTAPP-CERT-004).
//
// Content-agnostic. Every value comes from the INPUT frontmatter; no case text, no measured coordinates,
// no forced line breaks. The markdown body is rendered by cmarker. The exemplar (usage/FILED-EXAMPLE-motion-brief.pdf)
// opens with the caption on page 1 and the body follows on the same page; the template does the same.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Liberation Sans",)  // FLADISTCTAPP-FORM-003: Arial 14-point (Rule 9.045(b)). Arial is not vendored and typst warns on an unknown family (warnings fail), so the vendored metric twin Liberation Sans is declared alone (docs/FONTS.md, Arial row).
#let type-size = 14pt                            // FLADISTCTAPP-FORM-003: 14-point; footnotes and quotations are the same size (FLADISTCTAPP-FORM-005).
#let body-leading = 1.25em                       // FLADISTCTAPP-FORM-004: double-spaced. Liberation Sans single line is about 1.12 em, so this is about double.
#let single-leading = 0.46em                     // FLADISTCTAPP-FORM-005, -006: footnotes, quotations and headings may be single-spaced (0.46 em on the cap-height line: a 1.15 em pitch).
#let page-margin = 1in                           // FLADISTCTAPP-FORM-002: at least one inch on all four sides.
#let para-indent = 0.5in                         // Tier 2: first-line indent of body paragraphs, as in the exemplars.
#let caption-indent = 0.3in                      // Tier 2: party designations ("Appellants,") set in from the party names.
#let sig-indent = 0.5in                          // Tier 2: counsel block at the paragraph indent, as in the exemplars.
#let cert-sig-indent = 3.5in                     // Tier 2: certificate of service signature set right of centre.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fladistctapp-motion: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("fladistctapp-motion: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Signer entry (FLADISTCTAPP-CERT-001 style block; Florida Bar number and contact lines as filed):
/// "By: /s/ NAME", the typed name, then the lines beneath.
#let signer-entry(s, by: true) = {
  if by [By: /s/ #s.name] else [/s/ #s.name]
  linebreak()
  [#s.at("typed", default: s.name)]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

/// Signature block: firm, counsel lines, then each signer.
#let signature-block(sig, indent) = {
  block(width: 100%, breakable: false, pad(left: indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig [ #strong(sig.firm) #v(0.5em) ]
    #for l in sig.at("lines", default: ()) { inl(l) + linebreak() }
    #for (i, s) in sig.at("signers", default: ()).enumerate() {
      v(0.9em)
      signer-entry(s)
    }
  ])
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let fladistctapp-motion(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // FLADISTCTAPP-FORM-002: 1 in margins. The extra 4 pt at the foot keeps footnote descents inside the margin.
  set page(
    paper: "us-letter",
    margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt),
    numbering: (num, ..rest) => if num > 1 { str(num) },  // exemplar: page 1 carries no number; numbering from page 2 on
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a centred capitalised heading (ARGUMENT, CONCLUSION);
  // level 2 and 3 are argument headings (bold, hanging).
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
  // Footnotes: 14 pt like the text, single-spaced (FLADISTCTAPP-FORM-005).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Caption (FLADISTCTAPP-CONT-001 style: court, case number, lower tribunal; the judge is not named) ----
  // Starts page 1; the body follows the caption and title on the same page, as in the exemplars.
  {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    align(center)[
      #text(weight: "bold")[IN THE DISTRICT COURT OF APPEAL OF FLORIDA, #upper(need(meta, "district")) DISTRICT]
      #v(0.6em)
      CASE NO. #need(meta, "case_number") \
      L.T. CASE NO. #need(meta, "lt_case_number")
    ]
    v(0.6em)
    for (i, side) in need(meta, "caption").enumerate() {
      if i > 0 { v(0.6em); pad(left: caption-indent)[v.]; v(0.6em) }
      block(width: 100%)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #block(width: 85%, inl(side.names))
        #v(single-leading)
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

  // ---- Signature block (FLADISTCTAPP-CONT-001 items: name, address, e-mail of the filing attorney) ----
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

  // ---- Certificate of service (FLADISTCTAPP-CERT-004; wording is the filer's, content per Rule 9.420) ----
  if "certificate" in meta {
    let c = meta.certificate
    v(1.2em)
    block(width: 100%, breakable: false, sticky: true)[
      #align(center, text(weight: "bold", upper[Certificate of Service]))
      #v(0.6em)
    ]
    if "service" in c { par(first-line-indent: para-indent, inl(c.service)) }
    if "signer" in c {
      block(width: 100%, breakable: false)[
        #v(0.6em)
        #pad(left: cert-sig-indent)[
          #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
          #signer-entry(c.signer, by: false)
        ]
      ]
    }
  }
}
