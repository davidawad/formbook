// Complaint for the U.S. District Court for the District of Rhode Island (rid).
// Rules: Fed. R. Civ. P. 8(a), 10(a), 10(b), 10(c); D.R.I. LR Cv 5(a)(1)-(5): 8 1/2 x 11 paper, full caption,
// title, double spacing, at least 12-point type, page numbers bottom center, signature block with bar number,
// firm address, fax and email; LR Cv 5(a)(4): jury demand to the right of the caption, below the case number.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
// See ../README.md.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; LR Cv 5(a)(3) sets no typeface, only the size
#let type-size = 12pt                   // LR Cv 5(a)(3): at least 12-point font
#let footnote-size = 10pt               // LR Cv 5(a)(3): footnotes at least 10-point (none in a complaint)
#let page-w = 8.5in                     // LR Cv 5(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // convention (no D.R.I. margin rule); page number sits in the bottom margin
#let text-width = page-w - 2 * margin
#let pitch = 27.6pt                    // double spacing: the baseline pitch of both filed exemplars at 12 pt (measured, README.md)
#let body-leading = 1.645em             // Liberation Serif sets a 0.655em line, so 1.645em of leading gives the 27.6 pt pitch above
#let single-leading = 0.5em             // caption, counsel and signature blocks: single-spaced
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let sig-left = 2.9in                   // width of the left column of the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("rid-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, links, smart punctuation) for one run of text.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// The caption: the party names on the left (closed by a rule on the right and below), the civil action
/// number on the right, and the jury demand below it (LR Cv 5(a)(4)).
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let number = if "case_number" in meta and meta.case_number != "" {
    "C.A. No. " + meta.case_number
  } else {
    "C.A. No. ______________"
  }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.12in, bottom: 0.12in), line-stack(rows)),
    block(inset: (left: 0.1in), {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [#number]
      if "jury_demand" in meta and meta.jury_demand {
        v(pitch)
        text(weight: "bold", "JURY TRIAL DEMANDED")
      }
    }),
  )
}

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", stack(dir: ttb, spacing: single-leading,
    "UNITED STATES DISTRICT COURT",
    "FOR THE DISTRICT OF RHODE ISLAND",
  )))
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, text(weight: "bold", inl(meta.brief_title)))
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, prayer, signature
// ---------------------------------------------------------------------------

/// Heading level 1 is centered bold; level 2 is centered bold italic; level 3 is bold, left.
/// The heading is sticky, so it never ends a page.
#let heading-block(level, text-md) = {
  let c = inl(text-md)
  block(width: text-width, above: 0pt, below: body-leading, sticky: true, {
    set par(leading: single-leading, spacing: 0pt)
    if level == 1 {
      align(center, text(weight: "bold", c))
    } else if level == 2 {
      align(center, text(weight: "bold", style: "italic", c))
    } else {
      text(weight: "bold", c)
    }
  })
}

/// Splits the body into blank-line-separated chunks, and renders each: a heading, a list, an unnumbered
/// prayer ("WHEREFORE" paragraph), or a numbered allegation. The template numbers the allegations itself.
#let body-content(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let pieces = ()
  let n = 0
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      let text-md = t.slice(level).trim()
      pieces.push(heading-block(level, text-md))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pieces.push(block(width: text-width, above: 0pt, below: body-leading, {
        set par(leading: body-leading)
        set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in)
        set list(indent: 0.5in, body-indent: 0.4in)
        inl(t)
        v(body-leading)
      }))
    } else if t.starts-with("WHEREFORE") {
      pieces.push(block(width: text-width, above: 0pt, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        inl(t)
      }))
    } else {
      n += 1
      pieces.push(block(width: text-width, above: 0pt, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        [#(str(n) + ".")#h(0.3in)]
        inl(t)
      }))
    }
  }
  pieces.join()
}

/// The signature block (LR Cv 5(a)(5)): party line, "By ... attorneys", the signers with bar numbers,
/// then the firm's address, telephone, fax and email. Kept on one page.
#let signature(meta) = block(width: text-width, breakable: false, above: pitch, {
  let sig = meta.signature
  grid(
    columns: (sig-left, 1fr),
    column-gutter: 0.2in,
    if "date" in meta { [Dated: #meta.date] } else { [] },
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      line-stack(sig.party)
      v(pitch * 0.5)
      let rows = ()
      for s in sig.signers {
        rows.push("/s/ " + s.name)
        rows.push(if "bar" in s and s.bar != "" { s.name + " " + s.bar } else { s.name })
        rows.push("")
      }
      if rows.len() > 0 { line-stack(rows.slice(0, rows.len() - 1)) }
      v(pitch * 0.5)
      line-stack(sig.firm)
    },
  )
})

#let rid-complaint(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1")
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // A complaint must name every party in the title (Rule 10(a)): the caption carries them all.
  assert("caption" in meta and "parties" in meta.caption, message: "rid-complaint: the sample needs caption.parties")
  assert("brief_title" in meta, message: "rid-complaint: the sample needs brief_title")
  assert("signature" in meta, message: "rid-complaint: the sample needs a signature block (LR Cv 5(a)(5))")

  cover(meta)
  body-content(body)
  signature(meta)
}
