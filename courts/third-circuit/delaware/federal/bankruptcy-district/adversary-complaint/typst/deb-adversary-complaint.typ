// Complaint initiating an adversary proceeding, United States Bankruptcy Court for the District of Delaware.
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; caption substantially conforms to Official
// Form 416); Fed. R. Civ. P. 10(a) (names of all parties, title) and 10(b) (numbered paragraphs);
// Fed. R. Bankr. P. 7008 and Del. Bankr. L.R. 7008-1 (statement whether the pleader consents to entry of
// final orders); Del. Bankr. L.R. 9004-1(a) (caption contents), 7003-1 (cover sheet, filed separately),
// 7004-1 (summons, filed separately). See ../README.md. Content-agnostic: every case-specific word comes
// from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
// No typeface is named for pleadings: LR 7007-2 applies only to motions in adversary proceedings, and
// Fed. R. Bankr. P. 7010 / Fed. R. Civ. P. 10 name none, so the house face applies: Times New Roman, vendored
// (docs/FONTS.md "No face named"). See ../README.md, "Typeface".
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt
#let margin = 1in                        // FRBP 9004(a): legible; letter paper, 1 in margins
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                 // first-line indent; an allegation's number starts here ...
#let num-box = 0.5in                     // ... in a box this wide: the text starts 1 in in (docx: a tab at 1440)
#let cap-left = 3.4in                    // Form 416 caption: the party column, ruled at its right and foot ...
#let cap-rule = 0.75pt                   // ... with a rule this thick ...
#let cap-pad-right = 10pt                // ... its text this far from the rule ...
#let cap-pad-below = 8pt                 // ... and its last line this far above it
#let cap-right = 0.35in                  // the case column's text this far right of the rule (0.2 in gutter + 0.15 in)
#let sig-col = 2.8in                     // the signature column; "Dated:" and the place sit left of it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/deb-adversary-complaint.lua and
// docx/reference.xml set the same twips: 20 x pt).
#let pitch-body = 24pt                   // double spaced (docx 480)
#let pitch-single = 14pt                 // court line, caption, title, signature, footer (docx 280)
#let cover-gap = 14pt                    // a blank single line: court line to caption, caption to caption, to the title
#let text-above = 24pt                   // the title to the text: a blank double line
#let sig-above = 24pt                    // the last paragraph to the signature block
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("deb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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

/// A single-pitch line (one paragraph; it wraps on single lines). `above`: the space before it.
#let sline(content, above: 0pt, align-to: left) = block(width: 100%, above: above, below: 0pt,
  align(align-to, par(first-line-indent: 0pt, content)))

/// Single-pitch lines, one paragraph each; an empty item is a blank single line.
#let lines(items, align-to: left) = {
  let gap = 0pt
  for i in items {
    if i == "" { gap += pitch-single } else {
      sline(inl(i), above: gap, align-to: align-to)
      gap = 0pt
    }
  }
}

/// A body paragraph on the double pitch: its first line indented, `label` (a number) in a box `num-box` wide.
#let body-par(label, content, align-to: left, indent: true) = block(width: 100%, above: 0pt, below: 0pt,
  align(align-to, par(first-line-indent: if indent { para-indent } else { 0pt }, {
    if label != none { box(width: num-box, label) }
    content
  })))

/// Headings on the body pitch, bold, with no space of their own, kept with the block after them: level 1 centered
/// capitals, level 2 at the margin with the text hanging half an inch, level 3 centered (the count headings).
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, par(text(weight: "bold", upper(inl(s))))) }
  else if level == 2 { par(hanging-indent: 0.5in, text(weight: "bold", inl(s))) }
  else { align(center, par(text(weight: "bold", inl(s)))) }
})

// ---------------------------------------------------------------------------
// Cover: court line, the Form 416 captions (LR 9004-1(a)), title
// ---------------------------------------------------------------------------

/// One caption block: the party names at the left, each party's designation set right, ruled at the right and the
/// foot; the case information to the right of the rule (docx: a one-row table, the left cell bordered).
#let caption-block(c) = {
  let left-col = {
    for (k, p) in c.parties.enumerate() {
      lines(if k > 0 { ("",) } else { () } + p.names)
      if "designation" in p { sline(inl(p.designation), align-to: right) }
    }
  }
  // grid cell strokes and insets: the rule runs the height of the row, the taller of the two columns, with the
  // space below it under both (LibreOffice takes a cell's bottom margin for the whole row)
  block(width: 100%, above: cover-gap, below: 0pt, breakable: false, grid(
    columns: (cap-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: cap-rule, bottom: cap-rule) },
    inset: (x, y) => if x == 0 { (right: cap-pad-right, bottom: cap-pad-below) } else { (left: cap-right, bottom: cap-pad-below) },
    left-col, lines(c.right),
  ))
}

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  sline(align-to: center, text(weight: "bold", upper(inl(meta.court))))
  caption-block(meta.caption.bankruptcy)
  caption-block(meta.caption.adversary)
  sline(above: cover-gap, align-to: center, text(weight: "bold", inl(meta.title)))
}

// ---------------------------------------------------------------------------
// Signature block: "Dated:" and the place at the left, "Respectfully submitted," and each counsel block (firm,
// a blank line, the attorneys) in the signature column, a blank line between blocks; single lines, kept whole
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = meta.signature
  let rows = ("Respectfully submitted,", "")
  for (k, b) in sig.blocks.enumerate() {
    if k > 0 { rows.push("") }
    rows += b.firm + ("",) + b.attorneys
  }
  // the left column's lines sit beside the first single lines of the right column, blank or not
  let left = ([Dated: #inl(meta.date)], inl(sig.place))
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
    set text(..edges(pitch-single))
    let gap = 0pt
    for (n, r) in rows.enumerate() {
      if r == "" and n >= left.len() { gap += pitch-single } else {
        block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
          [#box(width: sig-col, left.at(n, default: []))#inl(r)]))
        gap = 0pt
      }
    }
  })
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs (FRCP 10(b)), the unnumbered prayer and notes
// ---------------------------------------------------------------------------

/// One chunk. Each blank-line-separated chunk of markdown is one numbered paragraph (FRCP 10(b)), except: headings;
/// the prayer (a WHEREFORE clause and its lettered "a)" items, which the exemplar leaves unnumbered); and editorial
/// notes written in italic brackets ("*[...]*"), which mark omitted text in a sample (centered).
#let render-chunk(t, para) = {
  let h = t.match(regex("^(#{1,3})[ \\t]+(.*)$"))
  if h != none {
    heading-block(h.captures.at(0).len(), h.captures.at(1))
  } else if t.starts-with("WHEREFORE") or t.match(regex("^[a-z]\\)[ \\t]")) != none {
    body-par(none, inl(t))
  } else if t.starts-with("*[") {
    body-par(none, inl(t), align-to: center, indent: false)
  } else {
    para.step()
    context body-par(str(para.get().first()) + ".", inl(t))
  }
}

#let deb-adversary-complaint(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let para = counter("allegation")

  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 157"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)
  v(text-above)
  if "preamble" in meta { body-par(none, inl(meta.preamble)) }
  // The last chunk is kept on one page with the signature block, so a signature never starts a page alone.
  for (i, t) in chunks.enumerate() {
    if i + 1 == chunks.len() {
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
        render-chunk(t, para)
        signature-block(meta)
      })
    } else {
      render-chunk(t, para)
    }
  }
}
