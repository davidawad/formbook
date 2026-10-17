// Complaint initiating an adversary proceeding, United States Bankruptcy Court for the District of Delaware.
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; caption substantially conforms to Official
// Form 416); Fed. R. Civ. P. 10(a) (names of all parties, title) and 10(b) (numbered paragraphs);
// Fed. R. Bankr. P. 7008 and Del. Bankr. L.R. 7008-1 (statement whether the pleader consents to entry of
// final orders); Del. Bankr. L.R. 9004-1(a) (caption contents), 7003-1 (cover sheet, filed separately),
// 7004-1 (summons, filed separately). See ../README.md. Content-agnostic: every case-specific word comes
// from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
// No typeface is named for pleadings: LR 7007-2 applies only to motions in adversary proceedings, and
// Fed. R. Bankr. P. 7010 / Fed. R. Civ. P. 10 name none, so the default applies: Liberation Serif, the
// Times New Roman substitute (docs/FONTS.md "No face named"). See ../README.md, "Typeface".
#let font-family = "Liberation Serif"        // Times New Roman substitute (docs/FONTS.md "No face named"); vendored in fonts/
#let type-size = 12pt
#let body-leading = 1.345em              // double spacing: Liberation Serif line box 0.655em + 1.345em = 24 pt at 12 pt
#let single-leading = 0.5em
#let page-w = 8.5in                      // FRBP 9004(a): legible; letter-size paper
#let page-h = 11in
#let margin = 1in
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                 // first-line indent of numbered paragraphs
#let caption-left = 3.4in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("deb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

#let page-setup(body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1",
    footer: context align(center, text(size: type-size, counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, justify: false)
  body
}

// ---------------------------------------------------------------------------
// Caption (FRBP 7010 / Official Form 416; LR 9004-1(a)). Party names on the left, case
// and adversary numbers on the right.
// ---------------------------------------------------------------------------

#let caption-block(parties, right) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    let rows = ()
    for (k, p) in parties.enumerate() {
      if k > 0 { rows.push("") }
      rows += p.names
      if "designation" in p { rows.push(p.designation) }
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.15in), line-stack(right)),
)

#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", upper(meta.court)))
  v(body-leading)
  caption-block(meta.caption.bankruptcy.parties, meta.caption.bankruptcy.right)
  v(body-leading)
  caption-block(meta.caption.adversary.parties, meta.caption.adversary.right)
  v(body-leading)
  align(center, text(weight: "bold", inl(meta.title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs (FRCP 10(b)), unnumbered preamble
// ---------------------------------------------------------------------------

/// Heading styles: centred bold (level 1), bold left (level 2), centred bold (level 3, for the
/// count headings). A heading never ends a page: it is kept with the paragraph after it.
#let heading-styles(c) = {
  show heading.where(level: 1): it => block(above: body-leading, below: body-leading, width: text-width,
    sticky: true, align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(above: body-leading, below: body-leading, width: text-width,
    sticky: true, par(hanging-indent: 0.5in, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(above: body-leading, below: body-leading, width: text-width,
    sticky: true, align(center, text(weight: "bold", it.body)))
  c
}

/// Numbered allegations. Each blank-line-separated chunk of markdown is one numbered paragraph (FRCP
/// 10(b)), except: headings; lists; the prayer (a WHEREFORE clause and its lettered items, which the
/// exemplar leaves unnumbered); and editorial notes written in italic brackets ("*[...]*"), which mark
/// omitted text in a sample. Numbering is applied per chunk, not with a `show par` rule: a show rule
/// that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list is rendered as it is written and not numbered.
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with("WHEREFORE") {
      par(first-line-indent: 0pt, [#h(para-indent) #inl(t)])
    } else if t.starts-with(regex("^[a-z]\\) ")) {
      par(first-line-indent: 0pt, [#h(para-indent) #inl(t)])
    } else if t.starts-with("*[") {
      align(center, text(style: "italic", inl(t)))
    } else {
      n += 1
      par(first-line-indent: 0pt, [#h(para-indent) #str(n).#h(0.5in) #inl(t)])
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (FRBP 9011 / LR 9011-style block: date, firm, signer, counsel to plaintiffs)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  v(body-leading)
  block(breakable: false, grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date \ #meta.signature.place],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(single-leading)
      for b in meta.signature.blocks {
        line-stack(b.firm)
        v(single-leading)
        line-stack(b.attorneys)
        v(body-leading)
      }
    },
  ))
}

#let deb-adversary-complaint(meta, body) = {
  page-setup({
    caption(meta)
    if "preamble" in meta {
      par(first-line-indent: para-indent, inl(meta.preamble))
    }
    heading-styles({
      allegations(body)
    })
    signature-block(meta)
  })
}
