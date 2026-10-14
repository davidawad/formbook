// Motion with brief in support (memorandum), United States Bankruptcy Court for the Western District of
// Wisconsin (wiwb). Built from the rules, not from a filed exemplar (none found: see ../exemplars/SOURCE.md).
// Rules (see ../README.md for quotes, URLs and the verification date):
//   Fed. R. Bankr. P. 9013 (a motion is written; it states its grounds with particularity and the relief sought),
//   9004(a)-(b) (legibility; caption elements), 9011 (signature block), 9014 (contested matter, for a motion
//   that is not an adversary-proceeding motion), 7012(b) (Fed. R. Civ. P. 12(b) defenses in adversary proceedings).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; no system font is used (tools/render.sh)
#let type-size = 12pt                   // convention: 12 point body text (no W.D. Wis. rule found; README.md)
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (convention; README.md)
#let page-h = 11in
#let margin-x = 1in                     // convention: 1 inch side margins
#let margin-top = 1in
#let margin-bottom = 1in
#let text-width = page-w - 2 * margin-x
#let body-leading = 1.35em              // convention: loosely double-spaced body; measured pitch in README.md
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

/// Caption for a contested matter (main case, no adversary) or an adversary proceeding. The adversary
/// number is printed only when the sample gives one; otherwise a blank line for the clerk.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    line-stack(("In re:", meta.debtor, "Case No. " + meta.bankruptcy_case, "Chapter " + meta.chapter))
    if "caption" in meta {
      v(1.2em)
      party-column(meta)
    }
  }),
  align(top, {
    v(0.2em)
    if "caption" in meta {
      text(weight: "bold", "Adversary Case No.")
      if "adversary_case" in meta and meta.adversary_case != "" {
        h(0.4em)
        meta.adversary_case
      } else {
        h(0.4em)
        box(width: 1.6in, line(length: 1.6in, stroke: 0.5pt))
      }
    }
  }),
)

#let cover(meta) = {
  court-title()
  caption(meta)
  v(1.5em)
  align(center, text(weight: "bold", upper(meta.title)))
  v(1.5em)
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
  for c in chunks {
    let t = c.trim()
    parbreak()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
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
  block(width: text-width, breakable: false, grid(
    columns: (1fr, 3.1in),
    align(top, if "date" in meta { inl(meta.date) } else { [] }),
    align(top, {
      if "firm" in meta.signature { text(weight: "bold", meta.signature.firm) }
      v(single-leading)
      "Respectfully submitted,"
      v(2 * body-leading)
      "/s/ " + box(width: 2.8in, line(length: 2.8in, stroke: 0.5pt))
      v(0.2em)
      line-stack((meta.signature.signer,) + meta.signature.lines)
    }),
  ))
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let wiwb-motion-brief(meta, body) = {
  // Fed. R. Bankr. P. 9013(a)-(b): a motion is written and states its grounds with particularity and the relief
  // requested. The template requires a relief statement; the grounds are the sample's to write.
  assert(body.match(regex("(?im)^# *relief requested")) != none, message: "wiwb-motion-brief: Fed. R. Bankr. P. 9013(b) requires the relief requested (a '# RELIEF REQUESTED' heading)")
  assert(body.match(regex("(?im)^# *grounds")) != none, message: "wiwb-motion-brief: Fed. R. Bankr. P. 9013(b) requires the grounds stated with particularity (a '# GROUNDS' heading)")

  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-x, right: margin-x),
    footer: footer(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Paragraph gap of body-leading: with the 1.35em leading and a 0.65em line box, paragraphs start at the
  // same 24 pt pitch as lines (see README.md for the measurement method).
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  show heading.where(level: 1): it => block(width: text-width, above: 1.2em, below: 0.6em, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: 1em, below: 0.5em, sticky: true,
    text(weight: "bold", it.body))

  cover(meta)
  brief-body(body)
  signature(meta)
}
