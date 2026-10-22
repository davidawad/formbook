// Motion with memorandum in support for the U.S. Bankruptcy Court, S.D. Ohio (FRBP 9013).
// Rules: Fed. R. Bankr. P. 9013 (a motion must be in writing, state its grounds with particularity and set forth the
// relief requested), 9004(a)-(b) (legible; caption with court, title, case number and designation); S.D. Ohio LBR
// 9004-1(b) (8 1/2 x 11, double spaced, top margin of one inch or more, 10-12 point type), LBR 9004-2 (caption),
// LBR 9013-1(a) (memorandum in support, certificate of service, 21-day notice unless exempt; the notice text is the
// sample in LBR 9013-1(a)(2)), LBR 9013-2(a) (20-page limit: not checked here), LBR 9013-3 (certificate of service).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no face is named (LBR 9004-1(b)); Times New Roman, vendored
#let type-size = 12pt                   // LBR 9004-1(b): typed print at least 10-12 point; 12 point is used
#let margin = 1in                       // LBR 9004-1(b): top margin not less than one inch; the sides match it
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                // first-line indent of paragraphs
#let quote-indent = 0.75in              // left indent of a lettered quotation ("(A) ...", the § 1112(b)(4) list)
#let list-indent = 0.5in                // a markdown list's number starts half an inch in ...
#let list-box = 0.4in                   // ... in a box of its own; the text hangs at 0.9 in (docx: List Number)
#let cap-left = 3.4in                   // the caption's party column ...
#let cap-mid = 0.3in                    // ... the column of ")" marks ...
#let cap-pad = 0.15in                   // ... and the case column's text off its left edge
#let sig-col = 2.8in                    // the signature column starts here; "Dated:" sits left of it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ohsb-motion-brief.lua and
// docx/reference.xml set the same twips: 20 x pt).
#let pitch-body = 24pt                  // LBR 9004-1(b): double spaced (docx 480)
#let pitch-single = 14pt                // court title, caption, title, signature, footnotes, address blocks, footer (docx 280)
#let cover-gap = 14pt                   // a blank single line: court title to caption, caption to title
#let text-above = 24pt                  // the title to the text: a blank double line
#let sig-above = 12pt                   // the paragraph before a signature block to the block
#let lines-gap = 14pt                   // a blank single line around a hard-broken (address) block
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
  if m == none { panic("ohsb-motion-brief: the sample must start with a YAML frontmatter block") }
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
#let is-quote(t) = t.match(regex("^\\([A-Za-z]\\)[ \\t]")) != none
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

/// A body paragraph on the double pitch, its first line indented.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(content))

/// Headings at the type size on the body pitch, with no space of their own, kept with the block after them:
/// level 1 centered bold capitals, level 2 centered bold.
#let heading-block(level, s) = {
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

// ---------------------------------------------------------------------------
// The 21-day notice (LBR 9013-1(a)(2)): the rule's sample text with the movant's name and the relief filled in
// from the frontmatter. Rendered where the sample carries {{NOTICE_21_DAY}}.
// ---------------------------------------------------------------------------

#let notice-21-day(meta) = {
  let movant = meta.notice.movant
  let relief = meta.notice.relief
  let rep(s) = s.replace("(Name)", movant).replace("(relief sought in motion/objection)", relief)
  heading-block(1, "NOTICE OF MOTION/OBJECTION")
  for p in (
    rep("(Name) has filed papers with the court to obtain (relief sought in motion/objection)."),
    "Your rights may be affected. You should read these papers carefully and discuss them with your attorney, if you have one in this bankruptcy case. If you do not have an attorney, you may wish to consult one.",
    "If you do not want the court to grant the relief sought in the motion/objection, then on or before twenty-one (21) days from the date set forth in the certificate of service for the motion/objection, you must file with the court a response explaining your position by mailing your response by first class mail to " + meta.notice.clerk_address + " OR your attorney must file a response using the court’s ECF System.",
    "The court must receive your response on or before the above date.",
    "You must also send a copy of your response either by 1) the court’s ECF System or by 2) first class mail to " + meta.notice.movant_address + " and " + meta.notice.others + ".",
    "If you or your attorney do not take these steps, the court may decide that you do not oppose the relief sought in the motion/objection and may enter an order granting that relief without further hearing or notice.",
  ) {
    body-par(p)
  }
}

// ---------------------------------------------------------------------------
// Body: paragraphs (unnumbered), headings, lists, lettered quotations, centered asterisks, address blocks
// ---------------------------------------------------------------------------

/// One chunk: a heading ("#"/"##"), the signature directive, the notice directive, the centered asterisks, a
/// markdown list, a lettered quotation "(A) ...", a block of hard-broken lines (an address: single spaced, not
/// indented, a blank single line around it), or a paragraph (first line indented).
#let render-chunk(t, meta, defs) = {
  if t.starts-with("## ") {
    heading-block(2, t.slice(3))
  } else if t.starts-with("# ") {
    heading-block(1, t.slice(2))
  } else if t == "{{SIGNATURE}}" {
    signature-block(meta)
  } else if t == "{{NOTICE_21_DAY}}" {
    notice-21-day(meta)
  } else if t == "***" {
    block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt)[\*\*\*]))
  } else if is-list(t) {
    list-items(t, defs)
  } else if is-quote(t) {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: quote-indent, par(first-line-indent: 0pt, rich(t, defs))))
  } else if t.contains("\\\n") {
    block(width: 100%, above: lines-gap, below: lines-gap, {
      set text(..edges(pitch-single))
      par(first-line-indent: 0pt, rich(t, defs))
    })
  } else {
    body-par(rich(t, defs))
  }
}

// ---------------------------------------------------------------------------
// Entry: the whole motion with memorandum
// ---------------------------------------------------------------------------

#let motion-brief(meta, body) = {
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "" and not is-def(c))

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
  for t in chunks { render-chunk(t, meta, defs) }
}
