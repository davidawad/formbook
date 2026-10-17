// Memorandum brief in support of a motion for the U.S. District Court for the Southern District of Mississippi (mssd).
// Rules: L.U.Civ.R. 7(b)(2) (the memorandum is a separate docket item from the motion), 7(b)(5)(A) (8 1/2 x 11, double
// spaced, margins of at least 1 inch on all four sides, page numbers only in the margins), 7(b)(5)(B) (proportional serif
// face, 12-point text, footnotes 11-point or larger), 7(b)(5)(C) (case names italic or underlined), 11(a) (counsel's
// name, address, telephone, fax, e-mail and bar number); the 35-page limit of 7(b)(5) is not checked (see ../README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a choice recorded in README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute per docs/FONTS.md (Times New Roman in the exemplar)
#let type-size = 12pt                   // L.U.Civ.R. 7(b)(5)(B): text 12-point or larger
#let footnote-size = 11pt               // 7(b)(5)(B): footnotes 11-point or larger
#let margin = 1in                       // 7(b)(5)(A): at least 1 inch on all four sides
#let body-leading = 1.645em             // 7(b)(5)(A): double spacing, calibrated to 27.6 pt line pitch (README.md); Liberation Serif's 0.655em line box + 1.645em = 2.3em = 27.6 pt at 12 pt
#let single-leading = 0.25em            // headings, caption, footnotes, signature block: single spaced
#let para-indent = 0.5in                // first-line indent of body paragraphs

// The signature fields L.U.Civ.R. 11(a) requires. The template refuses to render without them.
#let required-signature-keys = ("signer", "bar_no", "firm", "address", "telephone", "fax", "email")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mssd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, smart quotes).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A heading stays with the paragraph after it (sticky) and is followed by one line of space.
#let heading-block(c) = block(width: 100%, above: 0pt, below: body-leading, sticky: true, text(size: type-size, c))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  for line in meta.court {
    align(center, text(weight: "bold", upper(line)))
    linebreak()
  }
}

#let caption(meta) = grid(
  columns: (3.6in, 1fr),
  column-gutter: 0.1in,
  {
    // Each party: its names, then its designation; "v." on its own line between the parties.
    let blocks = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { blocks.push(line-stack(("v.",))) }
      blocks.push(line-stack(p.names + (p.designation,)))
    }
    stack(dir: ttb, spacing: single-leading * 2, ..blocks)
  },
  align(horizon, {
    set par(leading: single-leading, spacing: 0pt)
    [CIVIL ACTION NO.#linebreak()#meta.case_number]
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, underline(text(weight: "bold", upper(meta.brief_title))))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Signature and certificate
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = meta.signature
  for k in required-signature-keys {
    assert(k in s, message: "mssd-motion-brief: signature." + k + " is required (L.U.Civ.R. 11(a))")
  }
  block(width: 100%, breakable: false, below: body-leading, {
    v(body-leading)
    if "date" in s {
      block(width: 100%, below: body-leading, [Respectfully submitted, this the #s.date])
    }
    pad(left: 3.0in, {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [#s.firm]
      linebreak()
      for a in s.address { [#a]; linebreak() }
      [Telephone: #s.telephone]
      linebreak()
      [Facsimile: #s.fax]
      v(single-leading * 2)
      [s/ #s.signer]
      linebreak()
      [#upper(s.signer), #s.bar_no]
      linebreak()
      [Email: #s.email]
    })
  })
}

#let certificate-block(meta) = if "certificate" in meta {
  let c = meta.certificate
  block(width: 100%, breakable: false, {
    heading-block(align(center, text(weight: "bold", underline("CERTIFICATE OF SERVICE"))))
    block(width: 100%, below: body-leading, {
      set par(leading: body-leading)
      h(para-indent)
      inl(c.text)
    })
    pad(left: 3.0in, {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [s/ #c.signer]
      linebreak()
      [#upper(c.signer), #c.bar_no]
    })
  })
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------
/// Body text: each blank-line-separated markdown chunk is one paragraph with a first-line indent. Headings are
/// sticky (see heading-block). cmarker resolves a footnote only when its definition is in the same render call as
/// its reference, so each definition ("[^n]: ...") is attached to the paragraph that cites it, and no definition
/// chunk is rendered on its own.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = (:)
  for t in chunks {
    if t.starts-with("[^") {
      defs.insert(t.slice(2, t.position("]")), t)
    }
  }
  for t in chunks {
    if t.starts-with("[^") { continue }
    let src = t
    for (label, def) in defs {
      if t.contains("[^" + label + "]") { src += "\n\n" + def }
    }
    if t.starts-with("#") {
      cmarker.render(src, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: 100%, below: body-leading, {
        set par(leading: body-leading)
        cmarker.render(src, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      block(width: 100%, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(src, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
}

#let mssd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Footnotes: single spaced, 7(b)(5)(B) size, a short rule above them.
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings: level 1 is a centered, bold, underlined caps section; level 2 is a bold sub-heading at the left.
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", underline(upper(it.body)))))
  show heading.where(level: 2): it => heading-block(text(weight: "bold", it.body))

  cover(meta)

  body-chunks(body)

  signature-block(meta)
  certificate-block(meta)
  // L.U.Civ.R. 7(b)(5): the movant's original and rebuttal memoranda together may not exceed 35 pages.
  context {
    let pages = counter(page).final().first()
    assert(pages <= 35, message: "mssd-motion-brief: the memorandum is " + str(pages) + " pages; L.U.Civ.R. 7(b)(5) allows 35")
  }
}
