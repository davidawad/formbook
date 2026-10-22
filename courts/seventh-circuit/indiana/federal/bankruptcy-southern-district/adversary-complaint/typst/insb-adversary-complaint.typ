// Adversary complaint for the United States Bankruptcy Court, S.D. Indiana (insb).
// Rules: Fed.R.Bankr.P. 7010 (Fed.R.Civ.P. 10 applies: the caption, and numbered paragraphs under Rule 10(b));
// Fed.R.Bankr.P. 7008 (the jurisdiction allegation names the case, its number and chapter, and the district and
// division; the pleader states whether it consents to final orders); Fed.R.Bankr.P. 9004(a) (clearly legible);
// S.D.Ind. B-5005-3 (papers no larger than 8-1/2 x 11). The S.D.Ind. Local Rules set no font, margin or line
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
#let para-indent = 0.5in              // first-line indent of numbered allegations; a paragraph number starts here
#let number-box = 0.5in               // an allegation's number in a box after the indent: its text starts 1 in from the margin
#let label-box = 0.6in                // a lettered item's label "(a)" in a box after the indent; its lines hang at 1.1 in
#let caption-left = 3.4in             // width of the party column of each caption
#let caption-gutter = 0.2in           // between the party column's rule and the right column
#let caption-pad-right = 10pt         // the party column's text stands this far from its right rule
#let caption-pad-bottom = 8pt         // and this far above its bottom rule
#let caption-right-pad = 0.1in        // the right column's text stands this far in
#let caption-rule = 0.75pt
#let quote-left = 1in                 // block quotations: indented 1 in at the left, 0.5 in at the right
#let quote-right = 0.5in
#let sig-col = 2.8in                  // signature: "Dated:" in a 2.6 in column and a 0.2 in gutter, the firm and signer after it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/insb.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 27.6pt              // layout choice: double spacing, matching the filed exemplar (27.6 pt baseline pitch, measured)
#let pitch-single = 13.8pt            // single spacing: court title, captions, title, block quotations, signature
#let cover-gap = 27.6pt               // court title to the bankruptcy caption, the adversary caption to the title, the title to the lead-in
#let caption-gap = 13.8pt             // between the bankruptcy and the adversary caption
#let heading-gap = 13.8pt             // above and below a heading (half a double line)
#let quote-gap = 13.8pt               // above, between and below the paragraphs of a block quotation
#let sig-above = 27.6pt               // the last paragraph to the signature block
#let sig-gap = 13.8pt                 // the firm to "By: /s/"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("insb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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
#let sline(above: 0pt, centered: false, c) = if c == "" {
  block(width: 100%, height: pitch-single, above: above, below: 0pt)
} else {
  block(width: 100%, above: above, below: 0pt, {
    set text(..edges(pitch-single))
    set align(center) if centered
    par(first-line-indent: 0pt, if type(c) == str { unloose(md(c)) } else { c })
  })
}

/// Single-pitch lines, one paragraph each.
#let slines(items) = for i in items { sline(i) }

// ---------------------------------------------------------------------------
// Cover: court title, bankruptcy caption, adversary caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let ls = ([UNITED STATES BANKRUPTCY COURT], [SOUTHERN DISTRICT OF INDIANA])
  if "division" in meta and meta.division != none { ls.push(upper(meta.division) + " DIVISION") }
  for l in ls { sline(centered: true, text(weight: "bold", l)) }
}

/// A caption: the party column ruled at its right and foot, the numbers beside it (docx: a table row).
#let caption-grid(above, left, right) = block(width: 100%, above: above, below: 0pt, grid(
  columns: (caption-left, caption-gutter, 1fr),
  stroke: (x, y) => if x == 0 { (right: caption-rule, bottom: caption-rule) },
  inset: (x, y) => if x == 0 { (right: caption-pad-right, bottom: caption-pad-bottom) } else { (bottom: caption-pad-bottom) },
  slines(left),
  [],
  pad(left: caption-right-pad, slines(right)),
))

/// The bankruptcy caption: the debtor in the left column, the case number and chapter on the right.
#let bankruptcy-caption(meta) = caption-grid(cover-gap,
  ("In re:", "") + meta.debtor.names + (meta.debtor.designation,),
  ("Case No. " + meta.case_number, "Chapter " + meta.chapter))

/// The adversary caption: each party, then its designation; "v." between the parties.
#let adversary-caption(meta) = {
  let rows = ()
  for (k, p) in meta.adversary.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let number = if meta.adversary.adv_number == "" { "Adv. Pro. No. ____________" } else { "Adv. Pro. No. " + meta.adversary.adv_number }
  caption-grid(caption-gap, rows, (number,))
}

#let cover(meta) = {
  court-title(meta)
  bankruptcy-caption(meta)
  adversary-caption(meta)
  sline(above: cover-gap, centered: true, text(weight: "bold", unloose(md(meta.title))))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A body paragraph on the body pitch: `first` its first-line indent, `hang` the indent of its other lines.
#let body-par(above: 0pt, first: para-indent, hang: 0pt, sticky: false, centered: false, c) = block(width: 100%,
  above: above, below: 0pt, sticky: sticky, {
    set align(center) if centered
    par(first-line-indent: (amount: first, all: true), hanging-indent: hang, unloose(c))
  })

/// The signature block, single-spaced and kept on one page: "Dated:" at the left of the first line, the firm,
/// "By: /s/", the signer in capitals and the counsel lines in a column from `sig-col` (docx: a tab and a hanging
/// indent there).
#let signature-block(meta) = {
  let sig = meta.signature
  let lines = sig.firm.map(l => (l, 0pt))
  lines.push(("By: /s/ " + sig.signer, if sig.firm.len() > 0 { sig-gap } else { 0pt }))
  lines.push((upper(sig.signer), 0pt))
  lines += sig.lines.map(l => (l, 0pt))
  block(width: 100%, breakable: false, above: sig-above, below: 0pt, {
    set text(..edges(pitch-single))
    for (i, (l, gap)) in lines.enumerate() {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if i == 0 [Dated: #meta.date])#unloose(md(l))]))
    }
  })
}

/// A block quotation: single-spaced, indented on both sides, not numbered; a blank single line between its
/// paragraphs.
#let quotation(t) = {
  let ps = t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).filter(s => s.trim() != "")
  for q in ps {
    block(width: 100%, above: quote-gap, below: quote-gap, pad(left: quote-left, right: quote-right, sline(q.trim())))
  }
}

/// Body chunks, each separated by a blank line in the sample:
///   `#` heading                    centered (level 1) or bold (level 2); kept with the next chunk
///   `(a) ...` / `(1) ...`           labeled sub-item, the label kept, hanging indent, not numbered
///   `> ...`                         block quotation, single spaced, indented both sides, not numbered
///   `[...]`                         centered bracketed note, not numbered
///   `WHEREFORE ...`                 prayer paragraph, indented, not numbered, kept with the items after it
///   starts with a lowercase letter  continues the paragraph before it, not numbered
///   anything else                   numbered allegation (Fed.R.Civ.P. 10(b)); the count runs through the body
/// Numbering is per chunk, not a `show par` rule (that recurses without end in typst 0.15).
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  for t in chunks {
    let labeled = t.match(regex("^\\(([a-z]+|[0-9]+)\\)[ \t]+"))
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      quotation(t)
    } else if t.starts-with("[") {
      body-par(first: 0pt, centered: true, md(t))
    } else if labeled != none {
      let label = "(" + labeled.captures.at(0) + ")"
      body-par(first: 0pt, hang: para-indent + label-box, [#h(para-indent)#box(width: label-box, label)#unloose(md(t.slice(labeled.end)))])
    } else if t.starts-with("WHEREFORE") {
      body-par(sticky: true, md(t))
    } else if t.match(regex("^[a-z]")) != none {
      // Continues the paragraph before it (e.g. the total after a lettered list): not numbered, no indent.
      body-par(first: 0pt, md(t))
    } else {
      n += 1
      body-par([#box(width: number-box, [#n.])#unloose(md(t))])
    }
  }
}

#let insb-adversary-complaint(meta, body) = {
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
  // A doubled sign stays with its number too ("§§ 1334(b)"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings at the type size on the body pitch, half a double line above and below, kept with the text after
  // them: level 1 centered bold capitals, level 2 bold at the margin (docx: the same paragraphs).
  show heading: it => block(width: 100%, above: heading-gap, below: heading-gap, sticky: true, {
    set text(size: type-size, weight: "bold")
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, upper(it.body)) } else { it.body }
  })

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none { body-par(above: cover-gap, md(meta.lead_in)) }

  allegations(body)

  signature-block(meta)
}
