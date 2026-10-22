// Motion to dismiss with accompanying memorandum of law for the U.S. District Court for the District of
// New Hampshire (nhd). Rules: LR 7.1(a) (the word "motion" in the title; memorandum with the motion),
// LR 7.1(a)(3) (25-page limit for a dispositive memorandum), LR 7.1(g) (a Rule 12(b) motion is dispositive);
// LR 5.1(a) (8 1/2 x 11 paper, 12-point proportionally spaced type, one-inch margins, double spaced except
// quotations, page numbers at the bottom center); LR 5.1(b) (attorney identification in the signature
// section); LR 5.1(c) (caption, description of the filing, docket number with the judge's initials);
// LR 5.1(d) and Fed. R. Civ. P. 5(d)(1) (certificate of service). See ../README.md and ../../rules.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (Times itself cannot be vendored)
#let type-size = 12pt                   // LR 5.1(a): proportionally spaced font, no less than 12 point
#let margin = 1in                       // LR 5.1(a): no less than one-inch margins
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let item-indent = 0.5in                // lettered items: the letter half an inch in
#let item-box = 0.6in                   // the letter's box: the item text (and its wrapped lines) 1.1 in from the margin
#let heading-step = 0.5in               // level 3 headings stand 0.5 in in, level 4 headings 1 in
#let caption-names = 3.7in              // the caption's party column
#let caption-paren = 0.3in              // the column of ")" marks
#let sig-indent = 3.25in                // signature block starts at the right half of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 27.6pt              // LR 5.1(a) double spacing: 2 x the single line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nhd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it. Plain text: no markdown in
/// the caption, signature and certificate fields.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Single-spaced lines; the first `above` below the block before.
#let lines(items, above: 0pt) = for (i, l) in items.enumerate() {
  line-block(above: if i == 0 { above } else { 0pt }, [#l])
}

/// A body paragraph at the double pitch, with the first-line indent.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title() = {
  line-block(align(center, strong[IN THE UNITED STATES DISTRICT COURT]))
  line-block(align(center, strong[FOR THE DISTRICT OF NEW HAMPSHIRE]))
}

/// The caption: party names on the left, a column of ")" marks, and the docket number beside the
/// middle line. Each row is one single line, so the column of ")" marks lines up with the names.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let mid = calc.floor(rows.len() / 2)
  let cells = ()
  for (i, r) in rows.enumerate() {
    cells.push(line-block([#r]))
    cells.push(line-block([)]))
    cells.push(if i == mid { line-block([#meta.case_number]) } else { [] })
  }
  block(width: 100%, above: pitch-single, below: 0pt,
    grid(columns: (caption-names, caption-paren, 1fr), ..cells))
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs (unnumbered), lettered lists
// ---------------------------------------------------------------------------

/// Body text. Each blank-line-separated chunk of markdown is one of:
///   `#` to `####` heading (level 1 centered; 2 and 3 flush left, indented by level; 4 italic);
///   `1.` list (rendered as (a), (b), ...);
///   anything else: one paragraph with a first-line indent.
#let body-text(body) = {
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else {
      body-par(md(t))
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

// LR 5.1(d) and Fed. R. Civ. P. 5(d)(1): the certificate of service, personally signed by counsel. A blank double
// line above its heading; the signer a blank double line below the text; the block never breaks across a page.
#let certificate-block(meta) = {
  let cert = meta.certificate
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    heading(level: 1, [Certificate of Service])
    body-par([#cert.text])
    block(above: pitch-double, below: 0pt, pad(left: sig-indent, lines(cert.signer)))
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let nhd-motion-brief(meta, body) = {
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

  // Headings at the body size and pitch, bold: level 1 centered caps; level 2 flush left; level 3 indented
  // heading-step; level 4 italic, indented twice that. No space of their own (the double pitch sets them off).
  // Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { upper(it.body) } else { it.body }
    b = if it.level >= 4 { strong(emph(b)) } else { strong(b) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt,
      if it.level == 1 { align(center, b) } else { pad(left: heading-step * calc.max(it.level - 2, 0), b) })
  }

  court-title()
  caption(meta)
  block(sticky: true, width: 100%, above: pitch-single, below: 0pt,
    align(center, par(first-line-indent: 0pt, strong(upper(meta.title)))))

  body-text(body)

  signature-block(meta)

  if "certificate" in meta {
    certificate-block(meta)
  }
}
