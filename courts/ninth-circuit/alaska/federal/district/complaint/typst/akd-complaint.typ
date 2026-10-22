// Complaint for the United States District Court for the District of Alaska (akd).
// Rules: D. Alaska Local Civil Rule 7.5(a) (double-spaced; margins of at least 1 inch, footers included;
// a page number and a footer with the case name and number on every page of a multi-page document;
// at least 13-point proportionally spaced font), 7.5(b) (first-page layout: attorney block, court title,
// case number with the judge's initials, caption, document title), 7.5(c) (signature page), 8.1(a)
// (statute under the title), 8.1(b) (jurisdictional statement at the start of the body), 10.1 (form of
// pleadings: 7.5 and 8.1). Fed. R. Civ. P. 8(a) and 10(a)-(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // L.R. 7.5(a)(1)(D): proportionally spaced; vendored in fonts/
#let type-size = 13pt                   // L.R. 7.5(a)(1)(D): at least 13-point
#let para-indent = 0.5in                // first-line indent; a paragraph's number stands here
#let number-box = 0.5in                 // the paragraph number's box: the text starts an inch in
#let item-indent = 0.5in                // prayer items: the letter half an inch in
#let item-box = 0.5in                   // the letter's box: the item's text hangs an inch in
#let margin = 1in                       // L.R. 7.5(a)(1)(B): at least 1 inch around all text, footers included
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 8pt               // between the caption's rule and the case number
#let caption-inset = 8pt                // the party text stands off the rule (right and below)
#let court-drop = 0.8in                 // L.R. 7.5(b)(2): the court title at least half an inch below the counsel block
#let sig-indent = 2.5in                 // the signature block, right of centre
#let verify-indent = 3in                // the verification's signature line

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 30pt                // L.R. 7.5(a)(1)(A): double-spaced, twice the single pitch
#let pitch-single = 15pt                // counsel block, caption, quotations, footnotes, signature, footer: 1.15 x 13 pt
#let half-gap = 15pt                    // between the title and the text, around quotations, between caption parties
#let small-gap = 6pt                    // between a party's names and its designation
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt             // from the text to the footnote rule (the space LibreOffice keeps above it)
#let footer-gap = 6pt                   // between the text area and the footer (three 15 pt lines, in the bottom margin)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("akd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field; a missing one fails the build with its name.
#let need(meta, k) = {
  if k not in meta { panic("akd-complaint: the sample frontmatter needs `" + k + "`") }
  meta.at(k)
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// A double-spaced paragraph with a first-line indent.
#let body-par(above: 0pt, content) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// Lettered list items (a), (b), ... for the prayer for relief and other lists.
#let lettered(..nums) = "(" + str.from-unicode(96 + nums.pos().first()) + ")"

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Footer on every page: page number, then the case name and the case number (L.R. 7.5(a)(1)(C)), single lines,
/// inside the 1-inch margin (L.R. 7.5(a)(1)(B): the margin is kept around the footer too).
#let running-footer(meta) = context {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: 0pt)
  line-block(align(center, counter(page).display()))
  line-block(align(center, inl(need(meta, "footer_title"))))
  line-block(align(center)[Case No. #need(meta, "case_number")])
}

// ---------------------------------------------------------------------------
// Cover: counsel block, court title, caption, title (L.R. 7.5(b))
// ---------------------------------------------------------------------------

#let cover(meta) = {
  // Counsel block, upper left, single-spaced (L.R. 7.5(b)(1)(A)): name, bar number, firm, address, telephone,
  // e-mail, then the party the attorney represents (L.R. 7.5(b)(1)(C)).
  for l in need(meta, "counsel") { line-block(inl(l)) }
  // Court title, centered, one line per entry (L.R. 7.5(b)(2)).
  for (i, l) in need(meta, "court").enumerate() {
    line-block(above: if i == 0 { court-drop } else { 0pt }, align(center, strong(upper(l))))
  }
  // Caption: parties on the left, closed by a rule on the right and bottom; the case number (with the judge's
  // initials, L.R. 7.5(b)(3)(B)) on the right, beside the parties.
  let sides = need(meta, "caption")
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-inset), {
      for (i, s) in sides.enumerate() {
        for (j, n) in s.names.enumerate() { line-block(above: if i > 0 and j == 0 { half-gap } else { 0pt }, inl(n)) }
        line-block(above: small-gap, align(right, inl(s.designation)))
      }
    }),
    line-block[Case No. #need(meta, "case_number")],
  ))
  // Document title, centered and bold, with the statute under it (L.R. 8.1(a)) and an optional oral-argument
  // legend (L.R. 7.1(f)).
  line-block(above: pitch-double, align(center, strong(upper(need(meta, "title")))))
  if "statute" in meta { line-block(align(center)[(#meta.statute)]) }
  if meta.at("oral_argument", default: false) { line-block(align(center, strong[Oral Argument Requested])) }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Footnote definitions are `[^key]: text` chunks; they are removed from the body and returned by key.
#let split-footnotes(body) = {
  let defs = (:)
  let kept = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1).trim()) } else { kept.push(c) }
  }
  (kept.join("\n\n"), defs)
}

/// One paragraph's inline markdown. Each `[^key]` marker becomes a typst footnote whose text is its definition.
#let para-content(t, defs) = {
  let pos = 0
  let out = []
  for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
    let k = m.captures.at(0)
    assert(k in defs, message: "akd-complaint: footnote [^" + k + "] has no definition in the sample")
    out += inl(t.slice(pos, m.start))
    out += footnote(inl(defs.at(k)))
    pos = m.end
    // a space after the mark stays (each piece is rendered on its own, which trims it)
    if t.slice(pos).starts-with(regex("\\s")) { out += [ ] }
  }
  out + inl(t.slice(pos))
}

/// Headings at the body size in a double line, centered and bold: level 1 numbered I., II., ... in capitals.
/// Sticky: a heading never ends a page.
#let heading-rule(it) = {
  set text(size: type-size)
  set par(first-line-indent: 0pt)
  let b = if it.level == 1 {
    upper([#numbering("I.", ..counter(heading).at(it.location()).slice(0, 1)) #it.body])
  } else { it.body }
  block(sticky: true, width: 100%, above: 0pt, below: 0pt, align(center, strong(b)))
}

/// Render the body. A chunk is a heading (starts with #), a list (starts with a number and a dot, or a bullet), a
/// block quotation (starts with >) or a paragraph; paragraphs are numbered 1, 2, ... (Fed. R. Civ. P. 10(b)).
/// Headings and lists are not numbered.
#let render-body(body) = {
  let (text-body, defs) = split-footnotes(body)
  let chunks = text-body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    // The last block is kept with the signature block, so the signature never stands on a page alone.
    show: if i == chunks.len() - 1 { it => block(sticky: true, breakable: false, above: 0pt, below: 0pt, it) } else { it => it }
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      // L.R. 7.5(a)(1)(A): quotations single-spaced and indented
      block(width: 100%, above: half-gap, below: half-gap, inset: (left: para-indent, right: para-indent), {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        para-content(t.split(regex("\\r?\\n")).map(l => l.trim-start(">").trim()).join("\n"), defs)
      })
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else {
      n += 1
      body-par([#box(width: number-box, [#n.])#para-content(t, defs)])
    }
  }
}

/// Jury demand under the body, when the sample asks for one (Fed. R. Civ. P. 38(b)).
#let jury-demand(meta) = if meta.at("jury_demand", default: false) {
  block(sticky: true, width: 100%, above: pitch-double, below: 0pt, align(center, strong[DEMAND FOR JURY TRIAL]))
  body-par[Plaintiff demands a trial by jury on all issues so triable.]
}

/// Date line and signature block (L.R. 7.5(c)(1)-(2)), single-spaced, set in the right half of the page; never
/// split across a page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, {
    if "date" in meta { line-block(pad(left: para-indent, inl(meta.date))) }
    let lines = (strong(sig.firm),)
    if "role" in sig { lines.push(inl(sig.role)) }
    for (j, l) in lines.enumerate() { line-block(above: if j == 0 { half-gap } else { 0pt }, pad(left: sig-indent, l)) }
    line-block(above: half-gap, pad(left: sig-indent)[/s/ #sig.signer])
    line-block(pad(left: sig-indent, sig.signer))
    if "bar" in sig { line-block(pad(left: sig-indent, sig.bar)) }
  })
}

/// Verification page (the plaintiff's verification of the factual allegations), when the sample has one.
#let verification(meta) = if "verification" in meta {
  let v = meta.verification
  pagebreak(weak: true)
  block(sticky: true, width: 100%, above: 0pt, below: 0pt, align(center, strong(upper(inl(v.heading)))))
  body-par(above: half-gap, inl(v.text))
  if "date" in v { line-block(above: half-gap, pad(left: para-indent, inl(v.date))) }
  block(width: 100%, above: pitch-double * 2, below: 0pt, breakable: false, pad(left: verify-indent, {
    block(width: 100%, above: 0pt, below: 0pt, stroke: (top: 0.5pt), line-block(inl(v.signer)))
  }))
}

// ---------------------------------------------------------------------------
// The pleading
// ---------------------------------------------------------------------------

#let akd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "case_number", "footer_title", "caption", "counsel", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  // L.R. 7.5(a)(2)(A): letter size; 1-inch margins (L.R. 7.5(a)(1)(B)), the footer in the bottom margin, its top
  // footer-gap below the text area (Word: the footer 21 pt above the page foot).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: footer-gap,
    footer: running-footer(meta),
  )
  set document(
    title: need(meta, "title") + ", Case No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch; prayer items as a label box (item-box) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-box)
  // A doubled sign stays with its number ("§§ 701"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set heading(numbering: "I.")
  show heading: heading-rule
  set enum(numbering: lettered)              // prayer items are lettered (a), (b), ...
  // Footnotes at the text size, single lines, under a 30 % rule, 7 pt between notes; the mark and a space before the
  // text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  cover(meta)
  if "opening" in meta { body-par(above: half-gap, inl(meta.opening)) }
  render-body(body)
  jury-demand(meta)
  signature-block(meta)
  verification(meta)
}
