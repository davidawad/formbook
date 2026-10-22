// Memorandum of law supporting a motion (Fed. R. Civ. P. 12(b)) for the U.S. District Court for the Eastern
// District of North Carolina (nced). Rules: Local Civil Rule 7.1(e) and 7.2(a) (a supporting memorandum; its
// content); 7.2(f) (length: 30 pages or 8,400 words; the word-count certificate when the word limit is used);
// 10.1 (letter paper, double-spaced, at least 11-point type, one-inch margins, court and division, case number,
// caption, title with the rule relied on, attorney block, date, signature with the typed name, page numbers).
// See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; see README, "Known gaps"
#let type-size = 12pt                   // LR 10.1(a): at least 11 point (footnotes are typed matter too)
#let margin = 1in                       // LR 10.1(a): one inch on all sides
#let para-indent = 0.5in                // first-line indent of text paragraphs; level-3 headings stand in by it
#let label-col = 0.6in                  // a heading's label column (0.5 in and a 0.1 in gutter); the title hangs after it
#let caption-left = 3.4in               // party column of the caption
#let caption-paren = 0.25in             // column of ")" marks, one per caption line
#let title-gap = 0.25in                 // space between the ")" column and the title block
#let sig-indent = 3in                   // the attorney block
#let served-indent = 0.5in              // the service list

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: court title, caption, signature block, footnotes
#let pitch-double = 2 * pitch-single    // LR 10.1(a): double-spaced
#let gap = pitch-single                 // a blank single line: between the parts of the cover, the signature and the certificates
#let heading-gap = pitch-single         // above and below a heading
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text 140 twips after)
#let note-clearance = 12.6pt            // between the body and the footnote separator (LibreOffice's footnote area)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nced-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, bold, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown: a "#" heading is level 1, "##" level 2, "###" level 3.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

/// A paragraph at the double pitch, first line indented.
#let body-par(content, above: 0pt, indent: para-indent) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: indent, all: true), content))

/// A centered bold title at the double pitch (the certificates).
#let title-line(above: 0pt, t) = block(width: 100%, above: above, below: 0pt, sticky: true,
  align(center, text(weight: "bold", t)))

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
  assert(measure(c).width <= caption-left, message: "nced-motion-brief: a caption line must fit on one line: " + r.t)
  c
}

/// One single-spaced row per caption line, a ")" closing each; the title beside them, centered on them.
#let caption(meta) = {
  let rows = meta.caption.lines.map(caption-item)
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(width: 100%, above: gap, below: 0pt, grid(
    columns: (caption-left, caption-paren, 1fr),
    rows: (pitch-single,) * rows.len(),
    grid.cell(x: 2, y: 0, rowspan: rows.len(),
      align(horizon, pad(left: title-gap, text(weight: "bold", inl(meta.brief_title))))),
    ..rows.map(r => (caption-cell(r), [)])).flatten(),
  ))
}

#let cover(meta) = {
  court-title(meta)
  case-number-line(meta)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Signature and certificates: each never breaks across a page
// ---------------------------------------------------------------------------

/// The attorney block (LR 10.1(f), (h), (i)): firm, the "BY: /s/" line, each signer's typed name with bar number
/// and e-mail, the address and telephone, and the party represented; a blank line between the groups, the first
/// `above` the block before it.
#let signature-lines(meta, above) = {
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
      line-block(above: if i == 0 { if first { above } else { gap } } else { 0pt }, left: sig-indent, inl(l))
    }
    first = false
  }
}

/// Dated signature block after the memorandum's conclusion (LR 10.1(g)).
#let signature-block(meta) = block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
  line-block[This the #meta.date.]
  signature-lines(meta, pitch-double)
})

/// LR 7.2(f)(3): a memorandum that uses the word limit carries a certificate stating its word count.
#let word-certificate(meta) = block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
  title-line("CERTIFICATE OF COMPLIANCE WITH WORD LIMIT")
  body-par(above: gap)[The undersigned certifies that this memorandum complies with the word limit of Local Civil Rule 7.2(f)(3)(A) and contains #meta.word_count words, excluding the matters listed in Local Civil Rule 7.2(f)(1), as counted by the word-processing software used to prepare it.]
  signature-lines(meta, gap)
})

/// Certificate of service (Fed. R. Civ. P. 5(b)).
#let service-certificate(meta) = block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
  title-line("CERTIFICATE OF SERVICE")
  body-par(above: gap, inl(meta.certificate.text))
  for (i, l) in meta.certificate.served.enumerate() {
    line-block(above: if i == 0 { gap } else { 0pt }, left: served-indent, inl(l))
  }
  body-par(above: gap)[This the #meta.certificate.date.]
  signature-lines(meta, gap)
})

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

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

/// Under "ARGUMENT" the points are Roman numerals (I., II.) and their sub-points lettered (A., B.); elsewhere the
/// sub-headings are lettered (A., B.) and their sub-points numbered (1., 2.). The template numbers them: the
/// sample writes the heading text alone. Each blank-line-separated chunk is a heading or a paragraph.
#let memorandum(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let notes = (:)
  for c in chunks {
    let m = c.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*"))
    if m != none { notes.insert(m.captures.at(0), c.slice(m.end)) }
  }
  let in-argument = false
  let (n2, n3) = (0, 0)
  for t in chunks.filter(c => not c.starts-with("[^")) {
    let h = t.match(regex("^(#{1,3})[ \\t]+(.*)$"))
    if h != none {
      let level = h.captures.at(0).len()
      let title = h.captures.at(1)
      let head(left, body) = block(sticky: true, width: 100%, above: heading-gap, below: heading-gap,
        pad(left: left, par(first-line-indent: 0pt, hanging-indent: if left == none { 0pt } else { label-col },
          text(weight: "bold", body))))
      if level == 1 {
        in-argument = upper(title.trim()) == "ARGUMENT"
        (n2, n3) = (0, 0)
        block(sticky: true, width: 100%, above: heading-gap, below: heading-gap,
          align(center, text(weight: "bold", upper(inl(title)))))
      } else if level == 2 {
        n2 += 1
        n3 = 0
        let lab = numbering(if in-argument { "I." } else { "A." }, n2)
        head(0pt, [#box(width: label-col, lab)#inl(title)])
      } else {
        n3 += 1
        let lab = numbering(if in-argument { "A." } else { "1." }, n3)
        head(para-indent, [#box(width: label-col, lab)#inl(title)])
      }
    } else {
      body-par(with-notes(t, notes))
    }
  }
}

#let nced-motion-brief(meta, body) = {
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

  cover(meta)
  block(above: gap, below: 0pt, memorandum(body))
  signature-block(meta)
  if "word_count" in meta {
    pagebreak(weak: true)
    word-certificate(meta)
  }
  if "certificate" in meta { service-certificate(meta) }
}
