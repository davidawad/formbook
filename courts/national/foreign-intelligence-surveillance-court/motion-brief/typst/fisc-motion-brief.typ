// Foreign Intelligence Surveillance Court: motion (doc type motion-brief).
//
// Rule-driven and content-agnostic. Requirement IDs (FISC-...) refer to ../README.md, which
// cites the FISC Rules of Procedure (effective Nov. 1, 2010). No case-specific text, no
// coordinates measured off any filed document, no forced line breaks. The markdown body is
// rendered by cmarker; the metadata comes from the YAML frontmatter of the same sample file
// (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a stated convention)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"      // Vendored in /fonts. FISC-FORM-004: the rules name no font, so docs/FONTS.md gives Liberation Serif (Times metrics).
#let type-size = 12pt                      // FISC-FORM-004: the rules name no size. Convention: 12 pt.
#let page-margin = 1in                     // FISC-FORM-003: the rules name no margin. Convention: 1 in.
#let body-leading = 1.35em                 // FISC-FORM-002: "typed (double-spaced)". Gives a 24 pt baseline pitch at 12 pt (see README).
                                           // baseline pitch is about twice single spacing (see README).
#let single-leading = 0.65em              // Single spacing (typst default leading): block quotes, headings, captions, signature and address blocks.
#let para-indent = 0.5in                   // Convention for the body: first-line indent.
#let sig-indent = 3.25in                   // Signature and verification blocks start at the right half.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, smart quotes) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Read a required metadata field; a missing field stops the build.
#let need(meta, key) = {
  if key not in meta { panic("fisc-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fisc-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A stack of single-spaced lines (no forced line breaks: each line is its own block).
#let lines-block(lines) = stack(
  dir: ttb, spacing: single-leading,
  ..lines.map(l => block(width: 100%, inl(l))),
)

/// Numbered heading label: level 1 I., level 2 A., level 3 1. (FISC-FORM-006).
#let heading-label(h) = {
  let v = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  if h.level == 1 { numbering("I.", v) }
  else if h.level == 2 { numbering("A.", v) }
  else if h.level == 3 { numbering("1.", v) }
  else { panic("fisc-motion-brief: headings deeper than level 3 are not supported") }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let fisc-motion-brief(meta, md) = {
  // -- validation of rule-driven requirements -------------------------------
  let filer = need(meta, "filer")
  if filer not in ("government", "other") {
    panic("fisc-motion-brief: `filer` must be `government` or `other`")
  }
  let adversarial = meta.at("adversarial", default: false)
  if adversarial and "counsel" not in meta {
    panic("fisc-motion-brief: an adversarial submission must carry `counsel` (FISC-FILE-007)")
  }
  if adversarial and filer == "other" and "clearance" not in meta {
    panic("fisc-motion-brief: a non-government party in an adversarial proceeding must state its clearances (FISC-FILE-008)")
  }
  let docket = need(meta, "docket")
  let title = need(meta, "brief_title")
  let caption = need(meta, "caption")
  let signature = need(meta, "signature")

  // -- document and page ----------------------------------------------------
  set document(title: docket + ": " + title)
  set page(
    paper: "us-letter",                                  // FISC-FORM-001: 8½ × 11 inch.
    margin: page-margin,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(
    justify: false,
    leading: body-leading,
    spacing: body-leading,
    first-line-indent: para-indent,
  )
  set heading(numbering: "1.")                           // the counter; the label is drawn below.

  // -- headings: numbered, bold, left, single-spaced (FISC-FORM-006) -------
  show heading: it => context block(
    width: 100%, above: 1.2em, below: 0.9em, sticky: true,
  )[
    #set par(first-line-indent: 0pt, leading: single-leading)
    #set text(size: type-size)
    #strong[#heading-label(it) #h(0.5em) #it.body]
  ]

  // -- court heading: the government and private filers use different conventions
  // (both exemplars are filed; FISC-FORM-005)
  let court-lines = if filer == "government" {
    ("UNITED STATES", "FOREIGN INTELLIGENCE SURVEILLANCE COURT", "WASHINGTON, D.C.")
  } else {
    ("IN THE FOREIGN INTELLIGENCE SURVEILLANCE COURT",)
  }
  align(center)[
    #set par(first-line-indent: 0pt, leading: single-leading)
    #stack(dir: ttb, spacing: single-leading, ..court-lines.map(l => block(width: 100%, [#l])))
  ]
  v(1.5em)

  // -- caption box and docket number (FISC-FORM-007) ------------------------
  grid(
    columns: (3.4in, 1fr),
    block(
      width: 100%,
      inset: (top: 0.6em, bottom: 0.8em, right: 0.8em),
      stroke: (right: 0.7pt, bottom: 0.7pt),
    )[
      #set par(first-line-indent: 0pt, leading: single-leading)
      #lines-block(caption)
    ],
    block(inset: (left: 0.3in, top: 0.6em), align(horizon)[
      #set par(first-line-indent: 0pt, leading: single-leading)
      #inl(docket)
    ]),
  )

  // -- title (FISC-FORM-008) ------------------------------------------------
  v(1.5em)
  align(center)[
    #set par(first-line-indent: 0pt, leading: single-leading)
    #strong[#inl(upper(title))]
  ]
  v(0.6em)

  // -- body -----------------------------------------------------------------
  cmarker.render(md, raw-typst: false, smart-punctuation: true)

  // -- signature block and counsel information (FISC-FILE-007): kept together, so a
  // signature is never stranded from the counsel block it signs for
  v(1.2em)
  block(breakable: false)[
    #set par(first-line-indent: 0pt, leading: single-leading)
    #if "dated" in meta [Dated: #inl(meta.dated) #v(1em)]
    #pad(left: sig-indent)[
      Respectfully submitted,
      #v(2.4em)
      #lines-block(signature.at("lines"))
    ]
    #if "counsel" in meta {
      v(1.2em)
      for group in meta.counsel [
        #lines-block(group.at("names"))
        #v(0.2em)
        #lines-block(group.at("lines"))
        #v(0.9em)
      ]
    }
  ]

  // -- security clearances for a non-government party (FISC-FILE-008) -----
  if "clearance" in meta {
    block(breakable: false)[
      #set par(first-line-indent: 0pt, leading: single-leading)
      #strong[Security clearances (FISC Rule 7(i))] #h(0.5em) #inl(meta.clearance)
    ]
  }

  // -- verification, 28 U.S.C. § 1746 (only when the filing has one) -------
  if "verification" in meta {
    let ver = meta.verification
    pagebreak(weak: true)
    align(center)[#strong[VERIFICATION]]
    v(1em)
    let statement = ver.at("statement", default: "is true and correct.")
    [I declare under penalty of perjury that the foregoing #inl(title) #inl(statement)
      Executed pursuant to 28 U.S.C. § 1746 on #inl(ver.date).]
    v(2.4em)
    block(breakable: false)[
      #set par(first-line-indent: 0pt, leading: single-leading)
      #pad(left: sig-indent)[#lines-block(ver.at("signature"))]
    ]
  }

  // -- certificate of service (FISC-FILE-005, Rule 8(c): time and manner) --
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    align(center)[#strong[CERTIFICATE OF SERVICE]]
    v(1em)
    let when = need(svc, "date")
    let time-part = if "time" in svc { [, at #inl(svc.time)] } else { [] }
    [I hereby certify that on #inl(when)#time-part, I served copies of the foregoing motion on:]
    v(0.8em)
    block(breakable: false)[
      #set par(first-line-indent: 0pt, leading: single-leading)
      #for rec in need(svc, "recipients") [
        #pad(left: para-indent)[#lines-block(rec.at("lines"))]
        #v(0.9em)
      ]
    ]
    [pursuant to FISC Rule 8 and #inl(need(svc, "manner")).]
    v(2.4em)
    block(breakable: false)[
      #set par(first-line-indent: 0pt, leading: single-leading)
      #pad(left: sig-indent)[#lines-block(svc.at("signature"))]
    ]
  }
}
