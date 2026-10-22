// Complaint for the U.S. District Court for the Western District of Texas (txwd).
// Rules: W.D. Tex. Local Rule CV-10(a) (12-point or larger type including footnotes, double-spaced, 8½ × 11
// paper with one-inch margins on all sides, case style and descriptive name on the document), CV-10(b)
// (attorney's address, e-mail, signature, state bar card number, telephone and fax); Fed. R. Civ. P. 8(a)
// and 10(a)-(b) (caption, numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // CV-10 names no face; Times New Roman (vendored), the exemplars' face
#let type-size = 12pt                   // CV-10(a): 12-point or larger
#let margin = 1in                       // CV-10(a): one-inch margins on all sides
#let para-indent = 0.5in                // first-line indent of body paragraphs; the paragraph number in a box of it
#let list-indent = 0.5in                // lists: the label half an inch in (a nested list a further half inch)
#let list-label = 0.25in                // lists: the box of the label, the text hanging after it
#let caption-left = 3.7in               // party column: the longest party line (about 3.3 in) must not wrap
#let caption-mid = 0.3in                // the § column
#let caption-right-inset = 0.2in        // the case column stands off the § column
#let caption-lead = 0.075in             // a caption row's leading space: this much indent
#let signature-indent = 3.2in           // the signature column (the right 3.2 in of the text width)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // CV-10(a): double spaced, 2 x the type size
#let pitch-single = 14.4pt              // single spacing (court title, caption, count lines, signature): 1.2 x the size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txwd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, smart punctuation).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body.
#let chunks(body) = body.split("\n\n").map(c => c.trim()).filter(c => c != "")

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it. An empty line
/// keeps its height.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the document
// ---------------------------------------------------------------------------

#let court-title(meta) = for line in meta.court {
  line-block(align(center, text(weight: "bold", line)))
}

/// Caption rows: [left, right], one single-spaced line each, a § in the middle column on every row (the W.D. Tex.
/// convention in both exemplars). A row's leading spaces become an indent. The caption stands two single lines
/// below the court title and above the title of the document.
#let caption(rows) = block(above: 2 * pitch-single, below: 2 * pitch-single, grid(
  columns: (caption-left, caption-mid, 1fr),
  {
    for r in rows {
      let left = r.at(0)
      let stripped = left.trim(at: start)
      line-block(if stripped == "" { "" } else { [#h((left.len() - stripped.len()) * caption-lead)#inl(stripped)] })
    }
  },
  { for _ in rows { line-block(align(center, [§])) } },
  pad(left: caption-right-inset, { for r in rows { line-block(r.at(1, default: "")) } }),
))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lists, centered count lines
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: the first-line indent, then (when numbered, FRCP 10(b)) the number in a box
/// of the paragraph indent and the text after it. `keep`: kept whole on the page of the block after it (the last
/// paragraph stays with the signature block).
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// A heading at the body pitch, bold, with no space of its own; sticky, so it never ends a page.
#let heading-block(alignment, c) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  align(alignment, text(weight: "bold", inl(c)))
})

/// Count lines (a "> " chunk): one centered single-spaced line per source line, a markdown quote marker dropped.
#let centered-lines(c) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, for l in c.split("\n") {
  let t = l.trim()
  if t.starts-with(">") { t = t.slice(1).trim() }
  line-block(align(center, inl(t)))
})

/// A list chunk: an item per line that starts with "1." or "-" (a continuation line joins the item before it);
/// a nested item (indented in the markdown) steps in a further list indent. Numbers as written, a bullet for "-".
/// Each item at the double pitch, the label in a box of list-label, the text hanging after it.
#let list-chunk(c) = {
  let items = ()
  for l in c.split("\n") {
    let m = l.match(regex("^(\\s*)(\\d+\\.|[-*+])\\s+(.*)$"))
    if m != none {
      let lab = m.captures.at(1)
      items.push((level: if m.captures.at(0).len() > 0 { 1 } else { 0 },
        label: if lab.ends-with(".") { lab } else { "•" }, text: m.captures.at(2)))
    } else if items.len() > 0 {
      items.last().text += " " + l.trim()
    }
  }
  for it in items {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent * (it.level + 1),
      par(first-line-indent: 0pt, hanging-indent: list-label, [#box(width: list-label, it.label)#inl(it.text)])))
  }
}

#let body-block(body) = {
  let cs = chunks(body)
  let n = 0
  for (i, c) in cs.enumerate() {
    let last = i == cs.len() - 1
    if c.starts-with("### ") {
      heading-block(left, c.slice(4))
    } else if c.starts-with("## ") {
      heading-block(center, c.slice(3))
    } else if c.starts-with("# ") {
      heading-block(center, upper(c.slice(2)))
    } else if c.starts-with(">") {
      centered-lines(c)
    } else if c.starts-with("~ ") {
      // unnumbered paragraph (the prayer lead-in)
      body-par(none, inl(c.slice(2)), keep: last)
    } else if c.match(regex("^(\\d+\\.|[-*+]) ")) != none {
      list-chunk(c)
    } else {
      // numbered paragraph (FRCP 10(b))
      n += 1
      body-par(n, inl(c), keep: last)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block: CV-10(b) (signature, state bar card number, address, e-mail, telephone, fax)
// ---------------------------------------------------------------------------

/// The date at the left; "Respectfully submitted", "/s/" and the signer, and the signer's lines in the right
/// 3.2 inches (an empty line keeps its height); never broken across a page.
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: 100%, breakable: false, above: pitch-single, below: 0pt, grid(
    columns: (1fr, signature-indent),
    line-block("Dated: " + meta.date),
    {
      line-block[Respectfully submitted,]
      line-block(above: pitch-single, "/s/ " + sig.signer)
      for l in sig.lines { line-block(l) }
    },
  ))
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let txwd-complaint(meta, body) = {
  // Pages numbered at the foot, centered, arabic from the first; the number in a single-spaced line box, so it sits
  // at the same place on every page (Word's footer).
  set page(paper: "us-letter", margin: margin, header: none, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (CV-10(a): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: list-label)
  // A doubled section sign stays with its number ("§§ 45.50.471"; xengine binds a single sign), as the docx filter
  // binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  court-title(meta)
  caption(meta.caption)
  block(width: 100%, above: 0pt, below: pitch-single, {
    set par(first-line-indent: 0pt)
    align(center, text(weight: "bold", inl(meta.title)))
  })
  body-block(body)
  signature-block(meta)
}
