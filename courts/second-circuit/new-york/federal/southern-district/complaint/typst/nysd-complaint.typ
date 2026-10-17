// U.S. District Court, Southern District of New York: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (NYSD-...) refer to ../README.md, which quotes the
// rules: Fed. R. Civ. P. 8(a), 10(a)-(c); S.D.N.Y. Joint Local Civil Rules (Jan. 2, 2026) 7.1(b)
// (typeface, margins, spacing for all papers). No case-specific text, no coordinates measured off the
// exemplar, no forced line breaks. The body is markdown rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // NYSD-FORM-002: the joint rules name no typeface; Times New Roman substitute per docs/FONTS.md. See README gaps.
#let type-size = 12pt                    // NYSD-FORM-002: 12-point type or larger (Local Civ. R. 7.1(b)(1)).
#let body-leading = 1.091em              // NYSD-FORM-003: double-spaced (Local Civ. R. 7.1(b)(3)); text edges are ascender/descender (below), a 0.909em
                                         // line box in Liberation Serif, so 0.909em + 1.091em = 2.0em = a 24 pt pitch at 12 pt, also between paragraphs.
#let single-leading = 0.241em            // 0.909em + 0.241em = 1.15em (13.8 pt), single spacing: caption, headings, block quotations, footnotes, signature block: single-spaced where the rule allows.
#let line-pitch = 24pt                   // one double-spaced line; used for spacing around headings and the caption.
#let margin = 1in                        // NYSD-FORM-004: at least one-inch margins on all sides (Local Civ. R. 7.1(b)(2)).
#let para-indent = 0.5in                 // first-line indent of numbered paragraphs.
#let number-gap = 0.3in                  // gap between a paragraph number and its text.
#let list-indent = 0.5in                 // lettered items (prayer for relief, class questions).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics, footnote references) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nysd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nysd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Cover: court title and caption (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

/// The caption: the parties on the left (closed by a rule on the right and bottom), the file number,
/// judge, legends and title on the right. Rule 10(a): court name, title naming all the parties, file
/// number, and the Rule 7(a) designation (the title "COMPLAINT").
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      for n in side.names { inl(n); parbreak() }
      pad(left: 1.8in, inl(side.designation))
      if i < sides.len() - 1 { v(line-pitch * 0.5); align(center)[v.]; v(line-pitch * 0.5) }
    }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    if meta.at("electronic", default: false) {
      [ELECTRONICALLY FILED]
      parbreak()
    }
    [No. #need(meta, "case_number")]
    if "judge" in meta { linebreak(); inl(meta.judge) }
    v(line-pitch * 0.5)
    for l in meta.at("legends", default: ()) { strong(upper(inl(l))); linebreak() }
    v(line-pitch * 0.5)
    strong(upper(inl(need(meta, "title"))))
    for l in meta.at("legends-after", default: ()) { linebreak(); strong(upper(inl(l))) }
  }
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, left),
    pad(left: 1.2em, top: 0.3em, right),
  )
}

#let cover(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(need(meta, "court").map(l => [#l]).join(linebreak()))))
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs (Rule 10(b)), lettered lists, block quotations
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one unit of the body:
///  - a heading ("#", "##", "###") is held and printed with the unit after it; the heading style is sticky,
///    so a heading never ends a page;
///  - a list is rendered with lettered items (a), (b), ... (each item its own block);
///  - a block quotation (">") is indented and single-spaced, not numbered;
///  - a footnote definition ("[^label]: text") is not printed here: it is attached to each chunk that refers to it;
///  - a paragraph starting "WHEREFORE" or under the "JURY TRIAL" heading is not numbered;
///  - any other paragraph is numbered 1, 2, ... (Fed. R. Civ. P. 10(b)).
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // cmarker renders a chunk on its own, so a footnote reference cannot see a definition in another chunk.
  let notes = body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:.*$"))
  let with-notes(t) = t + notes
    .filter(n => t.contains("[^" + n.captures.at(0) + "]"))
    .map(n => "\n\n" + n.text).join("")
  let pending = []
  let unnumbered-section = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") { continue }
    t = with-notes(t)
    if t.starts-with("#") {
      unnumbered-section = t.contains("JURY TRIAL")
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      { pending; items }
      pending = []
    } else {
      let piece = if t.starts-with(">") {
        // A block quotation: indented, single-spaced, not numbered.
        block(width: 100%, inset: (left: 0.75in, right: 0.5in), above: 0pt, below: line-pitch * 0.5, {
          set par(leading: single-leading, first-line-indent: 0pt, justify: false)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        })
      } else if t.starts-with("WHEREFORE") or unnumbered-section {
        block(width: 100%, [#h(para-indent)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)])
      } else {
        para-counter.step()
        block(width: 100%, context [#h(para-indent)#(para-counter.display()).#h(number-gap)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)])
      }
      { pending; piece }
      pending = []
    }
  }
  pending
}

// ---------------------------------------------------------------------------
// Signature block (no local rule cites the form; the exemplar's form is used: see ../README.md)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      v(line-pitch)
      [By: /s/ #inl(sig.signer)]
      linebreak()
      inl(sig.signer)
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let nysd-complaint(meta, md) = {
  for k in ("court", "case_number", "caption", "title", "signature", "date") {
    let _ = need(meta, k)
  }
  let para-counter = counter("allegation")

  set page(paper: "us-letter", margin: margin, numbering: "1", number-align: center + top)
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: list-indent, body-indent: 0.4in, spacing: body-leading)
  set list(indent: list-indent, body-indent: 0.4in, spacing: body-leading)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, separator: line(length: 30%, stroke: 0.5pt))
  // The note number is set in its own column so it is never run into the note text.
  show footnote.entry: it => {
    let n = counter(footnote).at(it.note.location()).first()
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em, justify: false)
    grid(columns: (auto, 1fr), column-gutter: 0.3em, super[#n], it.note.body)
  }

  // Headings are single-spaced (the rule allows it) and sticky. Level 1: centered caps; level 2:
  // centered bold; level 3: bold italic at the left.
  show heading.where(level: 1): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true, {
    set par(leading: single-leading)
    align(center, strong(upper(it.body)))
  })
  show heading.where(level: 2): it => block(width: 100%, above: 0pt, below: line-pitch * 0.5, sticky: true, {
    set par(leading: single-leading)
    align(center, strong(it.body))
  })
  show heading.where(level: 3): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true, {
    set par(leading: single-leading)
    strong(emph(it.body))
  })

  cover(meta)

  if "lead_in" in meta {
    block(width: 100%, above: 0pt, below: 0pt, {
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(md, para-counter)

  signature-block(meta)
}
