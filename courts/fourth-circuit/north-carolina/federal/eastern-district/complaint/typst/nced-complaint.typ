// Complaint for the U.S. District Court for the Eastern District of North Carolina (nced).
// Rules: Local Civil Rule 10.1 (letter paper, double-spaced, at least 11-point type, one-inch margins, court
// and division, case number after the initial filing, caption, title, attorney block, date, signature with the
// typed name, sequential page numbers); Fed. R. Civ. P. 8(a), 10(a) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 10.1(a) names no face; Times New Roman, the house standard (docs/FONTS.md; template_face in data/exemplar-fonts.json)
#let type-size = 12pt                   // LR 10.1(a): at least 11 point (footnotes are typed matter too)
#let margin = 1in                       // LR 10.1(a): one inch on all sides
#let para-indent = 0.5in                // first-line indent of text paragraphs; the allegation number's box after it
#let item-indent = 0.5in                // prayer items: the letter at the indent, in a box of this width
#let caption-left = 3.4in               // party column of the caption
#let caption-paren = 0.25in             // column of ")" marks, one per caption line
#let title-gap = 0.25in                 // space between the ")" column and the title block
#let sig-indent = 3in                   // the attorney block

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: court title, caption, signature block, footnotes
#let pitch-double = 2 * pitch-single    // LR 10.1(a): double-spaced
#let gap = pitch-single                 // a blank single line: between the parts of the cover and the signature
#let heading-gap = pitch-single         // above and below a heading
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text 140 twips after)
#let note-clearance = 12.6pt            // between the body and the footnote separator (LibreOffice's footnote area)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nced-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, bold, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown: headings are level 1 to 3 (h1-level 1 keeps "#" a top-level heading).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

// ---------------------------------------------------------------------------
// Cover: court and division (LR 10.1(b)), case number (LR 10.1(c)), caption (LR 10.1(d)), title (LR 10.1(e))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  for l in ("IN THE UNITED STATES DISTRICT COURT", "FOR THE EASTERN DISTRICT OF NORTH CAROLINA",
    upper(meta.division) + " DIVISION") { line-block(align(center, l)) }
}

#let case-number-line(meta) = {
  // LR 10.1(c): the case number is assigned by the clerk; an initial filing leaves it blank.
  let num = meta.at("case_number", default: none)
  line-block(above: gap, align(center, if num == none { [No. #("_" * 14)] } else { [No. #num] }))
}

/// One caption line. The line is a list entry: `"text"`, or `{t: "text", i: indent in half inches}`.
#let caption-item(x) = if type(x) == str { (t: x, i: 0) } else { (t: x.at("t", default: ""), i: x.at("i", default: 0)) }

#let caption-cell(r) = context {
  let c = [#h(r.i * 0.5in)#r.t]
  assert(measure(c).width <= caption-left, message: "nced-complaint: a caption line must fit on one line: " + r.t)
  c
}

/// The title block, to the right of the ")" column: the paper's title and any jury legend, a blank line apart.
#let title-block(meta) = {
  text(weight: "bold", inl(meta.brief_title))
  if "jury_demand" in meta and meta.jury_demand {
    block(above: gap, below: 0pt, text(weight: "bold", "(JURY TRIAL DEMANDED)"))
  }
}

/// One single-spaced row per caption line, a ")" closing each; the title beside them, centered on them.
#let caption(meta) = {
  let rows = meta.caption.lines.map(caption-item)
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(width: 100%, above: gap, below: 0pt, grid(
    columns: (caption-left, caption-paren, 1fr),
    rows: (pitch-single,) * rows.len(),
    grid.cell(x: 2, y: 0, rowspan: rows.len(), align(horizon, pad(left: title-gap, title-block(meta)))),
    ..rows.map(r => (caption-cell(r), [)])).flatten(),
  ))
}

#let cover(meta) = {
  court-title(meta)
  case-number-line(meta)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch, first line indented: unnumbered, or numbered (the number in a box of the
/// paragraph indent after the first-line indent, then the text).
#let body-par(num, content, above: 0pt) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// The prayer's items (a markdown list), lettered A., B., ...: the letter at the item indent in a box of its
/// width, the text hanging after it.
#let prayer-items(t) = {
  let items = t.split(regex("(?m)^\\d+\\.[ \\t]+")).filter(s => s.trim() != "")
  for (i, it) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent,
      par(hanging-indent: item-indent, first-line-indent: 0pt,
        [#box(width: item-indent, numbering("A.", i + 1))#inl(it.trim().replace(regex("\\s*\\n\\s*"), " "))])))
  }
}

/// A paragraph's text with its footnote references (`[^key]`) as typst footnotes: cmarker does not convert
/// markdown footnotes, so the definitions are collected and set at their references.
#let with-notes(t, notes) = {
  // cmarker trims a piece's outer spaces: a space next to a footnote reference is put back.
  let piece(s) = [#if s.starts-with(" ") [ ]#inl(s)#if s.ends-with(" ") [ ]]
  let out = []
  let last = 0
  for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
    if r.start > last { out += piece(t.slice(last, r.start)) }
    out += footnote(inl(notes.at(r.captures.at(0))))
    last = r.end
  }
  if last < t.len() { out += piece(t.slice(last)) }
  out
}

/// Numbered allegations (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is
/// neither a heading, a list nor a WHEREFORE clause is one numbered paragraph. Headings and lists are not
/// numbered; the prayer's WHEREFORE clause is not numbered (it is not an allegation).
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let notes = (:)
  for c in chunks {
    let m = c.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*"))
    if m != none { notes.insert(m.captures.at(0), c.slice(m.end)) }
  }
  let n = 0
  for t in chunks.filter(c => not c.starts-with("[^")) {
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      prayer-items(t)
    } else if t.starts-with("WHEREFORE") {
      body-par(none, with-notes(t, notes))
    } else {
      n += 1
      body-par(n, with-notes(t, notes))
    }
  }
}

/// Signature block (LR 10.1(f), (g), (h), (i)): date, firm, "BY: /s/" line, the typed name under it,
/// address and telephone, state bar numbers and e-mail, and the party represented; a blank line between the
/// groups. It never breaks across a page.
#let signature-block(meta) = block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
  line-block[This the #meta.date.]
  let sig = meta.signature
  let firm = sig.at("firm", default: ())
  let by = sig.at("by", default: sig.signers.at(0).name)
  let groups = ()
  if firm.len() > 0 { groups.push(firm) }
  groups.push((if firm.len() > 0 { "BY: /s/ " + by } else { "/s/ " + by },))
  for s in sig.signers { groups.push((s.name,) + s.lines) }
  groups.push(sig.at("address", default: ()))
  groups.push(sig.at("counsel_for", default: ()))
  let first = true
  for g in groups.filter(g => g.len() > 0) {
    for (i, l) in g.enumerate() {
      line-block(above: if i == 0 { if first { pitch-double } else { gap } } else { 0pt }, left: sig-indent, inl(l))
    }
    first = false
  }
})

#let nced-complaint(meta, body) = {
  // LR 10.1(j): every page numbered sequentially, centered at the foot of the page, in a single-spaced line box
  // where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("§§ 2201"; xengine binds a single one), its space a no-break one so
  // that xengine's rule does not box the second sign apart (a gap the PDF text reads as a space).
  show regex("[§¶]{2,} \\S+"): it => box(it.text.replace(" ", "\u{a0}"))

  // LR 10.1(a) "typed matter": footnotes in the type size, single-spaced.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)   // the entry does not inherit the body's leading
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings at the body pitch, a single line above and below, kept with the text after them: level 1 a centered
  // bold section in capitals, level 2 centered bold, level 3 bold italic at the margin.
  show heading: it => block(sticky: true, width: 100%, above: heading-gap, below: heading-gap, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", style: "italic", it.body) }
  })

  cover(meta)
  if "lead_in" in meta { body-par(none, inl(meta.lead_in), above: gap) }
  allegations(body)
  signature-block(meta)
}
