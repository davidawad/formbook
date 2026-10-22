// Motion with supporting argument for the United States Bankruptcy Court, S.D. Indiana (insb).
// Rules: S.D.Ind. B-9013-1(a) (every request is a separate motion; it is named in the caption, states the order or
// relief sought, and contains a short and plain statement of its basis); Fed.R.Bankr.P. 9013(b) (a motion must
// state its grounds with particularity and set forth the relief requested); S.D.Ind. B-7007-1(a) (a Rule 12 motion
// needs a supporting brief, which may be combined with the motion in one document, 35-page limit); S.D.Ind. B-9013-2
// (a certificate of service accompanies a paper filed under Rule 9013 or 9014); Fed.R.Bankr.P. 9004(a) (clearly
// legible); S.D.Ind. B-5005-3 (no larger than 8-1/2 x 11). The S.D.Ind. Local Rules set no font, margin or line
// spacing: those are layout choices, marked as such in ../README.md.
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or is a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")      // layout choice: no S.D.Ind. font rule; Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                 // layout choice: the Rule 9004(a) legibility floor is the only requirement
#let page-w = 8.5in                   // S.D.Ind. B-5005-3: no larger than 8-1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                     // layout choice
#let footer-distance = 0.5in          // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in              // first-line indent of body paragraphs
#let caption-left = 3.4in             // width of the party column of the caption
#let caption-gutter = 0.2in           // between the party column's rule and the right column
#let caption-pad-right = 10pt         // the party column's text stands this far from its right rule
#let caption-pad-bottom = 8pt         // and this far above its bottom rule
#let caption-right-pad = 0.1in        // the right column's text stands this far in
#let caption-rule = 0.75pt
#let quote-left = 1in                 // block quotations: indented 1 in at the left, 0.5 in at the right
#let quote-right = 0.5in
#let sig-left = 3in                   // the signature lines start 3 in from the margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/insb.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 27.6pt              // layout choice: double spacing, matching the filed exemplar (27.6 pt baseline pitch, measured)
#let pitch-single = 13.8pt            // single spacing: court title, caption, block quotations, signature
#let cover-gap = 27.6pt               // court title to caption, caption to title, title to the body
#let heading-gap = 13.8pt             // above and below a heading (half a double line)
#let quote-gap = 13.8pt               // above, between and below the paragraphs of a block quotation
#let sig-gap = 13.8pt                 // the date line to the signature lines

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("insb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown (for names with *et al.*, etc.).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-pitch line (a paragraph of its own), with an explicit space above it; "" is a blank line.
#let sline(above: 0pt, left: 0pt, centered: false, c) = if c == "" {
  block(width: 100%, height: pitch-single, above: above, below: 0pt)
} else {
  block(width: 100%, above: above, below: 0pt, {
    set text(..edges(pitch-single))
    set align(center) if centered
    pad(left: left, par(first-line-indent: 0pt, if type(c) == str { unloose(md(c)) } else { c }))
  })
}

/// Single-pitch lines, one paragraph each.
#let slines(items, left: 0pt) = for i in items { sline(left: left, i) }

/// A body paragraph on the body pitch: `first` its first-line indent.
#let body-par(above: 0pt, below: 0pt, first: para-indent, sticky: false, centered: false, c) = block(width: 100%,
  above: above, below: below, sticky: sticky, {
    set align(center) if centered
    par(first-line-indent: (amount: first, all: true), unloose(c))
  })

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (B-9013-1(a): the request is named in the caption)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let ls = ([UNITED STATES BANKRUPTCY COURT], [SOUTHERN DISTRICT OF INDIANA])
  if "division" in meta and meta.division != none { ls.push(upper(meta.division) + " DIVISION") }
  for l in ls { sline(centered: true, text(weight: "bold", l)) }
}

/// The bankruptcy caption: the debtor in the party column, ruled at its right and foot; the case number and chapter
/// on the right (docx: a table row).
#let bankruptcy-caption(meta) = block(width: 100%, above: cover-gap, below: 0pt, grid(
  columns: (caption-left, caption-gutter, 1fr),
  stroke: (x, y) => if x == 0 { (right: caption-rule, bottom: caption-rule) },
  inset: (x, y) => if x == 0 { (right: caption-pad-right, bottom: caption-pad-bottom) } else { (bottom: caption-pad-bottom) },
  slines(("In re:", "") + meta.debtor.names + (meta.debtor.designation,)),
  [],
  pad(left: caption-right-pad, slines(("Case No. " + meta.case_number, "Chapter " + meta.chapter))),
))

#let cover(meta) = {
  court-title(meta)
  bankruptcy-caption(meta)
  body-par(above: cover-gap, below: cover-gap, first: 0pt, centered: true, sticky: true, text(weight: "bold", md(meta.title)))
}

// ---------------------------------------------------------------------------
// Body, signature and certificate of service
// ---------------------------------------------------------------------------

/// The date line and the signature lines from `sig-left`, kept on one page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
  if "date_line" in meta and meta.date_line != none { body-par(md(meta.date_line)) }
  block(width: 100%, above: sig-gap, below: 0pt,
    slines(("/s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines, left: sig-left))
})

/// A block quotation: single-spaced, indented on both sides, not indented on the first line; a blank single line
/// between its paragraphs.
#let quotation(t) = {
  let ps = t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).filter(s => s.trim() != "")
  for q in ps {
    block(width: 100%, above: quote-gap, below: quote-gap, pad(left: quote-left, right: quote-right, sline(q.trim())))
  }
}

/// Body chunks, each separated by a blank line in the sample:
///   `#` heading                    centered (level 1) or bold (level 2); kept with the next chunk
///   `> ...`                         block quotation, indented both sides, not indented on the first line
///   `Id.` or a digit first          a citation line that continues after a block quotation: flush left
///   anything else                   paragraph, first-line indent (motions are not numbered)
#let argument(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for (i, t) in chunks.enumerate() {
    // the last chunk is kept with the signature after it: a signature never stands alone on a page
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      quotation(t)
    } else if t.match(regex("^(Id\\.|[0-9])")) != none {
      body-par(first: 0pt, sticky: last, md(t))
    } else {
      body-par(sticky: last, md(t))
    }
  }
}

/// The certificate of service (B-9013-2) on a page of its own, as the filed exemplar sets it: the title, the text,
/// the signer's lines from `sig-left`.
#let certificate(meta) = {
  pagebreak(weak: true)
  sline(centered: true, text(weight: "bold", [CERTIFICATE OF SERVICE]))
  body-par(above: cover-gap, md(meta.certificate.text))
  block(width: 100%, above: cover-gap, below: 0pt,
    slines(("/s/ " + meta.certificate.signer,) + meta.certificate.lines, left: sig-left))
}

#let insb-motion-brief(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    numbering: none,
    // The page number centered at the foot of every page from page 1, in a single-pitch line box that ends
    // footer-distance above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings at the type size on the body pitch, half a double line above and below, kept with the text after
  // them: level 1 centered bold capitals, level 2 bold at the margin (docx: the same paragraphs).
  show heading: it => block(width: 100%, above: heading-gap, below: heading-gap, sticky: true, {
    set text(size: type-size, weight: "bold")
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, upper(it.body)) } else { it.body }
  })

  cover(meta)
  argument(body)
  signature-block(meta)
  if "certificate" in meta and meta.certificate != none {
    certificate(meta)
  }
}
