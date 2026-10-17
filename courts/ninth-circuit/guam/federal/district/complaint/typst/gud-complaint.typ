// Complaint for the United States District Court of Guam (gud).
// Rules: GNLR 5.1 (paper, double spacing, court title not less than 3 in. from the top, counsel in the
// upper left, title of the action below the court title, file number and description at the right, pages
// numbered at the bottom); FRCP 8(a) and 8(d)(1), 10(a) (caption) and 10(b) (numbered paragraphs).
// See ../README.md for the rule text, the dates verified and the known gaps.
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // GNLR 5.1 sets no typeface; EB Garamond is the only font vendored in fonts/
#let type-size = 12pt                   // the convention of both exemplars
#let pitch = 24pt                       // GNLR 5.1(a): double-spaced text
#let page-w = 8.5in                     // GNLR 5.1(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // GNLR 5.1 sets no margin; 1 in. on every side is the exemplars' convention
#let court-title-top = 3in              // GNLR 5.1(b): the court title commences not less than 3 in. from the top
#let counsel-w = 3.25in                 // GNLR 5.1(c)(1): counsel at the upper left; right of centre reserved for the filing stamp
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: 0.65 em line box + 1.35 em = 2 em = 24 pt at 12 pt (measured; README.md)
#let single-leading = 0.5em             // single spacing for counsel, court title, caption, signature: about 13.8 pt
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-w = 3.25in                 // party column of the caption
#let caption-gutter = 0.25in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gud-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names, italics).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines (counsel, court title, caption, signature).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if type(i) == str { inl(i) } else { i }))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Counsel block (GNLR 5.1(c)(1)). Its box fills the space between the top margin and the court title, so the
/// court title commences at 3 in. (GNLR 5.1(b)). The rule says "not less than three inches", so a longer counsel
/// block pushes the court title down instead of failing.
#let counsel-block(meta) = context {
  let h = measure(width: counsel-w, line-stack(meta.counsel)).height
  // A counsel block longer than the box leaves one line of clearance above the court title.
  block(width: counsel-w, height: calc.max(court-title-top - margin, h + pitch * 0.5), line-stack(meta.counsel))
}

#let court-title(meta) = align(center, text(weight: "bold", line-stack(meta.court_title)))

// ---------------------------------------------------------------------------
// Caption (GNLR 5.1(c)(2)-(3)): title of the action below and left of the court title; file number,
// civil designation and a description of the paper to the right.
// ---------------------------------------------------------------------------

#let caption-left(meta) = {
  // One single-spaced stack: every line, including the blank lines between parties, takes one line pitch.
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      rows += ("", pad(left: 0.5in, inl(meta.caption.between)), "")
    }
    rows += p.names
    rows.push(pad(left: 1in, inl(p.designation)))
  }
  block(width: caption-w, line-stack(rows))
}

#let caption-right(meta) = block(width: text-width - caption-w - caption-gutter, {
  set par(leading: single-leading, spacing: 0pt)
  line-stack((meta.case_number, meta.designation))
  v(pitch)
  text(weight: "bold", inl(meta.brief_title))
  if "brief_subtitle" in meta {
    v(single-leading)
    inl(meta.brief_subtitle)
  }
})

#let caption(meta) = grid(
  columns: (caption-w, 1fr),
  column-gutter: caption-gutter,
  caption-left(meta),
  caption-right(meta),
)

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, {
  v(pitch)
  set par(leading: single-leading, spacing: 0pt)
  [Respectfully submitted this #meta.date.]
  v(pitch)
  pad(left: 3in, line-stack(meta.signature.firm + ("", "/s/ " + meta.signature.signer) + meta.signature.lines))
})

/// Body: each blank-line-separated chunk is a heading, a list, an unnumbered paragraph (marked
/// `<!-- unnumbered -->`), or a numbered paragraph (FRCP 10(b)). Headings are kept with the chunk after them.
#let allegations(body) = {
  let para-no = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; its items are spaced by body-leading.
      set par(leading: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading)
    } else if t.starts-with("<!--") {
      let text = t.replace(regex("^<!--[^>]*-->\\s*"), "")
      block(breakable: true, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        inl(text)
      })
    } else {
      para-no += 1
      block(breakable: true, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        [#para-no.#h(0.3in)#inl(t)]
      })
    }
  }
}

#let gud-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set block(spacing: 0pt)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centred section (roman numerals are typed in the sample); level 2 a bold sub-heading.
  show heading.where(level: 1): it => block(width: 100%, above: pitch, below: body-leading, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: pitch, below: body-leading, sticky: true,
    text(weight: "bold", it.body))

  cover(meta)

  if "lead_in" in meta {
    block(width: 100%, below: body-leading, {
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(body)

  signature-block(meta)
}
