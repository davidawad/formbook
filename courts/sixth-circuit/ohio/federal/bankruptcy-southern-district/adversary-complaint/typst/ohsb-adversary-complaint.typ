// Adversary complaint for the U.S. Bankruptcy Court, S.D. Ohio (FRBP 7001 proceeding).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies to the form of an adversary pleading; the caption
// substantially conforms to Official Form 416), 9004(a)-(b) (legible; caption with court, title, case and
// adversary numbers, designation); S.D. Ohio LBR 9004-1(b) (8 1/2 x 11, double spaced, top margin of one inch or
// more, 10-12 point type), LBR 9004-2 (caption: debtor, case number, chapter, adversary number, judge, nature of the
// paper and the relief), LBR 7001-1 (one adversary per defendant: not checked here). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no face is named (LBR 9004-1(b)); Times New Roman, vendored
#let type-size = 12pt                   // LBR 9004-1(b): typed print at least 10-12 point; 12 point is used
#let margin = 1in                       // LBR 9004-1(b): top margin not less than one inch; the sides match it
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                // first-line indent of paragraphs; an allegation's number starts here
#let num-box = 0.5in                    // an allegation's number (or a relief item's numeral) in a box this wide:
                                        // the text starts 1 in from the margin (docx: a tab at 1440)
#let list-indent = 0.5in                // a markdown list's number starts half an inch in ...
#let list-box = 0.4in                   // ... in a box of its own; the text hangs at 0.9 in (docx: List Number)
#let cap-left = 3.4in                   // the caption's party column ...
#let cap-mid = 0.3in                    // ... the column of ")" marks ...
#let cap-pad = 0.15in                   // ... and the case column's text off its left edge
#let sig-col = 2.8in                    // the signature column starts here; "Dated:" sits left of it
#let table-char = 6pt                   // a pipe table: a column is half an em per character of its longest cell ...
#let table-slack = 3                    // ... plus this many characters of room
#let table-inset = 5pt                  // cell padding (docx: 100 twips), 0.5 pt rules

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ohsb-adversary-complaint.lua and
// docx/reference.xml set the same twips: 20 x pt).
#let pitch-body = 24pt                  // LBR 9004-1(b): double spaced (docx 480)
#let pitch-single = 14pt                // court title, caption, title, signature, footnotes, table, footer (docx 280)
#let cover-gap = 14pt                   // a blank single line: court title to caption, caption to title
#let text-above = 24pt                  // the title to the text: a blank double line
#let sig-above = 12pt                   // the last paragraph to the signature block
#let table-space = 12pt                 // an exhibit heading to its table
#let note-gap = 7pt                     // between two footnotes (docx: Footnote Text 140 twips after)
#let note-clearance = 6pt               // the text to the footnote rule (LibreOffice reserves no more above a note)
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohsb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown.
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

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

/// Single-pitch lines, one paragraph each; an empty item is a blank single line. `above`: the space before the first.
#let lines(items, above: 0pt, centered: false) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  set align(center) if centered
  let gap = above
  for i in items {
    if i == "" { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, par(if type(i) == str { inl(i) } else { i }))
      gap = 0pt
    }
  }
}

/// A body paragraph on the double pitch, its first line indented; `label` (a number) in a box `num-box` wide.
#let body-par(label, content) = block(width: 100%, above: 0pt, below: 0pt, par({
  if label != none { box(width: num-box, label) }
  content
}))

/// Headings at the type size on the body pitch, with no space of their own, kept with the block after them:
/// level 1 centered bold capitals, level 2 centered bold. `page`: the heading opens a page (an exhibit).
#let heading-block(level, s, page: false) = {
  if page { pagebreak(weak: true) }
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, align(center, par(first-line-indent: 0pt,
    text(weight: "bold", if level == 1 { upper(inl(s)) } else { inl(s) }))))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Court name (LBR 9004-2: the court and the division), three centered bold single lines.
#let court-title(meta) = lines(centered: true,
  ("UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF OHIO", meta.division).map(l => text(weight: "bold", l)))

/// Caption: the parties and the case information on either side of a column of ")" marks, one row per single line
/// (an empty entry is a blank line); a ")" beside every party line (docx: a borderless table, one row per line).
#let caption(meta) = {
  let left = meta.caption.left
  let right = meta.caption.right
  let n = calc.max(left.len(), right.len())
  let cell(s, pad: 0pt) = if s == "" { block(height: pitch-single) } else {
    block(width: 100%, inset: (left: pad), par(inl(s)))
  }
  block(width: 100%, above: cover-gap, below: 0pt, breakable: false, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    grid(columns: (cap-left, cap-mid, 1fr),
      ..range(n).map(i => (
        cell(left.at(i, default: "")),
        if i < left.len() { align(center, par[)]) } else { block(height: pitch-single) },
        cell(right.at(i, default: ""), pad: cap-pad),
      )).flatten())
  })
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  lines(above: cover-gap, centered: true, (text(weight: "bold", meta.brief_title),))
}

// ---------------------------------------------------------------------------
// Signature block: optional "Dated:" at the left, the closing and the signer's lines in the signature column
// ---------------------------------------------------------------------------

/// Single-spaced: the closing, a blank line, the signer's lines, all from `sig-col`; "Dated:" and the date left of
/// the first line when the frontmatter has a date (docx: a tab and a hanging indent there). Kept on one page.
#let signature-lines(meta) = {
  let sig = meta.signature
  let items = ()
  if "closing" in sig and sig.closing != none and sig.closing != "" { items += (sig.closing, "") }
  if "firm" in sig and sig.firm != none { items += sig.firm + ("",) }
  items += sig.lines
  let date = if "date" in meta and meta.date != none and meta.date != "" { [Dated: #meta.date] } else { [] }
  let gap = 0pt
  let first = true
  set text(..edges(pitch-single))
  for i in items {
    if i == "" { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if first { date })#inl(i)]))
      gap = 0pt
      first = false
    }
  }
}

#let signature-block(meta) = block(width: 100%, breakable: false, above: sig-above, below: 0pt, signature-lines(meta))

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b)), headings, roman relief items, lists, tables
// ---------------------------------------------------------------------------

/// A pipe table, unnumbered, single-spaced with 0.5 pt rules, centered, kept on one page. A column is `table-char`
/// per character of its longest cell (emphasis marks not counted) plus `table-slack` (docx: the same arithmetic).
#let pipe-table(t) = {
  let row(l) = {
    let s = l.trim()
    if s.starts-with("|") { s = s.slice(1) }
    if s.ends-with("|") { s = s.slice(0, -1) }
    s.split("|").map(c => c.trim())
  }
  let ls = t.split("\n").map(l => l.trim()).filter(l => l != "")
  let rows = ls.enumerate().filter(((i, l)) => i != 1).map(((i, l)) => row(l))
  let ncol = rows.first().len()
  let chars(c) = c.replace("*", "").clusters().len()
  let widths = range(ncol).map(j => (calc.max(..rows.map(r => chars(r.at(j, default: "")))) + table-slack) * table-char)
  block(width: 100%, above: table-space, below: 0pt, breakable: false, align(center, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    table(columns: widths, inset: table-inset, stroke: 0.5pt, align: left,
      ..rows.map(r => range(ncol).map(j => inl(r.at(j, default: "")))).flatten())
  }))
}

/// A markdown list chunk: one paragraph per item, the number `list-indent` in, in a `list-box`, the text hanging
/// after it; numbered from the list's first number.
#let list-items(t, defs) = {
  let items = ()
  let start = int(t.match(regex("^\\d+")).text)
  for l in t.split(regex("\\r?\\n")) {
    let m = l.match(regex("^(?:\\d+\\.|[-*+])[ \\t]+([\\s\\S]*)$"))
    if m != none { items.push(m.captures.at(0)) } else if items.len() > 0 { items.at(-1) += " " + l.trim() }
  }
  for (k, item) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent, par(first-line-indent: 0pt,
      hanging-indent: list-box, [#box(width: list-box)[#(start + k).]#rich(item, defs)])))
  }
}

/// One chunk. A chunk is a heading ("#"/"##"; "# EXHIBIT ..." opens a page), a table ("|"), a list, a roman-numeral
/// relief item (renumbered i., ii., ...), the signature directive, or a paragraph (numbered, Fed. R. Civ. P. 10(b)).
#let render-chunk(t, meta, defs, para, relief) = {
  if t.starts-with("## ") {
    heading-block(2, t.slice(3))
  } else if t.starts-with("# ") {
    heading-block(1, t.slice(2), page: upper(t.slice(2)).starts-with("EXHIBIT"))
  } else if t == "{{SIGNATURE}}" {
    signature-block(meta)
  } else if t.starts-with("|") {
    pipe-table(t)
  } else if is-list(t) {
    list-items(t, defs)
  } else if is-relief(t) {
    relief.step()
    let mm = t.match(regex("^([ivxlcdm]+)\\.[ \\t]+"))
    context body-par(numbering("i.", relief.get().first()), rich(t.slice(mm.end), defs))
  } else {
    para.step()
    context body-par(str(para.get().first()) + ".", rich(t, defs))
  }
}

// ---------------------------------------------------------------------------
// Entry: the whole complaint
// ---------------------------------------------------------------------------

#let complaint(meta, body) = {
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "" and not is-def(c))
  let para = counter("allegation")
  let relief = counter("relief-item")

  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. Lists are laid out here.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 547"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the type size, single-spaced (docx: Footnote Text in 14 pt boxes, 7 pt after), a short rule above.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  cover(meta)
  v(text-above)
  if "lead_in" in meta and meta.lead_in != none { body-par(none, rich(meta.lead_in, defs)) }

  // The chunk before the signature directive is kept on one page with the signature block, so a signature never
  // starts a page alone.
  let i = 0
  while i < chunks.len() {
    let t = chunks.at(i)
    if i + 1 < chunks.len() and chunks.at(i + 1) == "{{SIGNATURE}}" and not t.starts-with("#") {
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
        render-chunk(t, meta, defs, para, relief)
        signature-block(meta)
      })
      i += 2
    } else {
      render-chunk(t, meta, defs, para, relief)
      i += 1
    }
  }
}
