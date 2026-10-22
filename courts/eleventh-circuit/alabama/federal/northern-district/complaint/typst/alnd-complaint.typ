// Complaint for the U.S. District Court for the Northern District of Alabama (alnd).
// Rules: Fed. R. Civ. P. 8(a), 10(a)-(c) (caption, numbered paragraphs, one set of circumstances per
// paragraph), 11(a) (signature); Local Rule 23.1 (class-action legend, when the case is one). The local rules
// of the court (rev. Dec. 4, 2019) set no typeface, margin or spacing rule for pleadings; the layout below
// follows the filed exemplar where the rules leave it open. See ../README.md for every requirement and its
// status. Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a stated layout choice in ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no ALND typeface rule; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // 12 pt, the exemplar's size (no ALND rule sets one)
#let margins = (top: 1in, bottom: 1in, x: 1in)
#let para-indent = 0.5in                // first-line indent of paragraphs; the number of a numbered paragraph stands here
#let number-box = 0.5in                 // the paragraph number's box: the text starts an inch in, as in the exemplar
#let item-indent = 0.5in                // prayer items: the letter half an inch in, the text a box after it
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-inset = 14pt               // the party text stands off the caption's right rule; the case number off the rule
#let designation-indent = 1.8in         // a party's designation ("Plaintiff,") set in from its names
#let sig-gutter = 0.3in                 // between the firms' signature columns

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 24pt                // double spacing, the exemplar's 24 pt pitch (no ALND rule states it)
#let caption-pad = pitch-single / 2     // caption: the bottom rule stands half a line below the last party line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it; an empty one is a blank
/// line of the single pitch.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if body == [] or body == "" { block(height: pitch-single) } else { body }
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (the first page carries the start of the text)
// ---------------------------------------------------------------------------

#let court-title(meta) = for l in meta.court { line-block(align(center, strong(inl(l)))) }

#let caption(meta) = block(above: pitch-double, below: 0pt, grid(
  columns: (caption-left, 1fr),
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation set in from the names; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block(align(center, [v.])) }
      for n in p.names { line-block(inl(n)) }
      line-block(pad(left: designation-indent, inl(p.designation)))
    }
  }),
  pad(left: caption-inset, line-block[Case No.: #inl(meta.case_number)]),
))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b))
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: unnumbered (first-line indent), centered, or numbered: the number in a
/// box after the first-line indent, the text after it.
#let body-par(num, content, centered: false) = block(width: 100%, above: 0pt, below: 0pt, if centered {
  align(center, par(first-line-indent: 0pt, content))
} else if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: number-box, [#num])#content])
})

/// Each blank-line-separated chunk of markdown is one unit:
///   - a heading (`#`, `##`, `###`) is set by its show rule;
///   - a list (`1.`, `-`) is lettered A., B., ... (prayer for relief);
///   - a chunk starting with `<!--unnumbered-->` is an unnumbered paragraph with a first-line indent (the prayer lead-in);
///   - a chunk starting with `<!--centered-->` is an unnumbered centered line (the "(Against All Defendants)" legend);
///   - any other chunk is one numbered paragraph.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end.
#let allegations(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else if t.starts-with("<!--unnumbered-->") {
      body-par(none, md(t.slice("<!--unnumbered-->".len()).trim()))
    } else if t.starts-with("<!--centered-->") {
      body-par(none, md(t.slice("<!--centered-->".len()).trim()), centered: true)
    } else {
      n += 1
      body-par(n, md(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Date and signature (Fed. R. Civ. P. 11(a): signed by at least one attorney of record)
// ---------------------------------------------------------------------------

/// The date line, the firms side by side (an empty entry is a blank line), and the closing lines; the block never
/// breaks across a page.
#let signature-block(meta) = {
  let sig = meta.signature
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
    line-block(inl(meta.date_line))
    block(above: pitch-double, below: 0pt, grid(
      columns: (1fr,) * sig.firms.len(),
      column-gutter: sig-gutter,
      ..sig.firms.map(lines => for l in lines { line-block(if l == "" { [] } else { inl(l) }) }),
    ))
    for (i, l) in sig.at("lines", default: ()).enumerate() {
      line-block(above: if i == 0 { pitch-double } else { 0pt }, inl(l))
    }
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let alnd-complaint(meta, body) = {
  for k in ("court", "caption", "brief_title", "case_number", "signature", "date_line") {
    if k not in meta { panic("alnd-complaint: missing required metadata field `" + k + "`") }
  }

  set document(title: meta.brief_title)
  // Page numbers centered, arabic, on every page; the number in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margins,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch; prayer items as a label box (item-indent) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-indent)
  // A doubled sign stays with its number ("§§ 157"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // Headings at the body size and pitch, bold and centered (level 1 in capitals); no space of their own (the
  // double pitch sets them off). Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { upper(it.body) } else { it.body }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, align(center, strong(b)))
  }
  set enum(numbering: "A.")

  court-title(meta)
  caption(meta)
  block(sticky: true, width: 100%, above: pitch-double, below: 0pt,
    align(center, par(first-line-indent: 0pt, strong(upper(inl(meta.brief_title))))))
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  allegations(body)
  signature-block(meta)
}
