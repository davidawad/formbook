// U.S. District Court for the District of Hawaii: complaint.
//
// Rule-driven and content-agnostic. Requirement references are to ../README.md (the rules,
// with URLs and the date they were verified). No case-specific text, no coordinates measured
// off any filed document, no forced line breaks. The body is read by blank-line chunks here
// (allegations numbered, FRCP 10(b)); the metadata is the YAML frontmatter of the sample.
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is explicit (Word's exact
// line spacing; docx/hid.lua sets the same twips).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

// LR 10.2(a)(2) names 14-point Times New Roman for memoranda only; a complaint has no named face, so the template
// takes the house face, Times New Roman (vendored), which is also the exemplar's face.
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 14pt                      // LR 10.2(a)(2) fixes 14 pt for memoranda only, so a complaint's size is
                                           // open; the exemplar's body is 14-pt Times (measured, see README).
#let pitch-double = 32.2pt                 // LR 10.2(a)(4) double spacing: 2.3 x the size, the exemplar's pitch (32.3 pt)
#let pitch-single = 16.1pt                 // single spacing (counsel_for, court title, caption, headings, signature)
#let counsel-size = 11pt                   // counsel block: smaller than the body, so the caption starts on page 1
#let pitch-counsel = 12.65pt               // its single spacing, 1.15 x 11 pt
#let page-margin = 1in                     // LR 10.2(a)(1): one-inch margins.
#let para-indent = 0.5in
#let caption-left = 3.1in                  // the parties box
#let caption-pad = 0.125in                 // the parties box's text stands this far off its right rule
#let caption-foot = 8pt                    // and its last line this far above its bottom rule
#let caption-gap = 0.2in                   // the case column stands this far off the parties box
#let signature-indent = 3in                // the signature lines start 3 in from the margin
#let court-title = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF HAWAII")  // FRCP 10(a); LR 10.2(c)(1)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("hid-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("hid-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Blank-line separated chunks of the body.
#let chunks(body) = body.split(regex("\n[ \t]*\n")).map(s => s.trim()).filter(s => s != "")

/// One line block at `pitch` (a paragraph of its own); an empty line keeps its height.
#let line-block(pitch: pitch-single, above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" or body == [] { pitch } else { auto }, {
  set text(..edges(pitch))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Caption (LR 10.2(b): counsel upper left; LR 10.2(c): court, action, case number, title)
// ---------------------------------------------------------------------------

// Counsel columns, by how many the frontmatter gives (`counsel.columns`). Widths sum to the 6.5-inch
// text block; three columns keep the counsel block short enough for the caption to start on page 1.
#let counsel-widths = (
  "1": (6.5in,),
  "2": (3.25in, 3.25in),
  "3": (2.3in, 2.2in, 2.0in),
)

/// One counsel column: single-spaced lines at the counsel size (LR 10.2(b), LR 10.2(a)(4)); "" a blank line.
#let counsel-column(lines) = {
  set text(size: counsel-size)
  for l in lines { line-block(pitch: pitch-counsel, l) }
}

#let caption(meta) = {
  let columns = meta.at("counsel", default: (:)).at("columns", default: ())
  grid(
    columns: counsel-widths.at(str(columns.len())),
    ..columns.map(counsel-column),
  )
  if "counsel_for" in meta {
    line-block(above: pitch-single, emph(inl(meta.counsel_for)))
  }
  block(above: pitch-single, below: pitch-single, for t in court-title { line-block(align(center, strong(t))) })
  // The parties box (a rule at its right and bottom) and the case column: one single line each, a blank line between
  // the parts. Never split.
  let left = ()
  for p in need(meta, "parties") {
    for n in p.names { left.push(line-block(n)) }
    left.push(line-block(""))
    left.push(line-block(align(right, emph(inl(p.designation)))))
    if p != meta.parties.last() {
      left.push(line-block(""))
      left.push(line-block[v.])
      left.push(line-block(""))
    }
  }
  let case = "Civil No. " + need(meta, "case_number")
  if "judge_initials" in meta and meta.judge_initials != "" { case += "-" + meta.judge_initials }
  block(breakable: false, above: 0pt, below: pitch-single, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, inset: (right: caption-pad, bottom: caption-foot), stroke: (right: 0.75pt, bottom: 0.75pt),
      left.join()),
    pad(left: caption-gap, {
      line-block("")
      line-block(case)
      line-block("")
      line-block(strong(inl(need(meta, "title"))))
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch with the first-line indent; `keep`: kept whole on the page of the block
/// after it (the last block stays with the signature).
#let body-par(content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// A level-1 heading: centered, bold, capitals, at the body pitch. Not numbered. Never ends a page.
#let heading1(text-md) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false,
  align(center, strong(upper(inl(text-md)))))

/// A level-2 heading: bold, single-spaced, its roman numeral in a half-inch box and the text hanging after it,
/// a single line above and below. Kept with the next paragraph.
#let heading2(num, text-md) = block(width: 100%, above: pitch-single, below: pitch-single, sticky: true,
  breakable: false, {
  set text(..edges(pitch-single))
  par(first-line-indent: 0pt, hanging-indent: para-indent,
    strong[#box(width: para-indent, numbering("I.", num))#inl(text-md)])
})

/// A lettered item (prayer for relief): the letter half an inch in, the text hanging at one inch.
#let lettered(i, item, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep,
  pad(left: para-indent, par(first-line-indent: 0pt, hanging-indent: para-indent,
    [#box(width: para-indent, numbering("a.", i + 1))#inl(item)])))

#let render-body(body) = {
  // the blocks of the body in order: (kind, content)
  let blocks = ()
  for c in chunks(body) {
    if c.starts-with("- ") {
      let items = ()
      for line in c.split("\n") {
        if line.starts-with("- ") { items.push(line.slice(2).trim()) }
        else { items.push(items.pop() + " " + line.trim()) }
      }
      for (i, it) in items.enumerate() { blocks.push(("item", (i, it))) }
    } else if c.starts-with("## ") { blocks.push(("h2", c.slice(3))) }
    else if c.starts-with("# ") { blocks.push(("h1", c.slice(2))) }
    else if c.starts-with("> ") { blocks.push(("unnumbered", c.slice(2).replace("\n", " "))) }
    else { blocks.push(("numbered", c.replace("\n", " "))) }
  }
  let n = 0
  let h2 = 0
  for (k, (kind, c)) in blocks.enumerate() {
    let keep = k == blocks.len() - 1
    if kind == "h1" { heading1(c) }
    else if kind == "h2" { h2 += 1; heading2(h2, c) }
    else if kind == "item" { lettered(c.at(0), c.at(1), keep: keep) }
    else if kind == "unnumbered" { body-par(inl(c), keep: keep) }
    else { n += 1; body-par([#n. #inl(c)], keep: keep) }
  }
}

// ---------------------------------------------------------------------------
// Signature block (dated line at left, signature lines from 3 in)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = meta.at("signature", default: (:))
  block(breakable: false, above: pitch-single, below: 0pt, {
    if "date" in meta { line-block(meta.date) }
    line-block("")
    let blocks = sig.at("blocks", default: ())
    for (i, b) in blocks.enumerate() {
      for l in b.lines { line-block(if l == "" { "" } else { pad(left: signature-indent, inl(l)) }) }
      if i < blocks.len() - 1 { line-block("") }
    }
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let hid-complaint(meta, body-md) = {
  set document(title: need(meta, "title") + " (Civil No. " + need(meta, "case_number") + ")")
  // The page number centered at the foot, "- n -", in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), [#"-" #counter(page).display() #"-"])),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LR 10.2(a)(4): double spaced).
  show: xengine.with(pitch: pitch-double)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  show link: it => it.body
  caption(meta)
  render-body(body-md)
  signature-block(meta)
}
