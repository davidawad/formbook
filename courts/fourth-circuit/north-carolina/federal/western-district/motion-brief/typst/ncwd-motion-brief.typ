// Memorandum of law supporting a motion for the U.S. District Court for the Western District of North Carolina (ncwd).
// Rules: LCvR 7.1(c) (a brief is filed with the motion), 7.1(d) (25-page limit, 12 pt minimum, double-spaced,
// one-inch margins, numbered pages; a judge's standing order overrides these); Fed. R. Civ. P. 7(b), 11(a) (signer's
// address, e-mail and telephone); the June 18, 2024 Standing Order on artificial intelligence (3:24-mc-104), whose
// certification the template prints when the sample asks for it. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"        // LCvR 7.1(d): font size is the rule; Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (README)
#let type-size = 12pt                   // LCvR 7.1(d): a minimum of 12 point
#let margin = 1in                       // LCvR 7.1(d): one-inch margins
#let text-width = 8.5in - 2 * margin
#let pitch = 24pt                       // block spacing unit: one double-spaced line
#let body-leading = 1.645em             // double spacing: twice the single line (13.8 pt), a 27.6 pt pitch at 12 pt, as the filed exemplar sets it (measured, README)
#let single-leading = 0.5em             // single spacing for caption, counsel, signature: about 13.8 pt at 12 pt
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 2.9in               // party column of the caption
#let caption-mark = 0.3in               // ")" column between the parties and the title

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncwd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, quotations, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item; each item is its own block so the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// A section heading typed by the template itself (the AI certification and the certificate of service).
#let section-heading(s) = block(width: 100%, above: pitch, below: body-leading, sticky: true,
  align(center, text(weight: "bold", upper(s))))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page numbers, centered in the bottom margin (LCvR 7.1(d): each page is numbered).
#let page-number() = align(center, text(size: type-size, context counter(page).display()))

// ---------------------------------------------------------------------------
// First page: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = block(width: 100%, below: body-leading, {
  // Fed. R. Civ. P. 10(a): the court's name; the division line when the filing uses one.
  set par(leading: single-leading, spacing: 0pt)
  align(center)[
    #text(weight: "bold")[UNITED STATES DISTRICT COURT] \
    #text(weight: "bold")[FOR THE WESTERN DISTRICT OF NORTH CAROLINA]
    #if "division" in meta and meta.division != none [\ #text(weight: "bold", upper(meta.division))]
  ]
})

#let caption(meta) = block(width: 100%, breakable: false, grid(
  columns: (caption-left, caption-mark, 1fr),
  column-gutter: 0.1in,
  {
    // Each party: its lines, then its designation; "v." between the parties. Every row is one line.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.lines + (p.designation,)
    }
    line-stack(rows)
  },
  // A ")" for each row of the party column, as in the filed caption.
  {
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.lines + (p.designation,)
    }
    line-stack(rows.map(_ => ")"))
  },
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Civil Action No. #meta.case_number]
    v(pitch)
    for line in meta.title [#text(weight: "bold", inl(line)) \ ]
  }),
))

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Signature, certification, certificate of service
// ---------------------------------------------------------------------------

/// Signature block (Fed. R. Civ. P. 11(a)): the date line at the left, then each firm's block at the right half.
/// A signing firm has a "By: /s/" line for the signer; the signer's address, e-mail and telephone follow.
#let signature-block(sig) = block(width: 100%, breakable: false, above: pitch, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  [#sig.date_line]
  v(pitch)
  pad(left: 3.0in, stack(dir: ttb, spacing: pitch,
    ..sig.blocks.map(b => block(width: 100%, breakable: false, line-stack(
      if "by" in b and b.by != none {
        (b.firm, "By: /s/ " + b.by) + b.lines
      } else {
        (b.firm,) + b.lines
      },
    ))),
  ))
})

/// The AI certification the June 18, 2024 Standing Order requires (wording as filed in the exemplar).
#let ai-certification(meta) = {
  section-heading[Certification Regarding Use of Artificial Intelligence]
  block(width: 100%, {
    set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
    h(para-indent)
    [Pursuant to the June 18, 2024 Standing Order of this Court _In Re: Use of Artificial Intelligence_, 3:24-mc-104, counsel, by signing above, submits the following certification regarding #meta.ai_title.]
  })
  block(width: 100%, {
    set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
    h(para-indent)
    [1. No artificial intelligence was employed in doing the research for the preparation of this Memorandum, with the exception of such artificial intelligence embedded in the standard on-line legal research sources Westlaw, Lexis, FastCase, and Bloomberg, as well as Google and Google Scholar;]
  })
  block(width: 100%, {
    set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
    h(para-indent)
    [2. Every statement and every citation to an authority contained in this Memorandum has been checked by the undersigned as to the accuracy of the proposition for which it is offered, and the citation to authority provided.]
  })
  signature-block(meta.signature)
}

/// The certificate of service: the filing, the counsel served, the date and the signature.
#let certificate-of-service(meta) = {
  section-heading[Certificate of Service]
  block(width: 100%, {
    set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
    h(para-indent)
    [This is to certify that the undersigned has this day electronically filed the foregoing #meta.service_title with the Clerk of the Court using the CM/ECF system which will send notification of such filing to the following counsel of record:]
  })
  // Each counsel block is unbreakable on its own; the list may break between counsel.
  v(pitch)
  for (k, c) in meta.service.counsel.enumerate() {
    if k > 0 { v(pitch) }
    block(width: 100%, breakable: false, line-stack(c))
  }
  signature-block(meta.signature)
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Body paragraphs are not numbered (a brief is not a pleading, Fed. R. Civ. P. 10(b)); each is indented on its
/// first line. Numbering is not applied here, so no counter is needed.
#let paragraph(t) = [#h(para-indent)#inl(t)]

#let ncwd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: page-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centered section in caps; level 2 a bold argument heading at the left;
  // level 3 a bold italic sub-heading at the left. Each stays with the text after it.
  // Headings are set single-spaced (a two-line heading does not take the double pitch).
  show heading.where(level: 1): it => block(width: 100%, above: pitch, below: body-leading, sticky: true, {
    set par(leading: single-leading)
    align(center, text(weight: "bold", upper(it.body)))
  })
  show heading.where(level: 2): it => block(width: 100%, above: pitch, below: body-leading, sticky: true, {
    set par(leading: single-leading)
    text(weight: "bold", it.body)
  })
  show heading.where(level: 3): it => block(width: 100%, above: pitch, below: body-leading, sticky: true, {
    set par(leading: single-leading)
    text(weight: "bold", style: "italic", it.body)
  })

  cover(meta)

  // Body: each chunk is a heading, a list, an unindented block quotation (">"), or a paragraph.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else if t.starts-with(">") {
      [#inl(t.slice(1).trim())]
    } else {
      paragraph(t)
    }
    parbreak()
  }

  signature-block(meta.signature)
  if "ai_certification" in meta and meta.ai_certification {
    ai-certification(meta)
  }
  if "service" in meta and meta.service != none {
    certificate-of-service(meta)
  }
}
