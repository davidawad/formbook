// Complaint for the U.S. District Court for the District of New Hampshire (nhd).
// Rules: LR 5.1(a) (8 1/2 x 11 paper, 12-point proportionally spaced type, one-inch margins, double spaced
// except quotations, page numbers at the bottom center); LR 5.1(b) (attorney identification in the
// signature section); LR 5.1(c) (caption, description of the filing, docket number); Fed. R. Civ. P. 8
// (short and plain statement), 10(a) (caption and title), 10(b) (numbered paragraphs, one set of
// circumstances each). See ../README.md and ../../rules.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (Times itself cannot be vendored)
#let type-size = 12pt                   // LR 5.1(a): proportionally spaced font, no less than 12 point
#let margin = 1in                       // LR 5.1(a): no less than one-inch margins
#let para-indent = 0.5in                // first-line indent; the number of a numbered paragraph stands here
#let number-box = 0.5in                 // the paragraph number's box: the text starts an inch in, as in the exemplars
#let item-indent = 0.5in                // lettered items: the letter half an inch in
#let item-box = 0.6in                   // the letter's box: the item text (and its wrapped lines) 1.1 in from the margin
#let caption-left = 3.4in               // the party column of the caption
#let caption-gutter = 0.3in             // between the party column and the case number
#let sig-indent = 3.25in                // signature block starts at the right half of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 27.6pt              // LR 5.1(a) double spacing: 2 x the single line
#let case-drop = 2 * pitch-single       // the case number stands two single lines down, beside the "v." line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nhd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it. Plain text: no markdown in
/// the caption and signature fields.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Single-spaced lines; the first `above` below the block before.
#let lines(items, above: 0pt) = for (i, l) in items.enumerate() {
  line-block(above: if i == 0 { above } else { 0pt }, [#l])
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title() = {
  line-block(align(center, strong[IN THE UNITED STATES DISTRICT COURT]))
  line-block(align(center, strong[FOR THE DISTRICT OF NEW HAMPSHIRE]))
}

#let caption(meta) = {
  // Party names and designations, one per line; "v." between the parties.
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  block(width: 100%, above: pitch-single, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    lines(rows),
    [],
    pad(top: case-drop, {
      // The case number sits beside the party block, as the filed caption does.
      line-block([#meta.case_number])
      if "jury_demand" in meta and meta.jury_demand { line-block(strong[JURY TRIAL DEMANDED]) }
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, lettered lists
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: unnumbered (first-line indent) or numbered (the number in a box after the
/// first-line indent, the text after it).
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: number-box, [#num.])#content] }))

/// Each blank-line-separated chunk of markdown is one of:
///   `#`, `##`, `###` heading (sticky: it never ends a page);
///   `1.` list (rendered as (a), (b), ... and not numbered as a paragraph);
///   `~ ` unnumbered paragraph (the jury demand and similar closing text);
///   anything else: one numbered paragraph.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else if t.starts-with("~ ") {
      body-par(none, md(t.slice(2)))
    } else {
      n += 1
      body-par(n, md(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature section (LR 5.1(b): name, address, telephone, e-mail and NH bar number)
// ---------------------------------------------------------------------------

/// Groups of single lines at the right half of the page, a blank single line between groups; a blank double line
/// above; the block never breaks across a page.
#let signature-block(meta) = {
  let sig = meta.signature
  let groups = (
    (sig.intro,),
    if "party" in sig { sig.party } else { none },
    if "date" in sig { (sig.date,) } else { none },
    ("/s/ " + sig.signer,),
    ..sig.blocks,
  ).filter(g => g != none)
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, pad(left: sig-indent, {
    for (i, g) in groups.enumerate() { lines(g, above: if i == 0 { 0pt } else { pitch-single }) }
  }))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let nhd-complaint(meta, body) = {
  // Page numbers centered at the bottom (LR 5.1(a)); the number in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch; lettered items as a label box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-box)
  // A doubled sign stays with its number ("§§ 157"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set enum(numbering: "(a)")

  // Headings at the body size and pitch, bold: level 1 centered caps; level 2 centered; level 3 flush left. No space
  // of their own (the double pitch sets them off). Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = strong(if it.level == 1 { upper(it.body) } else { it.body })
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, if it.level <= 2 { align(center, b) } else { b })
  }

  court-title()
  caption(meta)
  block(sticky: true, width: 100%, above: pitch-single, below: 0pt,
    align(center, par(first-line-indent: 0pt, strong(upper(meta.title)))))

  if "lead_in" in meta { body-par(none, md(meta.lead_in)) }

  allegations(body)

  signature-block(meta)
}
