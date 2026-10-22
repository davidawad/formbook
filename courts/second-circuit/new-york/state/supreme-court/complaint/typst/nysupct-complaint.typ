// Supreme Court of the State of New York: verified complaint.
//
// Rules: 22 NYCRR 202.5(a) (print no smaller than 12-point, footnotes no smaller than 10-point, double spacing
// except quotations and the names and addresses of attorneys, letter paper, margins no smaller than one inch, the
// index number to the right of the caption), CPLR 2101 (form of papers; the signer's name printed beneath the
// signature), CPLR 3020 and 2106 (verification). Requirement IDs refer to ../README.md and ../../rules.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter and body, never from this file. No
// coordinates measured off the filed complaint, no forced line breaks.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // 202.5(a) and CPLR 2101(a) name no typeface; Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt              // NYSUPCT-FORM-003: 22 NYCRR 202.5(a) print no smaller than 12-point
#let note-size = 10pt              // NYSUPCT-FORM-003: 22 NYCRR 202.5(a) footnotes no smaller than 10-point
#let page-margin = 1in             // NYSUPCT-FORM-004: 22 NYCRR 202.5(a) margins no smaller than one inch
#let footer-distance = 0.5in       // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in           // convention: paragraphs begin with a first-line indent
#let caption-box = 3.6in           // the bordered party box at the left of the caption
#let caption-gutter = 0.2in        // the party box's text from its sides, and the box to the right column
#let quote-indent = 0.5in          // block quotations: indented on both sides
#let toc-indent = 0.4in            // contents: a level 2 entry this far in
#let toc-hang = 0.4in              // contents: an entry's later lines this far under its first
#let toc-col = 0.5in               // contents: the page column the rows wrap before
#let lead-slack = 4pt              // a row keeps its last word before the leader only with this much to spare (LibreOffice
                                   // wants about 4 pt free after the leader's three spaces; docs/EVAL-LOOP.md)
#let sig-col = 3.2in               // the signature column at the right
#let rule-short = 0.6in            // the "By:" rule ends this far before the signature column's right edge
#let toc-depth = 2

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/nysupct-complaint.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 24pt             // NYSUPCT-FORM-002: 22 NYCRR 202.5(a) double-spaced, two 12 pt lines
#let pitch-single = 13.8pt         // caption, headings, quotations, contents, signature block (202.5(a) excepts
                                   // quotations and the names and addresses of attorneys): Word's 1.15 x 12 pt
#let pitch-note = 11.5pt           // footnote lines: single spacing at 10 pt
#let gap = 24pt                    // a blank double line: caption to text, before the signature, the service list
#let heading-gap = 12pt            // above and below a heading, above and below a block quotation
#let note-gap = 6pt                // after each footnote (Word: Footnote Text's space after)
#let note-clearance = 7.8pt        // the text to the footnote rule

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nysupct-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nysupct-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown (italics etc.).
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Single-spaced lines, one paragraph each; "" is a blank single line. `above`: space above the first line.
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  for (k, i) in items.enumerate() {
    let a = if k == 0 { above } else { 0pt }
    if i == "" { block(width: 100%, above: a, below: 0pt, height: pitch-single) }
    else { block(width: 100%, above: a, below: 0pt, if type(i) == str { inl(i) } else { i }) }
  }
}

// ---------------------------------------------------------------------------
// Caption (NYSUPCT-FORM-006, NYSUPCT-CONT-001): court, county, the party box, the index number and the title
// ---------------------------------------------------------------------------

#let caption-block(meta) = {
  let parties = need(meta, "parties")
  line-stack((
    align(center, strong[SUPREME COURT OF THE STATE OF NEW YORK]),
    strong(inl(need(meta, "county"))),
  ))
  // The party box: a blank single line inside its top and bottom rules; the names 0.2 in from its sides; a blank
  // single line, "-against-" and a blank single line between the sides; each side's designation at the right, a
  // blank single line under its names.
  let left = ("",)
  for (i, group) in parties.enumerate() {
    if i > 0 { left += ("", align(center, emph[-against-]), "") }
    left += group.names.map(n => pad(left: caption-gutter, right: caption-gutter, inl(n)))
    left += ("", pad(right: caption-gutter, align(right, inl(group.designation))))
  }
  left.push("")
  let right = ("", need(meta, "index_no"))
  if "judge" in meta { right.push(meta.judge) }
  if "motion_seq" in meta { right.push(meta.motion_seq) }
  right += ("", "", strong(inl(need(meta, "title"))))
  block(width: 100%, above: heading-gap, below: 0pt, breakable: false, grid(
    columns: (caption-box, 1fr),
    stroke: (x, y) => if x == 0 { (top: 0.75pt, right: 0.75pt, bottom: 0.75pt) } else { none },
    line-stack(left),
    pad(left: caption-gutter, line-stack(right)),
  ))
}

// ---------------------------------------------------------------------------
// Table of contents (levels 1 and 2; the author types the headings' numbering)
// ---------------------------------------------------------------------------

#let toc-section() = {
  block(width: 100%, above: gap, below: heading-gap, sticky: true, {
    set text(..edges(pitch-single))
    align(center, strong[TABLE OF CONTENTS])
  })
  context {
    set text(..edges(pitch-single))
    for hd in query(heading) {
      if hd.level > toc-depth { continue }
      let ind = (hd.level - 1) * toc-indent
      let pg = numbering("1", ..counter(page).at(hd.location()))
      listing-row(hd.location(), [#h(ind)#hd.body#h(lead-slack)], pg, toc-col, ind + toc-hang, 0pt)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (CPLR 2101(a): dated, signed, the signer's name printed beneath) and service list
// ---------------------------------------------------------------------------

#let rule-line(c, top: false) = block(width: 100%, above: 0pt, below: 0pt,
  stroke: if top { (top: 0.5pt) } else { (bottom: 0.5pt) }, c)

#let dated(meta) = if "place" in meta {
  ("Dated:", meta.place, need(meta, "date"))
} else { ("Dated: " + need(meta, "date"),) }

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let right = ("Respectfully submitted,", "")
  if "firm" in sig { right += sig.firm + ("",) }
  right += (pad(right: rule-short, rule-line[By:]), inl(sig.signer))
  right += sig.at("lines", default: ()).map(l => emph(inl(l)))
  block(width: 100%, above: gap, below: 0pt, breakable: false, grid(
    columns: (1fr, sig-col),
    line-stack(dated(meta)),
    line-stack(right),
  ))
}

#let service-block(meta) = {
  if "to" not in meta { return }
  let lines = ("To:",)
  for group in meta.to {
    lines += ("",) + group.names + group.lines.map(l => emph(inl(l)))
  }
  block(width: 100%, above: gap, below: 0pt, breakable: false, line-stack(lines))
}

// ---------------------------------------------------------------------------
// Verification (CPLR 3020(a), 2106: an affirmation under the penalties of perjury), on a page of its own
// ---------------------------------------------------------------------------

#let verification-block(meta) = {
  let ver = need(meta, "verification")
  pagebreak()
  block(width: 100%, above: 0pt, below: gap, sticky: true, {
    set text(..edges(pitch-single))
    align(center, strong[VERIFICATION])
  })
  block(width: 100%, above: 0pt, below: 0pt, par[#inl(ver.verifier), #inl(ver.capacity), affirms under the
    penalties of perjury under the laws of New York, which may include a fine or imprisonment, that the foregoing
    #inl(need(meta, "title")) is true to the knowledge of the affirmant, except as to matters alleged on information
    and belief, and as to those matters the affirmant believes them to be true. The affirmant understands that this
    document may be filed in an action or proceeding in a court of law.])
  block(width: 100%, above: gap, below: 0pt, breakable: false, {
    line-stack(("Dated: " + need(meta, "date"), "", ""))
    grid(columns: (1fr, sig-col), [], line-stack((rule-line(top: true, inl(ver.verifier)),)))
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let nysupct-complaint(meta, body) = {
  let title = need(meta, "title")
  let _ = need(meta, "parties")

  set document(title: title)
  set page(
    paper: "us-letter",
    margin: page-margin,
    // the page number centered at the foot, 12 pt, in a single-pitch line box that ends footer-distance above the
    // page edge
    footer-descent: page-margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number; list labels in a half-inch box.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled sign stays with its number ("§§ 1331"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // Lists: the label half an inch in (the paragraph indent), the text an inch in.
  show enum: it => pad(left: para-indent, it)
  show list: it => pad(left: para-indent, it)

  // Headings, single-spaced and kept with the text after them (the author types the numbering): level 1 centered
  // bold; level 2 bold; level 3 bold italic.
  show heading: it => block(width: 100%, above: heading-gap, below: heading-gap, sticky: true, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(it.body)) }
    else if it.level == 2 { par(strong(it.body)) }
    else { par(strong(emph(it.body))) }
  })

  // Footnotes at the 10-point minimum (202.5(a)), single-spaced; the mark, a space, the note.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    block(breakable: false)[#super(num) #note.body]
  }

  // Block quotations: single-spaced (202.5(a) excepts quotations), indented on both sides.
  show quote.where(block: true): it => block(width: 100%, above: heading-gap, below: heading-gap,
    pad(left: quote-indent, right: quote-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      it.body
    }))

  // Links print as their text.
  show link: it => text(fill: black, it.body)

  caption-block(meta)

  if meta.at("toc", default: false) {
    toc-section()
    pagebreak()
  }

  // The body, rendered from markdown, a blank double line under the caption.
  block(width: 100%, above: gap, below: 0pt, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  signature-block(meta)
  service-block(meta)
  verification-block(meta)
}
