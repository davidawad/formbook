// Motion with brief in support (memorandum), United States Bankruptcy Court for the Western District of
// Wisconsin (wiwb). Built from the rules; the filed exemplar (../usage/SOURCE.md) settles only what they
// leave open. Rules (see ../README.md for quotes, URLs and the verification date):
//   Fed. R. Bankr. P. 9013 (a motion is written; it states its grounds with particularity and the relief sought),
//   9004(a)-(b) (legibility; caption elements), 9011 (signature block), 9014 (contested matter, for a motion
//   that is not an adversary-proceeding motion), 7012(b) (Fed. R. Civ. P. 12(b) defenses in adversary proceedings).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; no system font is used (tools/render.sh)
#let type-size = 12pt                   // convention: 12 point body text (no W.D. Wis. rule found; README.md)
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (convention; README.md)
#let page-h = 11in
#let margin-x = 1in                     // convention: 1 inch side margins
#let margin-top = 1in
#let margin-bottom = 1in
#let text-width = page-w - 2 * margin-x
#let body-leading = 1.645em             // double-spaced body (convention; no W.D. Wis. rule found): 2 x 1.15 x 12 pt = 27.6 pt baseline pitch, the word-processor "double" line (README.md)
#let single-leading = 0.5em             // single-spaced caption and signature block
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF WISCONSIN")   // Fed. R. Bankr. P. 9004(b)(1)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wiwb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced stack of lines (caption, signature block).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Page number, centered in the footer. The ECF header is added by the court's system, not here.
#let footer() = context align(center, text(size: 11pt, counter(page).display()))

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 9004(b); Fed. R. Bankr. P. 7010 and Official Form 416 for adversary captions)
// ---------------------------------------------------------------------------

#let court-title() = {
  align(center, line-stack(court-name.map(l => "**" + l + "**")))
  v(1.5em)
}

/// The party column: each side is its names, then its designation; "v." between the sides.
#let party-column(meta) = {
  let sides = meta.caption
  for (i, side) in sides.enumerate() {
    line-stack(side.names)
    v(single-leading)
    block(width: caption-left - 0.4in, align(right, inl(side.designation)))
    if i < sides.len() - 1 {
      v(0.8em)
      align(left, "v.")
      v(0.8em)
    }
  }
}

/// Caption. A contested matter in the main case (no `caption:` in the frontmatter) follows Official Form 416B
/// (Caption, Short Title, 12/15): "In re" and the debtor's name with "Debtor" under it at the left; "Case No."
/// and "Chapter" at the right; no rules. An adversary proceeding keeps the boxed party column with the
/// adversary number at the right (Fed. R. Bankr. P. 7010). The adversary number is printed only when the
/// sample gives one; otherwise a blank line for the clerk.
#let caption(meta) = if "caption" not in meta {
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    // One blank single-spaced line between the elements, as Official Form 416B spaces them.
    {
      set par(leading: single-leading, justify: false)
      set block(spacing: 1.5em)
      block("In re:")
      block(inl(meta.debtor))
      block(pad(left: para-indent, "Debtor."))
    },
    {
      set par(leading: single-leading, justify: false)
      set block(spacing: 1.5em)
      block("Case No. " + meta.bankruptcy_case)
      if "chapter" in meta { block("Chapter " + meta.chapter) }
    },
  )
} else {
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
      line-stack(("In re:", meta.debtor, "Debtor.", "Case No. " + meta.bankruptcy_case)
        + if "chapter" in meta { ("Chapter " + meta.chapter,) } else { () })
      v(1.2em)
      party-column(meta)
    }),
    align(top, {
      v(0.2em)
      text(weight: "bold", "Adversary Case No.")
      h(0.4em)
      if "adversary_case" in meta and meta.adversary_case != "" {
        meta.adversary_case
      } else {
        box(width: 1.6in, line(length: 1.6in, stroke: 0.5pt))
      }
    }),
  )
}

#let cover(meta) = {
  court-title()
  caption(meta)
  v(2em)
  // Designation of the paper (Fed. R. Bankr. P. 9004(b)(4); Official Form 416B "[Designation of Character of
  // Paper]"): centred, bold capitals, single-spaced so a two-line title reads as one block.
  align(center, block(width: text-width - 2 * para-indent, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    text(weight: "bold", upper(meta.title))
  }))
  v(2em)
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, lists
// ---------------------------------------------------------------------------

/// Brief body: each blank-line-separated chunk is one paragraph (first-line indent, not numbered: a brief
/// is argument, not allegations). Headings are rendered by the show rules below. Markdown ordered lists
/// become (1), (2), ... for the grounds and (a), (b), ... nowhere else.
/// Chunks are emitted with parbreak() so that paragraphs do not run together.
#let brief-body(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote text is kept apart from the chunks: each chunk is rendered alone, so a chunk gets the
  // definitions of the notes it refers to, and a definition chunk is not printed as a paragraph.
  let notes = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) {
    notes.insert(m.captures.at(0), m.captures.at(1))
  }
  let chunks = chunks.filter(c => not c.trim().starts-with(regex("^\\[\\^[^\\]]+\\]:")))
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
      let id = r.captures.at(0)
      t = t + "\n\n[^" + id + "]: " + notes.at(id, default: "")
    }
    parbreak()
    // The last paragraph is kept on the page with the signature block that follows it, so the signature
    // never stands alone on a page (the signature block itself does not break).
    let last = i == chunks.len() - 1
    show: it => if last { block(sticky: true, breakable: false, it) } else { it }
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(">") {
      // Block quotation: indented 0.5 inch on both sides, single-spaced, not first-line indented.
      pad(left: 0.5in, right: 0.5in, {
        set par(leading: single-leading, spacing: body-leading, first-line-indent: 0pt)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      h(para-indent)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Bankr. P. 9011): date, firm, /s/ signature, signer, bar number, address, phone
// ---------------------------------------------------------------------------

#let signature(meta) = {
  v(2 * body-leading)
  // Rows: closing and firm in the right column; then the date at the left on the same line as the "By:"
  // signature line; then the signer's lines under the signature.
  block(width: text-width, breakable: false, {
    set par(leading: single-leading, justify: false)
    grid(
      columns: (1fr, 3.1in),
      row-gutter: 1.5em,
      [],
      {
        // The closing line ("Respectfully submitted,") is the filer's choice; it is printed only when given.
        if "closing" in meta.signature { block(below: 1.5em, meta.signature.closing) }
        if "firm" in meta.signature { text(weight: "bold", meta.signature.firm) }
      },
      if "date" in meta { inl(meta.date) } else { [] },
      // Electronic signature: "/s/" before the signer's name, as CM/ECF filers type it (Fed. R. Bankr. P.
      // 9011(a) requires the signature; the "/s/" form is convention, see README.md).
      {
        "By: /s/ " + meta.signature.signer
        v(0.2em)
        line-stack(meta.signature.lines)
      },
    )
  })
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let wiwb-motion-brief(meta, body) = {
  // Fed. R. Bankr. P. 9013(b) requires the grounds and the relief requested, in substance. It does not require
  // headings for them: the filed memorandum (../usage/SOURCE.md) states both in its own headings, so the
  // template asserts nothing about heading names.

  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-x, right: margin-x),
    footer: footer(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Paragraph gap of body-leading: with the 1.645em leading and a 0.655em line box, paragraphs start at the
  // same 27.6 pt pitch as lines (see README.md for the measurement method).
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings are the body size (typst's default heading size is larger; the filed memorandum's are 12 pt).
  // A heading is single-spaced (a two-line heading reads as one unit) and set off by one double-spaced line
  // above and below; it is sticky so it never ends a page.
  show heading.where(level: 1): it => block(width: text-width, above: body-leading, below: body-leading,
    sticky: true, {
      set par(leading: single-leading)
      align(center, text(size: type-size, weight: "bold", upper(it.body)))
    })
  show heading.where(level: 2): it => block(width: text-width, above: body-leading, below: body-leading,
    sticky: true, {
      set par(leading: single-leading, hanging-indent: 0.4in)
      text(size: type-size, weight: "bold", it.body)
    })

  cover(meta)
  brief-body(body)
  signature(meta)
}
