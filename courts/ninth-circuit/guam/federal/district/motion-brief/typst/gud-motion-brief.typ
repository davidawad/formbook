// Motion with memorandum for the United States District Court of Guam (gud), FRCP 12(b) and 12(f).
// Rules: GNLR 5.1 (paper, double spacing, court title not less than 3 in. from the top, counsel in the
// upper left, title of the action below the court title, file number, civil designation and description
// at the right, pages numbered at the bottom); FRCP 7(b)(1) (grounds stated with particularity, relief
// stated), FRCP 10(a) (caption), FRCP 12(b)(6) and 12(f); FRCP 5(d)(1)(B) (no certificate of service is
// required for e-filing; the exemplar carries one, so the sample does too).
// See ../README.md for the rule text, the dates verified and the known gaps.
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // GNLR 5.1 sets no typeface; EB Garamond is the only font vendored in fonts/
#let type-size = 12pt                   // the convention of the exemplar
#let pitch = 24pt                       // GNLR 5.1(a): double-spaced text
#let page-w = 8.5in                     // GNLR 5.1(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // GNLR 5.1 sets no margin; 1 in. on every side is the exemplar's convention
#let court-title-top = 3in              // GNLR 5.1(b): the court title commences not less than 3 in. from the top
#let counsel-w = 3.25in                 // GNLR 5.1(c)(1): counsel at the upper left; right of centre reserved for the filing stamp
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: 0.65 em line box + 1.35 em = 2 em = 24 pt at 12 pt (measured; README.md)
#let single-leading = 0.5em             // single spacing for counsel, court title, caption, signature, addresses: about 13.8 pt
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-w = 3.25in                 // party column of the caption
#let caption-gutter = 0.25in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gud-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names, italics).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines (counsel, court title, caption, signature, addresses): one line pitch each.
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
// civil designation and a description of the paper (and of any memorandum) to the right.
// ---------------------------------------------------------------------------

#let caption-left(meta) = {
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
  line-stack((meta.case_number, meta.designation) + if "case_notes" in meta { meta.case_notes } else { () })
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

#let signature-block(meta) = block(breakable: false, below: body-leading, {
  v(pitch)
  set par(leading: single-leading, spacing: 0pt)
  [Respectfully submitted this #meta.date.]
  v(pitch)
  pad(left: 3in, line-stack(meta.signature.firm + ("", "/s/ " + meta.signature.signer) + meta.signature.lines))
})

/// Body: each blank-line-separated chunk is a heading, a list, an unnumbered paragraph, or one of three
/// markers: `<!-- signature -->` (the signature block goes here), `<!-- single -->` (the lines of the chunk
/// are single-spaced, e.g. an address), and a heading "CERTIFICATE..." starts a new page.
/// Headings are kept with the chunk after them. The signature block is appended at the end if the
/// sample has no `<!-- signature -->` marker.
#let memorandum(body, meta) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("<!-- signature -->") {
      signature-block(meta)
    } else if t.starts-with("<!-- single -->") {
      let text = t.replace(regex("^<!--[^>]*-->\\s*"), "")
      block(breakable: false, below: body-leading, line-stack(text.split(regex("\\r?\\n"))))
    } else if t.starts-with("#") {
      if t.starts-with("# CERTIFICATE") { pagebreak(weak: true) }
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; its items are spaced by body-leading.
      set par(leading: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading)
    } else {
      block(breakable: true, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        inl(t)
      })
    }
  }
  if not body.contains("<!-- signature -->") {
    signature-block(meta)
  }
}

#let gud-motion-brief(meta, body) = {
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

  memorandum(body, meta)
}
