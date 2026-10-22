// U.S. Bankruptcy Court, Middle District of North Carolina: adversary complaint (Fed. R. Bankr. P. 7001 et seq.).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; the caption substantially conforms to Official
// Form 416D), 7008(a) (jurisdiction statement and consent to final orders), Fed. R. Civ. P. 10(b) (numbered
// paragraphs); Local Rule 9011-4 (signature block: state bar number, telephone, email). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // the local rules set no typeface; Times New Roman, the house standard (David's 2026-10-17 ruling: template_face in data/exemplar-fonts.json), on typst and docx alike
#let type-size = 12pt                   // FRBP 9004(a): "clearly legible"; no local size rule, so the 12 pt convention (docs/FONTS.md)
#let page-margin = 1in
#let para-indent = 0.5in                // first-line indent of paragraphs; the paragraph number's box after it
#let item-indent = 0.5in                // prayer items: the letter at the indent, in a box of this width
#let sub-indent = 1in                   // the (i), (ii) sub-items of a paragraph
#let quote-inset = 0.5in                // block quotations: indented half an inch on each side
#let caption-left = 3.2in               // party column of the caption
#let caption-paren = 0.35in             // the ")" column
#let caption-inset = 0.25in             // the case numbers start this far right of the ")" column
#let signature-indent = 3.25in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // the double-spaced line pitch of the filed exemplar
#let pitch-single = 13.8pt              // single spacing: 1.15 x the type size (court lines, title, headings, quotations, signature, footnotes)
#let cap-row = 16pt                     // one caption row; the ")" column aligns row by row
#let gap-half = 12pt                    // half a double line: around the title, headings, quotations; in the signature block
#let caption-rule-gap = 9pt             // from the last caption row to the rule under the caption
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text 140 twips after)
#let note-clearance = 9pt               // between the body and the footnote separator: LibreOffice fits a body line whose box ends 16.8 pt
                                        // above the first note line's box (measured on the motion brief: typst breaks alike at 9 pt, not at 10 pt)

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
/// frontmatter. cmarker trims a piece's outer spaces: a space next to a marker is put back.
#let with-notes(t, notes) = {
  let piece(s) = [#if s.starts-with(" ") [ ]#inl(s)#if s.ends-with(" ") [ ]]
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^(\\d+)\\]")) {
    if m.start > pos { out += piece(t.slice(pos, m.start)) }
    let k = m.captures.at(0)
    if k not in notes { panic("ncmb-adversary-complaint: footnote [^" + k + "] has no text under `footnotes:`") }
    out += footnote(inl(notes.at(k)))
    pos = m.end
  }
  if pos < t.len() { out += piece(t.slice(pos)) }
  out
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, pitch: pitch-single, body) = block(width: 100%, above: above,
  below: below, pad(left: left, {
    set text(..edges(pitch))
    set par(first-line-indent: 0pt)
    body
  }))

// ---------------------------------------------------------------------------
// Caption (Form 416D: court, parties, case numbers, title of the paper)
// ---------------------------------------------------------------------------

/// A caption row is a string, or a dictionary {t: text, a: "l" | "c" | "r"} for its alignment in the column.
#let cap-cell(item) = {
  let t = if type(item) == dictionary { item.t } else { item }
  let a = if type(item) == dictionary { item.at("a", default: "l") } else { "l" }
  align(if a == "c" { center } else if a == "r" { right } else { left }, inl(t))
}

/// The caption: one row per line, the left column (parties), a ")" column in every row, the right column (case
/// numbers). The number of rows is the longer column; the shorter one is padded with empty rows, so the ")" marks
/// run the full height. A rule closes it.
#let caption(meta) = {
  let cap = need(meta, "caption")
  let left = need(cap, "left")
  let right = cap.at("right", default: ())
  let n = calc.max(left.len(), right.len())
  block(width: 100%, above: pitch-double, below: 0pt, {
    set text(..edges(cap-row))
    set par(first-line-indent: 0pt)
    grid(
      columns: (caption-left, caption-paren, 1fr),
      ..range(n).map(i => (
        cap-cell(if i < left.len() { left.at(i) } else { "" }),
        align(center, [)]),
        pad(left: caption-inset, cap-cell(if i < right.len() { right.at(i) } else { "" })),
      )).flatten(),
    )
  })
  block(width: 100%, height: caption-rule-gap, above: 0pt, below: 0pt, stroke: (bottom: 0.75pt))
}

#let cover(meta) = {
  for l in need(meta, "court") { line-block(align(center, inl(l))) }
  caption(meta)
  line-block(above: gap-half, below: gap-half, align(center, strong(inl(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, lists, block quotes
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch, first line indented: unnumbered, or numbered (the number in a box of the
/// paragraph indent after the first-line indent, then the text). A bare paragraph, not one inside a block: typst
/// then carries a last line whose footnote does not fit to the next page with its note, as Word does (inside a
/// block it keeps the line and moves the note on alone).
#let body-par(num, content) = par(first-line-indent: (amount: para-indent, all: true),
  if num == none { content } else { [#box(width: para-indent, [#num.])#content] })

/// Each blank-line-separated chunk of markdown is one unit. A chunk starting with WHEREFORE is the unnumbered
/// prayer lead-in; a numbered list is the prayer, lettered A., B., ...; a bulleted list holds a paragraph's
/// sub-items, printed with their own (i), (ii) labels and no bullet; a chunk starting with ">" is a block
/// quotation; every other chunk is a numbered paragraph. Numbering is applied per chunk, not with a `show par`
/// rule (a show rule that re-wraps paragraph content recurses without end in typst 0.15).
#let allegations(body, notes) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      let items = t.split(regex("(?m)^\\d+\\.[ \\t]+")).filter(s => s.trim() != "")
      for (i, it) in items.enumerate() {
        block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent,
          par(hanging-indent: item-indent, first-line-indent: 0pt,
            [#box(width: item-indent, numbering("A.", i + 1))#with-notes(it.trim(), notes)])))
      }
    } else if t.starts-with(regex("^[-*+][ \\t]")) {
      for it in t.split(regex("(?m)^[-*+][ \\t]+")).filter(s => s.trim() != "") {
        block(width: 100%, above: 0pt, below: 0pt, pad(left: sub-indent,
          par(first-line-indent: 0pt, with-notes(it.trim(), notes))))
      }
    } else if t.starts-with(">") {
      let ps = t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).filter(s => s.trim() != "")
      for q in ps { line-block(above: gap-half, below: gap-half, pad(x: quote-inset, with-notes(q.trim(), notes))) }
    } else if t.starts-with("WHEREFORE") {
      body-par(none, with-notes(t, notes))
    } else {
      n += 1
      body-par(n, with-notes(t, notes))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (LR 9011-4: state bar number, telephone and email on every paper)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let group(above, items) = for (i, l) in items.enumerate() {
    line-block(above: if i == 0 { above } else { 0pt }, left: signature-indent, inl(l))
  }
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    line-block(inl(need(sig, "dated")))
    group(gap-half, need(sig, "firm"))
    group(gap-half, ("/s/ " + need(sig, "signed_by"),))
    for s in need(sig, "signers") {
      group(gap-half, (need(s, "name"), "N.C. State Bar No. " + need(s, "bar"), "Email: " + need(s, "email")))
    }
    group(gap-half, need(sig, "address") + ("Telephone: " + need(sig, "phone"),) + need(sig, "role"))
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ncmb-adversary-complaint(meta, body) = {
  for k in ("court", "caption", "title", "lead_in", "signature") { let _ = need(meta, k) }

  set document(title: need(meta, "title"), author: need(need(meta, "signature"), "signed_by"))
  // The page number centered at the foot of every page, in a single-spaced line box, where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("§§ 157"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Footnotes: the type size, single-spaced; the mark, a space, the note.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)   // the entry does not inherit the body's leading
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings: single-spaced, half a double line above and below, kept with the text after them; level 1 centered
  // bold capitals, level 2 centered bold, level 3 bold italic at the margin.
  show heading: it => block(sticky: true, width: 100%, above: gap-half, below: gap-half, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 {
      align(center, strong(it.body))
    } else { strong(emph(it.body)) }
  })

  cover(meta)
  // The lead-in is an unnumbered paragraph (it states the parties and that the pleading is made).
  body-par(none, with-notes(need(meta, "lead_in"), need(meta, "footnotes")))
  allegations(body, need(meta, "footnotes"))
  signature-block(meta)
}
