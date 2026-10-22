// U.S. Bankruptcy Court, E.D. Oklahoma: brief in support of a motion (doc type `motion-brief`).
//
// Rule-driven and content-agnostic. Governing rules are cited in ../README.md and ../../rules.md:
//   LBR 9004-1(A) (paper: type size incl. footnotes, margins, double spacing of pleadings and briefs),
//   LBR 9004-1(C) and 9011-3(A) (signature block), LBR 7007-1(B) (brief length), FRBP 9013.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker, one chunk (a blank-line-separated block) at a time; the metadata comes
// from the YAML frontmatter of the same sample file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // LBR 9004-1(A) names no face; Times New Roman, the house standard and both exemplars' face (vendored metric twin)
#let type-size = 12pt                    // LBR 9004-1(A): no less than 12 point, footnotes included
#let page-margin = 1in                   // LBR 9004-1(A): margins no less than one inch
#let para-indent = 0.5in                 // first-line indent of body paragraphs; level-3 headings, quotations and bullets this far in
#let bullet-label = 0.25in               // a bullet's box, the item's text hanging after it
#let caption-left = 3.5in                // width of the debtor column of the caption
#let caption-pad = 0.2in                 // the debtor column's text this far off the rule
#let caption-gap = 0.3in                 // the number column's text this far off the rule
#let name-indent = 0.5in                 // the debtor's names
#let role-indent = 2.2in                 // "Debtor." under the names
#let signature-indent = 3.25in           // counsel, signature and certificate blocks stand this far from the left margin
#let rule = 0.75pt                       // the caption's rule
#let note-gap = 7pt                      // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt              // from the text to the footnote rule (the space LibreOffice keeps above it)
#let page-limit = 20                     // LBR 7007-1(B), 7056-1: a brief in support is at most 20 pages, exclusive of attachments

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 27.6pt               // LBR 9004-1(A): briefs double spaced; Word's double (2 x 1.15 x 12 pt)
#let pitch-single = 13.8pt               // single spacing (1.15 x 12 pt): court, caption, title, headings, quotations,
                                         // bullets, footnotes, counsel, signature

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Inline or block markdown (the body, the title, the certificate; footnote definitions folded into the chunk that
/// refers to them).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("okeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("okeb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A frontmatter value that is one string or a list of them, as a list.
#let strs(v) = if type(v) == array { v } else { (v,) }

/// Blank-line-separated chunks of markdown.
#let chunks-of(s) = s.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it. An empty line keeps
/// its height. Caption, counsel and signature strings are text, not markdown.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

/// A centered bold capitals heading, single spaced (the title, level-1 headings, the certificate's title).
#let center-heading(above: pitch-single, below: pitch-single, body) = block(width: 100%, above: above,
  below: below, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  align(center, strong(upper(body)))
})

/// A heading, single-spaced, a single line above and below it, sticky so it never ends a page: level 1 centered bold
/// capitals, level 2 bold at the margin, level 3 bold half an inch in.
#let heading-block(level, c) = if level == 1 { center-heading(c) } else {
  block(width: 100%, above: pitch-single, below: pitch-single, sticky: true, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(left: if level > 2 { para-indent } else { 0pt }, strong(c))
  })
}

/// A single-spaced block a single line above and below: a quotation (half an inch in on both sides) or a bullet
/// (the bullet half an inch in, the text hanging after it).
#let single-block(keep: false, left: para-indent, right: 0pt, hang: 0pt, body) = block(width: 100%,
  above: pitch-single, below: pitch-single, sticky: keep, breakable: not keep, pad(left: left, right: right, {
  set text(..edges(pitch-single))
  par(first-line-indent: 0pt, hanging-indent: hang, body)
}))

// ---------------------------------------------------------------------------
// Caption (both filed exemplars: the court in two bold lines; a double line below, the debtor column (3.5 in, closed
// by a rule at its right) and the number column; LBR 9004-2: the case number, the chapter under it), the title a
// double line below, and the counsel block when the filer puts one on the first page. One single line each.
// ---------------------------------------------------------------------------

#let caption(meta) = {
  line-block(align(center, strong[IN THE UNITED STATES BANKRUPTCY COURT]))
  line-block(align(center, strong[FOR THE EASTERN DISTRICT OF OKLAHOMA]))
  let left = (line-block("In re:"), line-block(""))
  for d in strs(need(meta, "debtor")) { left.push(line-block(left: name-indent, d)) }
  left.push(line-block(left: role-indent, need(meta, "debtor_role")))
  let judge = meta.at("judge", default: "")
  let right = (
    line-block("Case No. " + need(meta, "case_number") + if judge != "" { "-" + judge } else { "" }),
    line-block(above: pitch-single, "Chapter " + str(need(meta, "chapter"))),
  )
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, table(
    columns: (caption-left, 1fr), stroke: none, inset: 0pt,
    table.cell(stroke: (right: rule), inset: (right: caption-pad), left.join()),
    table.cell(inset: (left: caption-gap), right.join()),
  ))
  center-heading(above: pitch-double, md(need(meta, "title")))
  if "counsel" in meta {
    block(width: 100%, above: pitch-single, below: pitch-single, breakable: false,
      for l in meta.counsel { line-block(left: signature-indent, l) })
  }
}

// ---------------------------------------------------------------------------
// Body: blank-line-separated chunks. "#", "##", "###" headings; "N. " a numbered paragraph, numbered consecutively
// over the whole brief (the typed numbers are ignored); "> " a quotation; "- " lines a bulleted list; "* * *" a
// marked gap, centered; anything else an unnumbered paragraph, indented, double spaced. Footnote definitions
// ("[^x]: ...") go with the chunk that refers to them. The last block is kept whole with the signature block.
// ---------------------------------------------------------------------------

#let brief-body(body) = {
  let chunks = ()
  let notes = ()
  for c in chunks-of(body) {
    let m = c.match(regex("^\\[\\^([^\\]]+)\\]:"))
    if m != none { notes.push((m.captures.at(0), c)) } else { chunks.push(c) }
  }
  let n = 0
  for (k, t) in chunks.enumerate() {
    let keep = k == chunks.len() - 1
    for (label, def) in notes { if t.contains("[^" + label + "]") { t += "\n\n" + def } }
    let h = t.match(regex("^(#+)\\s+(.*)$"))
    let li = t.match(regex("^\\d+\\.[ \\t]+([\\s\\S]*)$"))
    if h != none {
      heading-block(h.captures.at(0).len(), md(h.captures.at(1)))
    } else if t.starts-with(">") {
      single-block(keep: keep, right: para-indent, md(t.replace(regex("(?m)^>[ \\t]?"), "")))
    } else if t.starts-with("- ") {
      let items = t.split(regex("\\r?\\n(?:- )")).map(i => i.replace(regex("^- "), ""))
      for (j, it) in items.enumerate() {
        single-block(keep: keep and j == items.len() - 1, hang: bullet-label,
          [#box(width: bullet-label, [•])#md(it)])
      }
    } else if t.match(regex("^\\*( *\\*){2,}$")) != none {
      // a marked gap in the text ("* * *"), centered at the body pitch
      block(width: 100%, above: 0pt, below: 0pt, sticky: keep, align(center, par(first-line-indent: 0pt, t)))
    } else {
      let text = if li != none { n += 1; [#n. #md(li.captures.at(0))] } else { md(t) }
      if keep {
        block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, [#text#parbreak()])
      } else {
        // Not a block: inside a block, typst places a footnote on a later page than its reference. The paragraph
        // break ends it (each chunk is its own paragraph).
        [#text#parbreak()]
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (LBR 9004-1(C), 9011-3(A): name, bar number, address, email, telephone, fax, party), a double line
// below the body: the dated line at the margin (if any), "Respectfully submitted," 3.25 in from the margin, a single
// line below it the electronic signature and the block; single spaced, never split.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    if "date" in meta { line-block("Dated: " + meta.date) }
    line-block(above: if "date" in meta { pitch-single } else { 0pt }, left: signature-indent,
      "Respectfully submitted,")
    line-block(above: pitch-single, left: signature-indent, "/s/ " + sig.electronic)
    for l in strs(sig.lines) { line-block(left: signature-indent, l) }
  })
}

// ---------------------------------------------------------------------------
// Certificate of service or of mailing (optional; follows the signature block, as in both exemplars), kept whole on
// one page (a short paper of its own; the trustee's exemplar sets it on a page of its own): its title a double line
// below the signature, centered bold capitals, a single line above the text; its paragraphs indented and double
// spaced, a paragraph of lines (markdown line breaks: an address) single spaced at the margin, a single line above
// and below; a single line below, the electronic signature and its block 3.25 in from the margin.
// ---------------------------------------------------------------------------

#let certificate-block(meta) = {
  if "certificate" not in meta { return }
  let c = meta.certificate
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    center-heading(above: 0pt, c.title)
    for t in chunks-of(c.body) {
      let lines = t.split(regex("\\\\\\r?\\n"))
      if lines.len() > 1 {
        block(width: 100%, above: pitch-single, below: pitch-single, for l in lines { line-block(md(l)) })
      } else {
        block(width: 100%, above: 0pt, below: 0pt, [#md(t)#parbreak()])
      }
    }
    block(width: 100%, above: pitch-single, below: 0pt, {
      line-block(left: signature-indent, "/s/ " + c.electronic)
      for l in strs(c.lines) { line-block(left: signature-indent, l) }
    })
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let okeb-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // Pages numbered at the foot, centered, in a single line box, where Word's footer sets it.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LBR 9004-1(A): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // LBR 9004-1(A): footnotes at the text size, single lines, under a 30 % rule, 7 pt between notes; the mark and a
  // space before the text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  caption(meta)
  brief-body(body)
  signature-block(meta)
  certificate-block(meta)

  // LBR 7007-1(B): the brief's length, counted in pages after the render. A failure here is a rule failure.
  context {
    let pages = counter(page).final().first()
    assert(pages <= page-limit, message: "okeb-motion-brief: LBR 7007-1(B): the brief is " + str(pages)
      + " pages; the limit is " + str(page-limit))
  }
}
