// U.S. Bankruptcy Court, Middle District of North Carolina: adversary complaint (Fed. R. Bankr. P. 7001 et seq.).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; the caption substantially conforms to Official
// Form 416D), 7008(a) (jurisdiction statement and consent to final orders), Fed. R. Civ. P. 10(b) (numbered
// paragraphs); Local Rule 9011-4 (signature block: state bar number, telephone, email). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"        // the local rules set no typeface; Schola matches the audited exemplar (docs/FONTS.md)
#let type-size = 12pt                   // FRBP 9004(a): "clearly legible"; no local size rule, so the 12 pt convention (docs/FONTS.md)
#let pitch = 24pt                       // the double-spaced line pitch of the filed exemplar
#let body-leading = pitch - 1.15em     // gap between body lines: the text runs in a 1.15em line box (top-edge 0.9em, bottom-edge -0.25em), so the line pitch is `pitch` (double spacing)
#let single-leading = 0.2em             // single spacing: caption, court title, signature block, footnotes
#let cap-row = 16pt                     // one single-spaced caption row; the parenthesis column aligns row by row
#let page-margin = 1in
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let number-gap = 0.3in
#let caption-left = 3.2in               // party column of the caption
#let caption-paren = 0.35in             // the ")" column
#let signature-indent = 3.25in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncmb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names, citations, section symbols) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A required frontmatter field: a missing one fails the build with its name.
#let need(d, key) = {
  if key not in d { panic("ncmb-adversary-complaint: missing required field `" + key + "`") }
  d.at(key)
}

/// Inline markdown with footnotes: each `[^n]` marker becomes a footnote whose text is `notes.n` from the
/// frontmatter. Chunks are rendered one at a time, so a definition cannot live in the body.
#let with-notes(t, notes) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^(\\d+)\\]")) {
    out += inl(t.slice(pos, m.start))
    let k = m.captures.at(0)
    if k not in notes { panic("ncmb-adversary-complaint: footnote [^" + k + "] has no text under `footnotes:`") }
    out += footnote(inl(notes.at(k)))
    pos = m.end
  }
  out + inl(t.slice(pos))
}

// ---------------------------------------------------------------------------
// Caption (Form 416D: court, parties, case numbers, title of the paper)
// ---------------------------------------------------------------------------

/// A caption row is a string, or a dictionary {t: text, a: "l" | "c" | "r"} for its alignment in the column.
#let cap-cell(item) = {
  let t = if type(item) == dictionary { item.t } else { item }
  let a = if type(item) == dictionary { item.at("a", default: "l") } else { "l" }
  let al = if a == "c" { center } else if a == "r" { right } else { left }
  block(width: 100%, height: cap-row, align(al, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    inl(t)
  }))
}

/// The caption: left column (parties), a ")" column in every row, right column (case numbers). The number of rows
/// is the longer column; a shorter column is padded with empty rows, so the ")" marks run the full height.
#let caption(meta) = {
  let cap = need(meta, "caption")
  let left = need(cap, "left")
  let right = cap.at("right", default: ())
  let n = calc.max(left.len(), right.len())
  block(width: 100%, stroke: (bottom: 0.75pt), inset: (bottom: 9pt), {
    stack(dir: ttb, ..range(n).map(i => grid(
      columns: (caption-left, caption-paren, 1fr),
      cap-cell(if i < left.len() { left.at(i) } else { "" }),
      block(height: cap-row, width: 100%, align(center, [)])),
      pad(left: 0.25in, cap-cell(if i < right.len() { right.at(i) } else { "" })),
    )))
  })
}

#let cover(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, stack(dir: ttb, spacing: single-leading, ..need(meta, "court").map(l => [#l])))
  v(pitch)
  caption(meta)
  v(pitch * 0.5)
  align(center, strong(need(meta, "title")))
  v(pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, lists, block quotes
// ---------------------------------------------------------------------------

#let para-counter = counter("allegation")

/// Each blank-line-separated chunk of markdown is one unit. A heading is kept with the unit after it.
/// A chunk starting with WHEREFORE is the unnumbered prayer lead-in; a chunk starting with a list marker is a
/// list (lettered A., B., ...); a chunk starting with ">" is a block quotation; every other chunk is a numbered
/// paragraph. Numbering is applied per chunk, not with a `show par` rule (a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15).
#let allegations(body, notes) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []  // a heading, held until the unit it introduces is placed
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      let unit = if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
        // A list: lettered A., B., ... (prayer) or bulleted with the marker left out, as (i), (ii), ... (sub-items).
        {
          set par(leading: body-leading)
          cmarker.render(t, raw-typst: false, smart-punctuation: true)
          v(body-leading)
        }
      } else if t.starts-with(">") {
        cmarker.render(t, raw-typst: false, smart-punctuation: true)
      } else if t.starts-with("WHEREFORE") {
        block(width: 100%, { set par(leading: body-leading, first-line-indent: 0pt); h(para-indent); inl(t) })
      } else {
        para-counter.step()
        block(width: 100%, { set par(leading: body-leading, first-line-indent: 0pt); context [#h(para-indent)#(para-counter.display()).#h(number-gap)#with-notes(t, notes)] })
      }
      // The heading is sticky, so it is never left at the foot of a page without its first line.
      let out = { pending; unit }
      pending = []
      out
    }
  }
  pending
}

// ---------------------------------------------------------------------------
// Signature block (LR 9011-4: state bar number, telephone and email on every paper)
// ---------------------------------------------------------------------------

#let lines(items) = stack(dir: ttb, spacing: single-leading, ..items.map(l => inl(l)))

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let signers = need(sig, "signers")
  block(breakable: false, above: pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    inl(need(sig, "dated"))
    v(pitch * 0.5)
    pad(left: signature-indent, {
      lines(need(sig, "firm"))
      v(pitch * 0.5)
      "/s/ " + need(sig, "signed_by")
      v(pitch * 0.5)
      for s in signers {
        lines((
          need(s, "name"),
          "N.C. State Bar No. " + need(s, "bar"),
          "Email: " + need(s, "email"),
        ))
        v(pitch * 0.5)
      }
      lines(need(sig, "address"))
      linebreak()
      "Telephone: " + need(sig, "phone")
      linebreak()
      lines(need(sig, "role"))
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ncmb-adversary-complaint(meta, body) = {
  for k in ("court", "caption", "title", "lead_in", "signature") { let _ = need(meta, k) }

  set document(title: need(meta, "title"), author: need(need(meta, "signature"), "signed_by"))
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer: context align(center, text(size: 11pt, counter(page).display("1"))),
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    // A 1.15em line box (a word-processor single line); Liberation Serif's ascender-descender box is only 0.909em,
    // so single-spaced lines with no gap would touch.
    top-edge: 0.9em, bottom-edge: -0.25em,
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.5in, spacing: body-leading)
  set list(marker: [], indent: 1in, body-indent: 0pt, spacing: body-leading)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings: level 1 centered bold caps; level 2 centered bold; level 3 bold italic at the margin.
  show heading.where(level: 1): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    text(size: type-size, align(center, strong(upper(it.body)))))
  show heading.where(level: 2): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    text(size: type-size, align(center, strong(it.body))))
  show heading.where(level: 3): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    text(size: type-size, strong(emph(it.body))))

  // Block quotations: single-spaced, indented half an inch on each side.
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, block(width: 100%, above: body-leading, below: body-leading, {
    set par(leading: single-leading, first-line-indent: 0pt)
    it.body
  }))

  cover(meta)

  // The lead-in is an unnumbered paragraph (it states the parties and that the pleading is made).
  block(width: 100%, { set par(leading: body-leading, first-line-indent: 0pt); h(para-indent); inl(need(meta, "lead_in")) })

  allegations(body, need(meta, "footnotes"))

  signature-block(meta)
}
