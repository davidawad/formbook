// Complaint for the U.S. District Court for the Southern District of Alabama (alsd).
// Rules: S.D. Ala. Gen. L.R. 5(a) (8 1/2 x 11 paper, double spacing, margins of at least 1 inch, plain roman
// font of 12 point or larger, counsel's name, address and telephone under the signature line), Civ. L.R. 10(a)
// (numbered paragraphs, one set of circumstances each), Fed. R. Civ. P. 10(a) and (b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Gen. L.R. 5(a)(2): plain roman font; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // Gen. L.R. 5(a)(2): 12 point or larger, footer included
#let body-leading = 1.345em             // Gen. L.R. 5(a)(1): double-spaced text; measured as 24 pt baseline pitch at 12 pt (CAND template, same font)
#let single-leading = 0.495em            // headings, caption, counsel and signature lines may be single-spaced
#let margin = 1in                       // Gen. L.R. 5(a)(1): at least 1 inch on all four sides
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-party-w = 3.2in            // width of the party column of the caption
#let signature-indent = 3.0in           // signature block sits in the right half of the page

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alsd-complaint: the sample must start with a YAML frontmatter block") }
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

/// Party column, a column of ")" marks, and the case number on the middle line (the S.D. Ala. form).
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
  if "jury_demand" in meta and meta.jury_demand {
    v(single-leading * 2)
    align(center, text(weight: "bold", "JURY TRIAL DEMANDED"))
  }
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block (Gen. L.R. 5(a)(3)): signature line, then name, address and telephone of each attorney.
#let signature-block(meta) = block(breakable: false, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  v(body-leading)
  [Dated: #meta.date]
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

/// Numbered paragraphs (Civ. L.R. 10(a); Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown
/// that is neither a heading nor a list is one numbered paragraph. Headings and lists are not numbered.
/// Numbering is applied per chunk (not with a `show par` rule, which recurses without end in typst 0.15).
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lettered (a), (b) ... by the enum set in cover(); a list may break across pages. The block's
      // below: is the same one-line gap as a paragraph's (see the note on the numbered blocks).
      block(width: 100%, above: 0pt, below: body-leading, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else if t.starts-with(regex("^(>|\\[|WHEREFORE)")) {
      // Not numbered: a block quote of contract text (single-spaced, Gen. L.R. 5(a)(1)), a prayer
      // lead-in ("WHEREFORE ..."), or a bracketed record cite ("[Indemnity Agreement, ¶ 3].").
      block(width: 100%, below: body-leading, {
        set par(leading: if t.starts-with(">") { single-leading } else { body-leading }, first-line-indent: 0pt)
        if t.starts-with(">") {
          pad(left: 0.5in, right: 0.5in, cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
        } else {
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        }
      })
    } else {
      // A paragraph is numbered on its first line, the number is the next allegation number.
      para-counter.step()
      // below: one line of spacing; a paragraph's last line does not carry the leading (typst), so the
      // gap between two blocks must be the leading itself to keep the 24 pt pitch.
      block(width: 100%, above: 0pt, below: body-leading, {
        set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt)
        h(para-indent)
        context para-counter.display() + [. ]
        h(0.2in)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
}

#let alsd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: margin, left: margin, right: margin),
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centered section; level 2 a centered bold sub-heading; level 3 bold italic at the left.
  // Headings are single-spaced, which Gen. L.R. 5(a)(1) allows, and stay with the paragraph after them.
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    text(weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta {
    set par(leading: body-leading)
    h(para-indent)
    inl(meta.lead_in)
  }

  allegations(body, para-counter)

  signature-block(meta)
}
