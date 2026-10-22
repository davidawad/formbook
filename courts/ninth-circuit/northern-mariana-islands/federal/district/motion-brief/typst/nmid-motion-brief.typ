// U.S. District Court for the Northern Mariana Islands: motion with memorandum of points and authorities.
// Rules: D.N.M.I. LR 5.2 (form: paper, numbered lines, double spacing, 12-point serif type, margins,
// top-right corner blank on page one, court title, caption, hearing date and time on page one), LR 5.2.b
// (authorities not on Westlaw or Lexis are attached), LR 7.1.d (length: 25 pages for a memorandum; a table of
// contents and a table of authorities above 10 pages); Fed. R. Civ. P. 12(b). See ../README.md for the rule text.
// Content-agnostic: no case-specific text here; the metadata and the body come from the sample.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LR 5.2.a: a serif font. Vendored in fonts/.
#let type-size = 12pt                   // LR 5.2.a: 12-point type or larger, footnotes included.
#let page-w = 8.5in                     // LR 5.2.a: 8.5 x 11 inch paper.
#let page-h = 11in
#let top-margin = 1.5in                 // LR 5.2.a: not less than 1.5 inches on the top.
#let left-margin = 1in                  // LR 5.2.a: one inch on the left-hand side (the line numbers sit in it).
#let right-margin = 0.5in               // LR 5.2.a: one-half inch on the right-hand side.
#let text-width = page-w - left-margin - right-margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/nmid-motion-brief.lua sets the same twips).
#let pitch = 24pt                       // LR 5.2.a: double spacing; the numbered lines are this pitch (docx 480).
// Single-spaced lines (counsel, caption, signature, footnotes) at exactly half a numbered line, and every space between
// them a multiple of it: each such line sits on a numbered line or halfway between two, never a few points off one
// (docx 240), so the line numbers and the text read alike in every engine's PDF.
#let pitch-single = 12pt
#let half = 12pt                        // half a numbered line: the gaps inside the caption and the signature
// A line box sets its baseline at 0.8 of its height (Word's exact spacing), 19.2 pt down a numbered line but 9.6 pt
// down a single line: a block of single lines starts `lift` lower, so its baselines fall on the numbered lines' (or
// halfway between two), and ends `drop` lower, so its height stays a whole number of half lines (docx: the same
// twips before the first line or as cell margins).
#let lift = 0.8 * (pitch - pitch-single)  // 9.6 pt
#let drop = pitch-single - lift           // 2.4 pt
// 1.5 in top + 1 in bottom leaves 8.5 in: 25 double-spaced lines (25 x 24 pt). The footer sits below them.
#let lines-per-page = 25
#let bottom-margin = page-h - top-margin - lines-per-page * pitch
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.25in            // the party column's rule to the right column
#let caption-pad = 10pt                 // the party column's text to its right rule
#let caption-below = half              // the party column's last line to its bottom rule
#let case-pad = 0.1in                   // the right column's text from its left edge
#let counsel-width = 4.2in
#let counsel-lines = 7                  // counsel block takes at least lines 1 to 7
#let sig-left = 2.6in                   // signature: the date column
#let sig-gutter = 0.2in
#let page-col = 0.5in                   // contents and authorities: the page column the rows wrap before
#let toa-hang = 0.35in                  // an authority's second line hangs this far in
#let item-label = 0.5in                 // a lettered item's label starts half an inch in
#let item-box = 0.4in                   // and the text 0.4 in after it
#let passim-threshold = 7               // an authority cited on this many pages or more prints "passim"
#let note-gap = 0pt                     // between two footnotes (docx: Footnote Text 0 twips after)
#let note-clearance = 12pt              // the body text to the footnote rule
// The footer: the page number centered, then the paper's title and the case number, two 12 pt lines 4 pt apart at
// 10 pt type, the second ending 0.4 in above the bottom edge (docx: footer distance 576 twips).
#let footer-size = 10pt
#let footer-pitch = 12pt
#let footer-gap = 4pt
#let footer-foot = 0.4in

// LR 5.2.d.1: the court's title, two lines, single-spaced and centered, at least 1.5 inches from the top.
#let court-title-lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN MARIANA ISLANDS")

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmid-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, names with *et al.*, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nmid-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Single-spaced lines, one paragraph each, `above` the first. An item is a string (markdown) or content.
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let gap = above
  for i in items {
    block(width: 100%, above: gap, below: 0pt, if type(i) == str { inl(i) } else { i })
    gap = 0pt
  }
}

// ---------------------------------------------------------------------------
// Headings: numbering and styles (the memorandum's own scheme: I., 1., a., (1))
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", 3 "1.", 4 "a.", 5 "(1)". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else if lv == 5 { numbering("(1)", k) }
  else { "" }
}

#let label-indent(level) = calc.max(level - 2, 0) * heading-tab

/// A centred bold line on the numbered-line pitch.
#let title-line(s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true,
  align(center, par(first-line-indent: 0pt, strong(s))))

// ---------------------------------------------------------------------------
// Tables of contents and authorities (LR 7.1.d.1)
// ---------------------------------------------------------------------------

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// A table's title and its column label at the right, each one numbered line.
#let table-head(title, col) = {
  title-line(upper(title))
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, align(right, par(first-line-indent: 0pt, strong(col))))
}

#let toc-section() = {
  table-head[Table of Contents][Page]
  context {
    for hd in query(heading.where(outlined: true)) {
      if hd.level > 4 { continue }
      let nums = counter(heading).at(hd.location()).slice(0, hd.level)
      let lab = heading-num(..nums)
      let ind = label-indent(hd.level)
      let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
      listing-row(hd.location(), [#h(ind)#box(width: heading-tab, lab)#title], page-label(hd.location()),
        page-col, ind + heading-tab, 0pt)
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes"),
  ("rule", "Rules"),
  ("regulation", "Regulations"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links in the body. Every link must have a registry entry.
#let toa-section(authorities) = {
  table-head[Table of Authorities][Page(s)]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("nmid-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(width: 100%, above: 0pt, below: 0pt, sticky: true, par(first-line-indent: 0pt, strong(title)))
      for (key, a) in members {
        // Distinct printed page labels, in document order (the page a citation starts on).
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let name = if "name" in a { [#if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }, ] }
        listing-row(none, [#name#inl(a.cite)], page-text, page-col, toa-hang, 0pt)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// First page: counsel (lines 1-7), court title, caption with the hearing, the lead-in
// ---------------------------------------------------------------------------

/// Lines 1-7 at least (docx: a table row at least that tall); a longer counsel block pushes the court title down
/// (LR 5.2.c).
#let counsel-block(meta) = context {
  let stack = pad(top: lift, line-stack(need(meta, "counsel")))
  let h = measure(width: counsel-width, stack).height
  block(width: counsel-width, height: calc.max(counsel-lines * pitch, h), above: 0pt, below: 0pt, stack)
}

/// Caption: the parties on the left (LR 5.2.d.2), the file number, the title of the paper and the hearing
/// date and time on the right (LR 5.2.d.3, 5.2.e), a blank numbered line above it. Its height is a whole number of
/// half lines (docx: the row's natural height), so the lead-in below is on a numbered line or halfway between two.
#let caption-block(meta) = {
  let versus = meta.at("versus", default: "v.")
  let rows = ()
  for (k, p) in need(meta, "caption").enumerate() {
    if k > 0 { rows.push(versus) }
    rows += p.names + (p.designation,)
  }
  let hearing = need(meta, "hearing")
  let g = grid(
    columns: (caption-left, caption-gutter, 1fr),
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(top: lift, right: caption-pad, bottom: caption-below + drop, line-stack(rows)),
    [],
    pad(top: lift, left: case-pad, bottom: drop, {
      line-stack(("CIVIL CASE NO. " + need(meta, "case_number"),))
      line-stack((strong(inl(need(meta, "brief_title"))),), above: half)
      line-stack((
        "Hearing Date: " + hearing.at("date", default: ""),
        "Hearing Time: " + hearing.at("time", default: ""),
        "Judge: " + hearing.at("judge", default: ""),
      ), above: half)
    }),
  )
  block(width: 100%, above: pitch, below: 0pt, breakable: false, g)
}

#let first-page(meta) = {
  counsel-block(meta)
  for l in court-title-lines { title-line(l) }
  caption-block(meta)
  if "lead_in" in meta { block(width: 100%, above: 0pt, below: 0pt, par(inl(meta.lead_in))) }
}

// ---------------------------------------------------------------------------
// Signature block (LR 5.2; the layout is a convention, the rules cite no form)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, grid(
    columns: (sig-left, sig-gutter, 1fr),
    pad(top: lift, line-stack(([Date: #need(meta, "date")],))),
    [],
    pad(top: lift, {
      line-stack(([Respectfully submitted,],))
      line-stack(sig.at("preamble", default: ()), above: half)
      line-stack(("/s/ " + sig.signer, sig.signer) + sig.at("lines", default: ()), above: half)
    }),
  ))
}

// ---------------------------------------------------------------------------
// Page furniture: numbered lines, pleading rules, footer
// ---------------------------------------------------------------------------

/// The numbers 1 to 25, each in a box of the numbered-line pitch with its baseline where the body's is (docx: the
/// header's text box of 25 exact 24 pt lines).
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.3in, height: pitch,
        align(right, text(font: font-family, size: type-size, ..edges(pitch), str(i)))))
  }
}

#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.12in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.08in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.08in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

#let footer-block(title, case-number) = place(
  top + left,
  dx: left-margin,
  dy: page-h - footer-foot - 2 * footer-pitch - footer-gap,
  block(width: text-width, {
    set text(font: font-family, size: footer-size, ..edges(footer-pitch))
    set par(first-line-indent: 0pt, leading: 0pt)
    block(width: 100%, above: 0pt, below: 0pt, align(center, context counter(page).display()))
    block(width: 100%, above: footer-gap, below: 0pt, grid(
      columns: (1fr, auto),
      upper(title),
      [CASE NO. #case-number],
    ))
  }),
)

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let nmid-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "counsel", "brief_title", "footer_title", "hearing", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    numbering: "1",
    footer: none,   // the footer-block below carries the page number; typst's default footer would repeat it
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(need(meta, "footer_title"), need(meta, "case_number")),
  )
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // numbered-line pitch, footnote marks at 58 %, a section sign kept with its number. Lists are lettered below.
  show: xengine.with(pitch: pitch, list-indent: none)
  // A doubled sign stays with its number and the punctuation before it ("(§§ 175-10.1-610(b)"; xengine binds a
  // single sign; docx: a no-break space after the signs).
  show regex("\\S*[§¶]{2,} \\S+"): it => box(it)
  set heading(numbering: heading-num)
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#metadata(it.dest.slice(4))<toa-hit>#it.body]
    } else {
      it
    }
  }

  // Headings on the numbered-line pitch, kept with the block after them: level 1 centred bold capitals; deeper levels
  // bold, the label in a box half an inch wide (each level half an inch further in), the title hanging after it.
  show heading: it => {
    set text(size: type-size)   // the type size, not typst's larger heading sizes
    let body = if it.level == 1 { align(center, par(first-line-indent: 0pt, strong(upper(it.body)))) } else {
      let ind = label-indent(it.level)
      let lab = context numbering(it.numbering, ..counter(heading).at(it.location()).slice(0, it.level))
      pad(left: ind, par(first-line-indent: 0pt, hanging-indent: heading-tab,
        strong[#box(width: heading-tab, lab)#it.body]))
    }
    block(width: 100%, above: 0pt, below: 0pt, sticky: true, body)
  }

  // Lettered list items, as in the complaint: (a), (b), ...; the label half an inch in, the text 0.4 in after it.
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      if item.has("number") and item.number != none { n = item.number }
      block(above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: item-label + item-box,
        [#h(item-label)#box(width: item-box, numbering("(a)", n))#item.body]))
      n += 1
    }
  }

  first-page(meta)
  pagebreak()
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()

  // The body; its last paragraph is kept with the signature block, so the signature never stands alone.
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n"))
  let defs = chunks.filter(c => c.trim().starts-with("[^")).join("\n\n")
  let texts = chunks.filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
  if texts.len() > 1 {
    render(texts.slice(0, -1).join("\n\n") + "\n\n" + defs)
  }
  block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
    render(texts.last() + "\n\n" + defs)
    signature-block(meta)
  })
}
