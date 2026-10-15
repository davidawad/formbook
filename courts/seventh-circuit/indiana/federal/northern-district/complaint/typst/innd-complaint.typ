// Complaint for the U.S. District Court for the Northern District of Indiana (innd).
// Rules: N.D. Ind. L.R. 5-4(a) (8.5 x 11 pages, 1-inch margins, 12-point body and 10-point footnotes, double
// spacing, consecutive page numbers, a title on the first page, the filer block); Fed. R. Civ. P. 10(a)
// (caption: court, title, file number) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"      // vendored in fonts/; see README "Known gaps"
#let type-size = 12pt                 // L.R. 5-4(a)(4): at least 12-point type in the body
#let note-size = 10pt                 // L.R. 5-4(a)(4): at least 10-point type in footnotes
#let pitch = 27.6pt                   // L.R. 5-4(a)(5): double spaced; two single lines of 12 pt type (13.8 pt each)
#let single-pitch = 13.8pt            // single spacing: caption, counsel, signature blocks, headings inside a block
#let margin = 1in                     // L.R. 5-4(a)(3): at least 1-inch margins
#let page-w = 8.5in                   // L.R. 5-4(a)(2)
#let page-h = 11in
#let para-indent = 0.5in              // first-line indent of numbered paragraphs
#let caption-left = 3.2in             // width of the party column of the caption
#let body-leading = 1.65em            // baseline pitch 27.6 pt at 12 pt: EB Garamond's line box is 0.65em (README.md)
#let single-leading = 0.5em           // baseline pitch 13.8 pt at 12 pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("innd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names with *italics*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Footnote definitions (`[^n]: text` chunks) by number. cmarker drops footnotes, so they are
/// rendered by `rich()` as real typst footnotes.
#let notes-of(chunks) = {
  let notes = (:)
  for c in chunks {
    let m = c.match(regex("^\\[\\^(\\d+)\\]:\\s*([\\s\\S]*)$"))
    if m != none { notes.insert(m.captures.at(0), m.captures.at(1)) }
  }
  notes
}

/// A markdown segment between footnote markers. cmarker trims spaces at its edges, so a space that sits
/// next to a marker is put back as a typst space.
#let seg(s) = {
  let lead = if s.starts-with(" ") { [ ] } else { [] }
  let trail = if s.ends-with(" ") { [ ] } else { [] }
  lead + inl(s) + trail
}

/// A paragraph's markdown with its `[^n]` references turned into typst footnotes.
#let rich(t, notes) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^(\\d+)\\]")) {
    if m.start > pos { out += seg(t.slice(pos, m.start)) }
    out += footnote(inl(notes.at(m.captures.at(0))))
    pos = m.end
  }
  if pos < t.len() { out += seg(t.slice(pos)) }
  out
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced row per item; an empty item is a blank row.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if i == "" { [ ] } else { [#i] }))
}

#let cover(meta) = {
  // Court lines and division in one stack, so the division gets the same single spacing as the court lines.
  let lines = meta.court.map(l => text(weight: "bold", l))
  if "division" in meta { lines.push(text(weight: "bold", upper(meta.division))) }
  stack(dir: ttb, spacing: single-leading, ..lines.map(l => align(center, l)))
  v(pitch)
}

/// The party column: each party's names, then its designation (indented); "v." between the parties.
#let party-stack(parties) = {
  let rows = ()
  for (k, p) in parties.enumerate() {
    if k > 0 { rows += (("", 0pt), ("v.", 0pt), ("", 0pt)) }
    for n in p.names { rows.push((n, 0pt)) }
    rows.push((p.designation, 1.2in))
  }
  set par(leading: single-leading, spacing: 0pt)
  stack(dir: ttb, spacing: single-leading, ..rows.map(r => pad(left: r.at(1), [#r.at(0)])))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.3in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.12in, bottom: 0.1in),
    party-stack(meta.caption.parties)),
  block(inset: (top: 0pt), {
    set par(leading: single-leading, spacing: 0pt)
    [Case No.: #meta.case_number]
    if "jury_demand" in meta and meta.jury_demand {
      v(single-pitch)
      text(weight: "bold", "JURY TRIAL DEMANDED")
    }
  }),
)

#let paper-title(meta) = block(width: 100%, above: pitch, below: pitch,
  align(center, text(weight: "bold", upper(meta.title))))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), lettered subparagraphs, headings
// ---------------------------------------------------------------------------

/// Blank-line-separated markdown chunks of the body; footnote definitions are removed (see `notes-of`).
#let body-chunks(body) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  all.filter(c => not c.starts-with("[^"))
}

/// The body. Each chunk that is neither a heading nor a list is one numbered paragraph; numbers are
/// counted here in code, so the sample never carries them. Two markers keep a paragraph unnumbered:
/// a leading "^ " (lead-in, jury demand), and a capital letter and period ("A. ") for prayer items,
/// which keep their letter.
/// `tail` (the signature block) is kept on one page with the last chunk of the body: a signature
/// never stands alone on a page.
#let body-blocks(body, notes, tail) = {
  let num = 0
  let out = []
  let chunks = body-chunks(body)
  for (i, t) in chunks.enumerate() {
    let piece = if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages. Items are lettered (a., b., ...) by the enum rule set in the entry point.
      block(width: 100%, above: 0pt, below: body-leading,
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
    } else if t.starts-with("^ ") {
      block(width: 100%, above: 0pt, below: body-leading,
        [#h(para-indent)#rich(t.slice(2), notes)])
    } else if t.starts-with(regex("^[A-Z]\\.[ \\t]")) {
      let m = t.match(regex("^([A-Z])\\.[ \\t]+([\\s\\S]*)$"))
      block(width: 100%, above: 0pt, below: body-leading,
        [#h(para-indent)#(m.captures.at(0) + ".")#h(0.3in)#rich(m.captures.at(1), notes)])
    } else {
      num += 1
      block(width: 100%, above: 0pt, below: body-leading,
        [#h(para-indent)#(str(num) + ".")#h(0.3in)#rich(t, notes)])
    }
    if i == chunks.len() - 1 {
      out += block(width: 100%, breakable: false, { piece; tail })
    } else {
      out += piece
    }
  }
  out
}

#let signature-block(meta) = block(breakable: false, width: 100%, above: pitch, {
  let sig = meta.signature
  grid(
    columns: (3in, 1fr),
    column-gutter: 0.2in,
    [Dated: #sig.dated],
    {
      set par(leading: single-leading, spacing: 0pt)
      [Respectfully submitted,]
      v(pitch)
      if "party" in sig { [#upper(sig.party)] ; v(single-pitch) }
      [By: #sig.by]
      if "role" in sig { linebreak() ; [#sig.role] }
      v(pitch)
      line-stack(sig.counsel)
    },
  )
})

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let innd-complaint(meta, body) = {
  let all-chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let notes = notes-of(all-chunks)

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.5in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.5in, spacing: body-leading)

  // Headings: level 1 centered caps; level 2 centered bold (COUNT I); level 3 bold, left (sub-section).
  show heading.where(level: 1): it => block(width: 100%, above: pitch, below: body-leading, align(center,
    text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: pitch, below: body-leading, align(center,
    text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: pitch, below: body-leading,
    text(weight: "bold", it.body))

  // Block quotations are single spaced (L.R. 5-4(a)(5): quoted material is excepted from double spacing).
  show quote.where(block: true): it => block(width: 100%, inset: (left: 0.5in, right: 0.5in), above: pitch, below: pitch, {
    set par(leading: single-leading, spacing: 0pt)
    it.body
  })

  // Footnotes at 10 pt, single spaced (L.R. 5-4(a)(4)).
  show footnote.entry: set text(size: note-size)
  show footnote.entry: set par(leading: single-leading)

  cover(meta)
  caption(meta)
  paper-title(meta)
  body-blocks(body, notes, signature-block(meta))
}
