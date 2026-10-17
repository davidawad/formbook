// Motion to dismiss with incorporated memorandum of law, for the United States District Court for the
// District of Maine (med). Rules: D. Me. Local Rule 7(a) (every motion incorporates a memorandum of law),
// 7(d)(1) (20-page limit for a memorandum supporting a motion to dismiss), 10(a) (caption and title), 10(b)
// (form: 12-point or larger type, footnotes 10-point or larger; text double-spaced; 8 1/2 x 11 inch paper; page
// numbers at the bottom; 1-inch margins). Fed. R. Civ. P. 7(b), 10(a), 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no face named by D. Me. LR 10(b)(1), so docs/FONTS.md "No face named": Times New Roman substitute (README.md)
#let type-size = 12pt                   // LR 10(b)(1): 12-point or larger; 12 pt, as the filed exemplars (README.md)
#let footnote-size = 11pt               // LR 10(b)(1): footnotes 10-point or larger
#let page-w = 8.5in                     // LR 10(b)(3): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // LR 10(b)(5): 1-inch margins on all four sides
#let body-leading = 27.6pt - 0.655em     // LR 10(b)(2): double-spaced: 27.6 pt baseline pitch (Word double spacing for 12 pt Times; the filed exemplars measure 27.6 pt) less Liberation Serif's 0.655 em line box
#let single-leading = 0.5em             // caption, headings, block quotes, footnotes, signature: single-spaced
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // width of the party block of the caption
#let designation-indent = 1.5in         // "Defendants." set in from the party names

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("med-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown to content (names, paragraphs, headings, footnotes; smart quotes).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LR 10(a); FRCP 10(a))
// ---------------------------------------------------------------------------

/// The party column: each party's names, then its designation set in from the names; "v." between parties.
#let party-block(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  let items = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { items.push([v.]) }
    for n in p.names { items.push(md(n)) }
    items.push(block(width: 100%, inset: (left: designation-indent), md(p.designation)))
  }
  stack(dir: ttb, spacing: single-leading, ..items)
}

/// Party column closed by a rule at its right and bottom; the case number at right.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.3in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 12pt, bottom: 8pt), party-block(meta)),
  align(horizon, block(inset: (left: 0.1in), {
    if meta.case_number == "" [Civil Action No. #box(width: 1.6in, height: 0.9em, stroke: (bottom: 0.6pt))]
    else [Civil Action No. #meta.case_number]
  })),
)

/// The court's name, two centered bold lines (LR 10(a): the caption names the court).
#let court-title() = stack(dir: ttb, spacing: single-leading,
  align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")),
  align(center, text(weight: "bold", "DISTRICT OF MAINE")),
)

/// The title of the motion, under the caption (LR 10(a)).
#let title-block(meta) = align(center, text(weight: "bold", upper(meta.title)))

#let cover(meta) = {
  court-title()
  v(body-leading)
  caption(meta)
  v(body-leading)
  title-block(meta)
}

// ---------------------------------------------------------------------------
// Signature, certificate, body
// ---------------------------------------------------------------------------

/// Signature block: the date, then the signing attorney's /s/ line and the lines of the block.
#let signature-block(meta) = block(width: 100%, sticky: true, {
  set par(leading: single-leading, spacing: 0pt)
  grid(
    columns: (2.8in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    stack(dir: ttb, spacing: single-leading,
      [/s/ #meta.signature.signer],
      ..meta.signature.lines.map(l => [#l]),
    ),
  )
})

/// Walk the markdown body. Blank lines separate chunks. `#` headings are styled by show rules below;
/// `>` block quotes are single-spaced; every other paragraph is a double-spaced body paragraph with a
/// first-line indent. A briefing paragraph is not numbered (FRCP 10(b) numbers claims in a pleading only).
#let body-pieces(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote definitions (`[^n]: text`) are not paragraphs: they are handed to cmarker with the chunk that
  // refers to them, so each reference resolves to its text. A definition chunk is not printed itself.
  let notes = chunks.map(c => c.trim()).filter(t => t.starts-with("[^")).join("\n\n")
  let out = ()
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") {
      continue
    } else if t.starts-with("#") {
      out.push(md(t))
    } else if t.starts-with(">") {
      out.push(block(width: 100%, inset: (left: 0.5in, right: 0.5in), {
        set par(leading: single-leading)
        md(t)
      }))
    } else {
      out.push({
        set par(leading: body-leading)
        [#h(para-indent)#md(if t.contains("[^") { t + "\n\n" + notes } else { t })]
      })
    }
  }
  out
}

#let med-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // LR 10(b)(4): each page numbered at the bottom.
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered bold section (INTRODUCTION, ARGUMENT, CONCLUSION); level 2 a bold
  // section heading at the left (I., II., with the statement of the argument); level 3 an underlined
  // sub-heading (i., ii.), as in the filing. Each heading is kept with the text after it.
  show heading.where(level: 1): it => block(width: 100%, above: single-leading * 2, below: single-leading * 2, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: single-leading * 2, below: single-leading * 2, sticky: true,
    par(hanging-indent: 0.5in, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: single-leading * 2, below: single-leading * 2, sticky: true,
    par(hanging-indent: 0.5in, underline(text(size: type-size, it.body))))

  // Footnotes: 11-point, single-spaced, above a short rule (LR 10(b)(1), (2)).
  set footnote.entry(separator: line(length: 2.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading, spacing: 0pt)

  cover(meta)
  v(body-leading)
  let pieces = body-pieces(body)
  let last = pieces.pop()
  for p in pieces { p }
  // The last paragraph stays on the page with the signature, so a signature block never stands alone.
  block(width: 100%, breakable: false, {
    last
    v(body-leading)
    signature-block(meta)
  })
  // A certificate of service, when the sample has one (FRCP 5(d)(1)(B): none is needed for CM/ECF service).
  if "certificate" in meta and meta.certificate != none {
    v(body-leading)
    block(width: 100%, breakable: false, {
      align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
      v(single-leading * 2)
      set par(leading: body-leading)
      [#h(para-indent)#md(meta.certificate)]
      v(body-leading)
      signature-block(meta)
    })
  }
}
