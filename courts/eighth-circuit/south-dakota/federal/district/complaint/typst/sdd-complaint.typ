// Complaint for the U.S. District Court for the District of South Dakota (sdd).
// Rules: D.S.D. Civ. LR 83.4 (form of papers: 8 1/2 x 11 inch, double-spaced text, headings single-spaced,
// margins at least one inch on all four sides, type at least 12 point), LR 10.1 (caption; signature block),
// LR 5.1(A)(4) ("/s/" before a filing user's typed name); Fed. R. Civ. P. 8(a), 10(a), 10(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // LR 83.4 names no face: the house standard, vendored in fonts/
#let type-size = 12pt                   // LR 83.4: type must be at least 12 point
#let page-w = 8.5in                     // LR 83.4: 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LR 83.4: at least one inch on all four sides
#let para-indent = 0.5in                // first-line indent; the paragraph number's box after it
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case-number column
#let caption-inset = 12pt               // the party text stands off the caption's right rule
#let right-inset = 0.15in               // the case-number column stands off the gutter
#let sig-left = 2.6in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in
#let sig-rule = 3.2in                   // the pro se signature line
#let label-col = 1.75in                 // a body table: the label column; the other columns share the rest
#let cell-x = 5pt                       // a body table's cell padding, left and right
#let cell-y = 3pt                       // and above and below the text
#let heading-space = 12pt               // above and below a heading (LR 83.4: headings single-spaced)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // LR 83.4: double-spaced text (Word's double)
#let caption-pad = pitch-single / 2     // caption: the bottom rule stands half a line below the last party line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("sdd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Cover: court title, caption (parties on the left, case number and title on the right)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "DISTRICT OF SOUTH DAKOTA")))
  if "division" in meta and meta.division != none {
    line-block(align(center, text(weight: "bold", upper(meta.division))))
  }
}

#let caption(meta) = block(above: pitch-double, below: pitch-double, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  pad(left: right-inset, {
    line-block("Case No. " + meta.case_number)
    line-block(above: pitch-single, text(weight: "bold", inl(meta.brief_title)))
    if "jury_demand" in meta and meta.jury_demand {
      line-block(above: pitch-single, text(weight: "bold", "JURY TRIAL DEMANDED"))
    }
  }),
))

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block (LR 10.1(B)): the signature, then the typed name, address, telephone and e-mail beneath it.
/// A party without an attorney signs personally on a line; a filing user's name is preceded by "/s/"
/// (LR 5.1(A)(4)). It never breaks across a page.
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (sig-left, 1fr),
    column-gutter: sig-gutter,
    line-block[Dated: #inl(meta.date)],
    {
      if "pro_se" in sig and sig.pro_se {
        // the signature line: an empty single line ruled at its foot
        block(width: sig-rule, height: pitch-single, above: 0pt, below: 0pt, stroke: (bottom: 0.5pt))
        line-block(above: 4pt, inl(sig.signer))
        line-block("Plaintiff, without counsel")
      } else {
        if "firm" in sig {
          for l in sig.firm { line-block(inl(l)) }
        }
        line-block(above: if "firm" in sig { pitch-single } else { 0pt }, inl("By: /s/ " + sig.signer))
        line-block(inl(sig.signer))
      }
      for l in sig.at("lines", default: ()) { line-block(inl(l)) }
    },
  ))
}

/// A body paragraph at the double pitch: unnumbered (first-line indent), or numbered (Fed. R. Civ. P. 10(b)): the
/// number in a box after the first-line indent, the text after it.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: para-indent, [#num.])#content])
})

/// A markdown pipe table, set single-spaced and ruled: the first column for the labels, the others sharing the
/// rest of the measure; the delimiter row is dropped. Every cell is one line block.
#let body-table(t) = {
  let rows = t.split(regex("\\r?\\n")).map(r => r.trim()).filter(r => r != "")
  let cells(r) = {
    let s = r
    if s.starts-with("|") { s = s.slice(1) }
    if s.ends-with("|") { s = s.slice(0, -1) }
    s.split("|").map(c => c.trim())
  }
  let rows = rows.filter(r => not r.match(regex("^\\|?[\\s:|-]+$")) != none).map(cells)
  let n = rows.first().len()
  let cols = if n == 1 { (1fr,) } else { (label-col,) + (1fr,) * (n - 1) }
  block(width: 100%, above: 0pt, below: heading-space, table(
    columns: cols,
    stroke: 0.5pt,
    inset: (x: cell-x, y: cell-y),
    ..rows.map(r => r.map(c => line-block(inl(c)))).flatten(),
  ))
}

/// Body text. Each blank-line-separated chunk of markdown is one of:
///   - a heading (`#`, `##`, `###`);
///   - a table (`|`): single-spaced and not numbered;
///   - a list (`1.`, `-`): lettered (a), (b), ... and not numbered;
///   - a paragraph: numbered 1, 2, ... (Fed. R. Civ. P. 10(b)), unless it starts with "~", which is stripped and
///     renders the paragraph unnumbered (used for the certification, which is not an allegation).
/// The last paragraph stays on the page with the signature block (a signature alone on a page is not allowed).
#let allegations(body, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  let tail-used = false
  for (i, t) in chunks.enumerate() {
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with("|") {
      body-table(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      md(t)
    } else {
      let unnumbered = t.starts-with("~")
      let para = if unnumbered { body-par(none, md(t.slice(1).trim())) } else {
        n += 1
        body-par(n, md(t))
      }
      if i == chunks.len() - 1 {
        block(breakable: false, width: 100%, above: 0pt, below: 0pt, { para; tail })
        tail-used = true
      } else {
        para
      }
    }
  }
  if not tail-used { tail }
}

#let sdd-complaint(meta, body) = {
  // Page numbers centered on every page, in a single-spaced line box (Word's footer at the same place).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    numbering: "1",
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LR 83.4: double-spaced); list items as a label box (para-indent) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  set enum(numbering: "(a)")

  // Headings single-spaced (LR 83.4): level 1 centered in capitals, bold; level 2 bold; level 3 bold italic; kept
  // with the block after them.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      text(weight: "bold", it.body)
    } else { text(weight: "bold", style: "italic", it.body) }
    block(sticky: true, width: 100%, above: heading-space, below: heading-space, b)
  }

  court-title(meta)
  caption(meta)
  allegations(body, signature-block(meta))
}
