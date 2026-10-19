// Adversary complaint for the U.S. Bankruptcy Court, S.D. Ohio (FRBP 7001 proceeding).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies to the form of an adversary pleading; the caption
// substantially conforms to Official Form 416), 9004(a)-(b) (legible; caption with court, title, case and
// adversary numbers, designation); S.D. Ohio LBR 9004-1(b) (8 1/2 x 11, double spaced, top margin of one inch or
// more, 10-12 point type), LBR 9004-2 (caption: debtor, case number, chapter, adversary number, judge, nature of the
// paper and the relief), LBR 7001-1 (one adversary per defendant: not checked here). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LBR 9004-1(b): typed print at least 10-12 point; 12 point is used
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is 0.655em, so 24 pt pitch at 12 pt
#let single-leading = 0.495em            // footnotes, signature block and caption lines: about 14 pt pitch
#let cap-line = 14pt                    // one caption or signature line (fixed height keeps the ")" column aligned)
#let para-indent = 0.5in                // first-line indent of paragraphs
#let margin = 1in                       // LBR 9004-1(b): top margin not less than one inch; the sides match it
#let text-width = 8.5in - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohsb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Footnote definitions "[^n]: text" keyed by label. Their chunks are removed from the body and each
/// reference "[^n]" becomes a typst footnote with the definition's text.
#let footnote-defs(body) = {
  let d = (:)
  for m in body.matches(regex("(?m)^\\[\\^(\\w+)\\]:[ \\t]*(.+)$")) {
    d.insert(m.captures.at(0), m.captures.at(1))
  }
  d
}

/// Inline markdown for one text segment. Markdown drops whitespace at a segment's edges, so a space at either edge
/// is kept as a typst space (a footnote reference sits between two segments).
#let seg(s) = {
  let lead = if s.starts-with(" ") { [ ] } else { [] }
  let trail = if s.ends-with(" ") { [ ] } else { [] }
  lead + inl(s) + trail
}

/// Inline markdown with footnote references turned into typst footnotes.
#let rich(t, defs) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^(\\w+)\\]")) {
    out += seg(t.slice(pos, m.start))
    out += footnote(inl(defs.at(m.captures.at(0))))
    pos = m.end
  }
  out + seg(t.slice(pos))
}

#let is-list(t) = t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none
#let is-relief(t) = t.match(regex("^([ivxlcdm]+)\\.[ \\t]")) != none
#let is-def(t) = t.match(regex("^\\[\\^\\w+\\]:")) != none

/// A heading stays with the paragraph after it (it never ends a page).
#let heading-block(c) = block(width: text-width, above: body-leading, below: body-leading, sticky: true, c)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Court name (LBR 9004-2: the court and the division) in single spacing.
#let court-title(meta) = stack(dir: ttb, spacing: 0pt,
  ..("UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF OHIO", meta.division).map(l =>
    block(height: cap-line, width: 100%, align(center, text(weight: "bold", l)))))

/// Caption: the parties and the case information on either side of a column of ")" marks, one row per line.
/// Each row is a fixed-height block, so the marks line up with the parties' lines.
#let caption(meta) = grid(
  columns: (3.4in, 0.3in, 1fr),
  stack(dir: ttb, spacing: 0pt, ..meta.caption.left.map(l =>
    block(height: cap-line, width: 100%, text(l)))),
  stack(dir: ttb, spacing: 0pt, ..meta.caption.left.map(_ =>
    block(height: cap-line, width: 100%, align(center, ")")))),
  stack(dir: ttb, spacing: 0pt, ..meta.caption.right.map(r =>
    block(height: cap-line, width: 100%, inset: (left: 0.15in), text(r)))),
)

#let cover(meta) = {
  set par(leading: 0pt, spacing: 0pt)
  court-title(meta)
  v(body-leading)
  block(width: text-width, height: meta.caption.left.len() * cap-line, caption(meta))
  v(body-leading)
  block(width: text-width, below: body-leading, {
    set par(leading: single-leading)
    align(center, text(weight: "bold", meta.brief_title))
  })
}

// ---------------------------------------------------------------------------
// Signature block: optional "Dated:" at the left, the closing and the signer's lines at the right
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, above: body-leading, grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  if "date" in meta and meta.date != none { [Dated: #meta.date] } else { [] },
  {
    let sig = meta.signature
    if "closing" in sig and sig.closing != "" {
      block(height: cap-line, width: 100%, text(sig.closing))
      v(cap-line)
    }
    stack(dir: ttb, spacing: 0pt, ..sig.lines.map(l => block(height: cap-line, width: 100%, text(l))))
  },
))

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b)), headings, lettered and roman items, tables
// ---------------------------------------------------------------------------

/// Renders the body chunks in order. A chunk is a heading ("#"/"##"), a table ("|"), a list, a roman-numeral item,
/// the signature directive, the centered asterisks, or a paragraph (numbered, Fed. R. Civ. P. 10(b)).
#let render-body(chunks, meta, defs) = {
  let para = 0
  let relief = 0
  for t in chunks {
    if t.starts-with("## ") {
      heading-block(align(center, text(weight: "bold", t.slice(3))))
    } else if t.starts-with("# ") {
      heading-block(align(center, text(weight: "bold", upper(t.slice(2)))))
    } else if t == "<!-- SIGNATURE -->" {
      signature-block(meta)
    } else if t.starts-with("|") {
      block(width: text-width, above: body-leading, below: body-leading,
        align(center, cmarker.render(t, raw-typst: false, smart-punctuation: true)))
    } else if is-list(t) {
      block(width: text-width, {
        set par(leading: body-leading)
        set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true)
      })
    } else if is-relief(t) {
      let mm = t.match(regex("^([ivxlcdm]+)\\.[ \\t]+"))
      relief += 1
      par[#h(para-indent) #numbering("i.", relief) #h(0.3in) #rich(t.slice(mm.end), defs)]
    } else {
      para += 1
      par[#h(para-indent) #str(para). #h(0.3in) #rich(t, defs)]
    }
  }
}

// ---------------------------------------------------------------------------
// Entry: the whole complaint
// ---------------------------------------------------------------------------

#let complaint(meta, body) = {
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "" and not is-def(c))

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Paragraph spacing equals the leading: typst adds leading only between the lines of one paragraph, so the
  // gap between paragraphs carries the second half of the double-spaced pitch.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: 0.4em)
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, spacing: 0.4em)
  set table(stroke: 0.5pt, inset: 5pt)

  cover(meta)

  if "lead_in" in meta {
    par[#h(para-indent) #rich(meta.lead_in, defs)]
  }

  render-body(chunks, meta, defs)
}
