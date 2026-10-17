// Complaint for the U.S. District Court for the Eastern District of Michigan (mied).
// Rules: LR 5.1(a) (double spacing, 1-inch margins, 14-point proportional type, page numbers);
// Fed. R. Civ. P. 10(a) (caption, title, case number), 10(b) (numbered paragraphs), 38(b) (jury demand).
// See ../README.md for the rule text, its source and the open questions.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a named style choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // LR 5.1(a)(3) names no face (any proportional type, 14 pt); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 14pt                   // LR 5.1(a)(3): 14 point for proportional type, footnotes included
#let margin = 1in                       // LR 5.1(a)(2): at least 1 inch, top, bottom and sides
#let page-number-size = 12pt            // page numbers are not text under LR 5.1(a)(3); style choice
// Double spacing (LR 5.1(a)(2)) is defined against the font's own single line. The font's line box is
// 0.655em (Liberation Serif: a 0.65em leading gives a 1.305em baseline pitch), so single spacing here is a 1.15em
// pitch (Times New Roman's single line box) and double spacing is 2.3em, about 32 pt at 14 pt.
#let single-leading = 0.495em            // single pitch 1.15em: captions, counsel, signature, headings, quotations
#let double-leading = 1.645em           // double pitch 2.3em: body text
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-indent = 0.5in              // the number of a numbered paragraph sits at this indent
#let caption-left = 3.3in               // width of the party column of the caption
#let page-w = 8.5in
#let page-h = 11in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mied-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, emphasis) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Markdown block (a chunk of body text) as content, with headings as level-1 blocks.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Single-spaced stack of lines (counsel, party names, signature block).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture: 1-inch margins, arabic page number centered at the foot (LR 5.1(a)(2))
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Caption: court title (Fed. R. Civ. P. 10(a)), party column, case number and judge
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "FOR THE EASTERN DISTRICT OF MICHIGAN")
  if "division" in meta { lines.push(upper(meta.division)) }
  set par(leading: single-leading, spacing: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading, ..lines.map(l => text(weight: "bold", l))))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    let rows = ("Case No. " + meta.case_number,)
    if "judge" in meta { rows.push(meta.judge) }
    if "judges" in meta { rows += meta.judges }
    line-stack(rows)
  }),
)

/// Cover of a paper: court title, caption, title of the paper (all single-spaced, centered title).
#let cover(meta, title) = {
  court-title(meta)
  v(2.3em)
  caption(meta)
  v(2.3em)
  align(center, text(weight: "bold", title))
  v(2.3em)
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b)); headings; prayer list (A., B., ...)
// ---------------------------------------------------------------------------

/// A heading: centered bold (level 1 in caps); level 2 centered bold, level 3 centered.
#let heading-block(level, it) = {
  set par(leading: single-leading)
  block(width: 100%, above: 2.3em, below: 2.3em, sticky: true, {
    if level == 1 { align(center, text(weight: "bold", upper(it.body))) }
    else if level == 2 { align(center, text(weight: "bold", it.body)) }
    else { align(center, text(style: "italic", it.body)) }
  })
}

/// The body as one markdown string. Each blank-line-separated chunk that is neither a heading nor a
/// list becomes a numbered paragraph ("1.<em space>text"); headings and lists pass through unchanged.
/// One markdown string keeps cmarker's own paragraph breaks: rendering the paragraphs as separate
/// content pieces in typst 0.15 runs them together or misplaces their lines.
#let numbered-body(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let parts = ()
  let n = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") or t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      parts.push(t)
    } else {
      n += 1
      parts.push(str(n) + ".\u{2003}" + t)
    }
  }
  parts.join("\n\n")
}

/// Signature block: "Respectfully submitted," then the attorney's electronic signature and contact lines.
#let signature-block(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  pad(left: 3.2in, block(width: 100%, breakable: false, {
    [Respectfully submitted,]
    v(1.15em)
    line-stack(("/s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines)
  }))
}

#let mied-complaint(meta, body) = {
  let title = meta.brief_title

  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    footer: context align(center, text(size: page-number-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: double-leading, spacing: double-leading, first-line-indent: para-indent, justify: false)
  show heading: it => heading-block(it.level, it)

  cover(meta, title)

  if "lead_in" in meta {
    block(width: 100%, {
      set par(leading: double-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Prayer items are lettered A., B., ... (the markdown numbers are not shown).
  set enum(numbering: (..n) => str.from-unicode(64 + n.pos().at(0)) + ".", indent: number-indent, body-indent: 0.5in, spacing: double-leading)
  md(numbered-body(body))

  v(2.3em)
  signature-block(meta)
}
