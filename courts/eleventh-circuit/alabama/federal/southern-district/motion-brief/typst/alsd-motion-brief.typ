// Motion to dismiss with memorandum for the U.S. District Court for the Southern District of Alabama (alsd).
// Rules: S.D. Ala. Gen. L.R. 5(a) (paper, double spacing, 1-inch margins, plain roman font of 12 point or
// larger, counsel's name, address and telephone under the signature line); Civ. L.R. 7(a) (the motion states
// its rule), 7(b) (a Rule 12(b) motion must be supported by a brief; the brief may be in the body of the motion),
// 7(e) (principal briefs at most 30 pages, excluding caption, cover, tables and signature block).
// Fed. R. Civ. P. 5(b) (certificate of service). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // Gen. L.R. 5(a)(2): plain roman font; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // Gen. L.R. 5(a)(2): 12 point or larger, footer included
#let body-leading = 1.345em             // Gen. L.R. 5(a)(1): double-spaced text; 24 pt baseline pitch at 12 pt (same font as the CAND template)
#let single-leading = 0.495em            // headings, caption, block quotes, signature lines may be single-spaced
#let margin = 1in                       // Gen. L.R. 5(a)(1): at least 1 inch on all four sides
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-party-w = 3.2in            // width of the party column of the caption
#let signature-indent = 3.0in           // signature block sits in the right half of the page

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alsd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in *italics*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  // One paragraph with line breaks, so the single spacing comes from the paragraph leading.
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", [IN THE UNITED STATES DISTRICT COURT \ FOR THE SOUTHERN DISTRICT OF ALABAMA \ #upper(meta.division)]))
}

/// Party column, a column of ")" marks, and the civil action number on the middle line (the S.D. Ala. form).
#let caption(meta) = {
  let rows = ()
  let n = meta.caption.parties.len()
  for (k, p) in meta.caption.parties.enumerate() {
    for name in p.names { rows.push(name) }
    rows.push(p.designation)
    if k < n - 1 {
      rows.push("")
      rows.push("v.")
      rows.push("")
    }
  }
  let mid = calc.floor(rows.len() / 2)
  let cells = rows.enumerate().map(((i, r)) => (
    block(width: caption-party-w, inl(r)),
    [)],
    if i == mid { [Civil Action No. #meta.case_number] } else { [] },
  )).flatten()
  set par(leading: single-leading, spacing: 0pt, justify: false)
  grid(columns: (caption-party-w, 0.3in, 1fr), row-gutter: single-leading, ..cells)
}

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", inl(meta.brief_title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block (Gen. L.R. 5(a)(3)): signature line, then name, address and telephone of each attorney.
#let signature-block(meta) = block(breakable: false, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  v(body-leading)
  [Date: #meta.date]
  v(body-leading)
  pad(left: signature-indent, {
    [Respectfully submitted,]
    v(body-leading)
    for (k, lines) in meta.signature.blocks.enumerate() {
      if k > 0 { v(body-leading) }
      for l in lines {
        inl(l)
        linebreak()
      }
    }
  })
})

/// Certificate of service (Fed. R. Civ. P. 5(b)): its own block, kept together.
#let certificate-block(meta) = block(breakable: false, {
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  v(body-leading)
  align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
  v(body-leading)
  h(para-indent)
  inl(meta.certificate.text)
  v(body-leading)
  pad(left: signature-indent, {
    set par(leading: single-leading, spacing: 0pt)
    for l in meta.certificate.signature {
      inl(l)
      linebreak()
    }
  })
})

/// Body paragraphs are unnumbered (a brief, not a pleading). Blank-line-separated markdown chunks: a heading,
/// a list, a block quote, or a paragraph. Each paragraph is indented on its first line.
#let body-text(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lettered (a), (b) ... by the enum set in alsd-motion-brief(); the block's below: is one line of gap.
      block(width: 100%, above: 0pt, below: body-leading, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else if t.starts-with(">") {
      // Block quote: single-spaced and indented, Gen. L.R. 5(a)(1).
      block(width: 100%, below: body-leading, {
        set par(leading: single-leading, first-line-indent: 0pt)
        pad(left: 0.5in, right: 0.5in, cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
      })
    } else {
      // Paragraph: first-line indent, one line of gap after the block (a paragraph's last line does not
      // carry the leading in typst; see alsd-complaint.typ).
      block(width: 100%, above: 0pt, below: body-leading, {
        set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
}

#let alsd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: margin, left: margin, right: margin),
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings (Gen. L.R. 5(a)(1): single-spaced headings are allowed). Level 1 is a centered section; level 2 a
  // bold heading at the left with a hanging indent for the roman numeral; level 3 a bold sub-heading.
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    par(hanging-indent: 0.5in, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    pad(left: 0.5in, par(hanging-indent: 0.5in, text(weight: "bold", it.body))))

  cover(meta)

  body-text(body)

  signature-block(meta)

  if "certificate" in meta and meta.certificate != none {
    certificate-block(meta)
  }
}
