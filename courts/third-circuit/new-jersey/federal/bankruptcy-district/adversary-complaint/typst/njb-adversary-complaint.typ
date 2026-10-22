// Adversary complaint for the United States Bankruptcy Court, District of New Jersey (njb).
// Rules: FRBP 7010 (form of an adversary pleading: FRCP 10, caption, numbered paragraphs); FRBP 9004(a), (b)
// (legible; caption with court, title, case and adversary number, document designation); D.N.J. LBR 9004-1(a), (b)
// (attorney block top left; chapter, judge initials and hearing date in the caption). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no face named by the rules: the house face, vendored
#let type-size = 14pt                   // convention: NJ filings in RECAP are 12 to 14 pt; see README.md
#let note-size = 11pt                   // the LBR 9004-1 caption note
#let footer-size = 12pt                 // the page number
#let margin = 1in                       // FRBP 9004: legible paper; the exemplar uses 1 inch on all sides
#let para-indent = 0.5in                // first-line indent; an allegation's number starts here ...
#let num-box = 0.5in                    // ... in a box this wide: the text starts 1 in in (docx: a tab at 1440)
#let list-indent = 0.5in                // a prayer item's letter starts half an inch in ...
#let list-box = 0.4in                   // ... in a box of its own; the text hangs at 0.9 in
#let cap-left = 3.25in                  // the caption's party column, ruled at its right and foot ...
#let cap-rule = 0.75pt                  // ... with a rule this thick ...
#let cap-pad-right = 10pt               // ... its text this far from the rule ...
#let cap-pad-below = 8pt                // ... and its last line this far above it
#let cap-right = 0.35in                 // the case column's text this far right of the rule (0.25 in gutter + 0.1 in)
#let sig-col = 3.1in                    // the signature column; "Dated:" sits left of it
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF NEW JERSEY")
#let lbr-note = "Caption in Compliance with D.N.J. LBR 9004-1"

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/njb-adversary-complaint.lua and
// docx/reference.xml set the same twips: 20 x pt).
#let pitch-body = 28pt                  // double spaced at 14 pt (docx 560)
#let pitch-single = 16pt                // counsel, court, caption, title, signature, footer (docx 320)
#let gap = 16pt                         // a blank single line: counsel to court, court to captions, caption to caption
#let text-above = 28pt                  // the title to the text: a blank double line
#let sig-above = 28pt                   // the last paragraph to the signature block
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("njb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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
#let inl(s) = unloose(cmarker.render(str(s), raw-typst: false, smart-punctuation: true))

/// A single-pitch line (one paragraph; it wraps on single lines). `above`: the space before it.
#let sline(content, above: 0pt, align-to: left) = block(width: 100%, above: above, below: 0pt,
  align(align-to, par(first-line-indent: 0pt, content)))

/// Single-pitch lines, one paragraph each.
#let lines(items, align-to: left) = for i in items { sline(inl(i), align-to: align-to) }

/// A body paragraph on the double pitch: its first line indented, `label` (a number) in a box `num-box` wide.
#let body-par(label, content, align-to: left, indent: true) = block(width: 100%, above: 0pt, below: 0pt,
  align(align-to, par(first-line-indent: if indent { para-indent } else { 0pt }, {
    if label != none { box(width: num-box, label) }
    content
  })))

/// Headings on the body pitch at the type size, with no space of their own, kept with the block after them:
/// level 1 centered bold capitals, level 3 bold italic at the margin.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, par(text(weight: "bold", upper(inl(s))))) }
  else { par(text(weight: "bold", style: "italic", inl(s))) }
})

// ---------------------------------------------------------------------------
// Cover: counsel, court, caption (page 1); the title opens page 2, as filed
// ---------------------------------------------------------------------------

/// One caption block: the left column ruled at its right and foot, the case information to the right of the rule
/// (docx: a one-row table, the left cell bordered). Grid cell strokes and insets: the rule runs the height of the
/// row, the taller of the two columns, with the space below it under both (LibreOffice takes a cell's bottom
/// margin for the whole row).
#let caption-block(left-items, right-items) = block(width: 100%, above: gap, below: 0pt, breakable: false, grid(
  columns: (cap-left, 1fr),
  stroke: (x, y) => if x == 0 { (right: cap-rule, bottom: cap-rule) },
  inset: (x, y) => if x == 0 { (right: cap-pad-right, bottom: cap-pad-below) } else {
    (left: cap-right, bottom: cap-pad-below) },
  lines(left-items), lines(right-items),
))

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  // LBR 9004-1(a): attorney of record and the party represented, top left of the first page.
  lines(meta.counsel)
  block(above: gap, below: 0pt, for l in court-name { sline(align-to: center, text(weight: "bold", l)) })
  sline(align-to: right, text(size: note-size, lbr-note))
  let hearing = if "hearing" in meta and meta.hearing != none { (meta.hearing,) } else { () }
  caption-block(("In re:",) + meta.debtor + ("Debtor.",),
    ("Case No.: " + str(meta.case_no), "Chapter " + str(meta.chapter), "Judge: " + str(meta.judge)) + hearing)
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  caption-block(rows, ("Adv. Pro. No. " + str(meta.adv_no),))
}

// ---------------------------------------------------------------------------
// Signature block: "Dated:" left of the first line, the closing, the firm, the signer and the lines in the
// signature column, single lines, a blank line after the closing and after the firm; kept whole
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = meta.signature
  let rows = ("Respectfully submitted,", "") + sig.firm + ("", "/s/ " + sig.signer) + sig.lines
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
    set text(..edges(pitch-single))
    let g = 0pt
    let first = true
    for r in rows {
      if r == "" { g += pitch-single } else {
        block(width: 100%, above: g, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
          [#box(width: sig-col, if first [Dated: #inl(meta.date)])#inl(r)]))
        g = 0pt
        first = false
      }
    }
  })
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (FRCP 10(b)), headings, the prayer and its lettered items, bracketed notes
// ---------------------------------------------------------------------------

/// One chunk: a heading ("#" or "###"), a prayer item ("N. text", lettered (a), (b), ... by its number; the letter
/// half an inch in, the text hanging), the WHEREFORE lead-in (unnumbered), a bracketed note (unnumbered, centered
/// italic), or a paragraph (numbered).
#let render-chunk(t, para) = {
  let h = t.match(regex("^(#{1,3})[ \\t]+(.*)$"))
  let item = t.match(regex("^(\\d+)\\.[ \\t]+([\\s\\S]*)$"))
  if h != none {
    heading-block(h.captures.at(0).len(), h.captures.at(1))
  } else if item != none {
    let letter = numbering("(a)", int(item.captures.at(0)))
    block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent, par(first-line-indent: 0pt,
      hanging-indent: list-box, [#box(width: list-box, letter)#inl(item.captures.at(1))])))
  } else if t.starts-with("WHEREFORE") {
    body-par(none, inl(t))
  } else if t.starts-with("[") {
    body-par(none, text(style: "italic", inl(t)), align-to: center, indent: false)
  } else {
    para.step()
    context body-par(str(para.get().first()) + ".", inl(t))
  }
}

#let adversary-complaint(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let para = counter("allegation")

  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1408"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)
  pagebreak()
  block(width: 100%, above: 0pt, below: 0pt, {
    set text(..edges(pitch-single))
    sline(align-to: center, text(weight: "bold", upper(inl(meta.title))))
  })
  v(text-above)
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
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
