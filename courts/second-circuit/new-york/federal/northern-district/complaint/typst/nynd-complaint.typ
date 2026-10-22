// Complaint for the United States District Court for the Northern District of New York (nynd).
// Rules: N.D.N.Y. L.R. 10.1(a) (form: 12-point type, one-inch margins, double-spaced body, consecutive
// pages), 10.1(c)(1) (caption: court, action, civil action number, judges' initials, nature of paper),
// 10.1(c)(2) (filer identification: signature, typed name, bar roll number, office address, telephone,
// e-mail); Fed. R. Civ. P. 8(a), 10(a)-(b) (numbered paragraphs), 38(b) (jury demand). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")     // L.R. 10.1 names no typeface; Times New Roman, the house standard and the exemplar's face, vendored in fonts/
#let type-size = 12pt                // L.R. 10.1(a)(1): at least 12-point type, text and footnotes
#let margin = 1in                    // L.R. 10.1(a)(2): one-inch margins on all four sides
#let para-indent = 0.5in             // first-line indent; the paragraph number sits at the indent, the text one tab later
#let number-tab = 0.5in              // the paragraph number in a box of this width
#let list-indent = 0.5in             // lettered prayer items: the label half an inch in
#let list-label = 0.5in              // and in a box of half an inch, the text hanging after it
#let caption-left = 3.6in            // width of the party column in the caption
#let caption-gutter = 0.3in          // between the party column and the case column
#let caption-case-pad = 0.1in        // the case column's text this far into its column
#let caption-foot = 10pt             // the party column's last line this far above its rule
#let between-indent = 0.5in          // "-against-" between the parties
#let designation-indent = 2in        // "Plaintiff," / "Defendants." under the names
#let signature-w = 3.2in             // the signature column at the right
#let signature-gutter = 0.2in
#let by-line = 2.6in                 // the signature line after "By:"
#let quote-indent = 1in              // block quotations, both sides
#let rule = 0.75pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt             // L.R. 10.1(a)(3): double-spaced body, 2 x the type size
#let pitch-single = 13.8pt           // single spacing, 1.15 x the size: court title, caption, quotations, signature
                                     // (L.R. 10.1(a)(4) lets block quotations be single-spaced)
#let quote-space = 12pt              // space above and below a block quotation

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nynd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, section signs, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it. An empty line keeps its
/// height.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Caption (L.R. 10.1(c)(1))
// ---------------------------------------------------------------------------

/// The court's name at the margin; a double line below it the caption: the party names, "-against-" between the
/// parties a single line apart and each designation under its names, the party column ruled 10 pt below its last
/// line; the case column with the civil action number and the judges' initials, and three blank single lines below
/// them the paper's title in bold capitals (its lines level with the party lines, so the PDF text reads the same lines
/// in every engine). Never split.
#let caption(meta) = {
  assert(meta.at("judges", default: "") != "",
    message: "nynd-complaint: L.R. 10.1(c)(1) requires the assigned judge's initials in the caption (frontmatter: judges)")
  line-block[UNITED STATES DISTRICT COURT]
  line-block[NORTHERN DISTRICT OF NEW YORK]
  let left = for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { line-block(above: pitch-single, pad(left: between-indent, inl(meta.caption.between))) }
    for (i, n) in p.names.enumerate() { line-block(above: if k > 0 and i == 0 { pitch-single } else { 0pt }, n) }
    line-block(pad(left: designation-indent, inl(p.designation)))
  }
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-gutter, 1fr),
    block(width: 100%, inset: (bottom: caption-foot), stroke: (bottom: rule), left),
    [],
    pad(left: caption-case-pad, {
      line-block[#meta.case_number (#meta.judges)]
      line-block(above: 3 * pitch-single, strong(upper(inl(meta.brief_title))))
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, lists, quotations
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: the first-line indent, then (when numbered) the number in a box of
/// number-tab and the text after it. `keep`: kept whole on the page of the block after it (the last block stays with
/// the signature block).
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: number-tab, [#num.])#content] }))

/// A heading at the body pitch, bold, sticky: level 1 centered in capitals, level 2 centered, level 3 at the margin.
#let heading-block(level, c) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(inl(c)))) }
  else if level == 2 { align(center, strong(inl(c))) }
  else { strong(inl(c)) }
})

/// Lettered items (a., b., ...; an item per line that starts with "1." or "-", a continuation line joins the item
/// before it): the label half an inch in, in a box of list-label, the text hanging after it, at the double pitch.
#let list-chunk(c, keep: false) = {
  let items = ()
  for l in c.split("\n") {
    let m = l.match(regex("^\\s*(\\d+\\.|[-*+])\\s+(.*)$"))
    if m != none { items.push(m.captures.at(1)) } else if items.len() > 0 { items.last() += " " + l.trim() }
  }
  for (i, it) in items.enumerate() {
    let k = keep and i == items.len() - 1
    block(width: 100%, above: 0pt, below: 0pt, sticky: k, breakable: not k, pad(left: list-indent,
      par(first-line-indent: 0pt, hanging-indent: list-label,
        [#box(width: list-label, numbering("a.", i + 1))#inl(it)])))
  }
}

/// A block quotation ("> "), single-spaced, an inch in on both sides, 12 pt above and below.
#let quote-chunk(c) = block(width: 100%, above: quote-space, below: quote-space, pad(x: quote-indent, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  inl(c.split("\n").map(l => l.trim().trim(">", at: start).trim()).join(" "))
}))

/// Each blank-line-separated chunk is a heading, a list, a quotation, an unnumbered paragraph (marked
/// `<!-- unnumbered -->`), a centered unnumbered subtitle (wrapped in parentheses, e.g. "(Against Defendants ...)"),
/// or a numbered paragraph (Fed. R. Civ. P. 10(b)). Numbering is applied per chunk.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  for (i, t) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    let h = t.match(regex("^(#{1,3})\\s+(.*)$"))
    if h != none {
      heading-block(h.captures.at(0).len(), h.captures.at(1))
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      list-chunk(t, keep: last)
    } else if t.starts-with(">") {
      quote-chunk(t)
    } else if t.starts-with("<!-- unnumbered -->") {
      body-par(none, inl(t.slice("<!-- unnumbered -->".len()).trim()), keep: last)
    } else if t.starts-with("(") and t.ends-with(")") {
      block(width: 100%, above: 0pt, below: 0pt, sticky: true, { set par(first-line-indent: 0pt); align(center, inl(t)) })
    } else {
      n += 1
      body-par(n, inl(t), keep: last)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (L.R. 10.1(c)(2): signature, typed name, bar roll number, office address, telephone, e-mail)
// ---------------------------------------------------------------------------

/// A double line below the body: "Dated:" at the left; at the right the firm in bold capitals, a double line below
/// it "By:" and the signature line, each signer's name, bar roll number and e-mail, a blank line, the address and
/// telephone, a blank line and the role in italics. Single-spaced, never split.
#let signature-block(sig) = {
  for s in sig.signers {
    assert(s.at("bar_roll", default: "") != "",
      message: "nynd-complaint: L.R. 10.1(c)(2) requires the bar roll number of each signing attorney (frontmatter: signature.signers[].bar_roll)")
  }
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, grid(
    columns: (1fr, signature-gutter, signature-w),
    line-block[Dated: #inl(sig.dated)],
    [],
    {
      line-block(strong(upper(inl(sig.firm))))
      line-block(above: pitch-double)[By: #box(width: by-line, line(length: 100%, stroke: 0.5pt))]
      for s in sig.signers {
        line-block(s.name)
        line-block(s.bar_roll)
        line-block(s.email)
      }
      for (i, a) in sig.address.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, a) }
      line-block(sig.phone)
      line-block(above: pitch-single, emph(inl(sig.role)))
    },
  ))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------
#let nynd-complaint(meta, body) = {
  // Pages numbered consecutively at the bottom, centered; the number in a single-spaced line box, where Word's footer
  // sets it.
  set page(paper: "us-letter", margin: margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (L.R. 10.1(a)(3): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: list-label)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  caption(meta)
  // The lead-in two double lines below the caption.
  if "lead_in" in meta and meta.lead_in != none {
    block(width: 100%, above: 2 * pitch-double, below: 0pt, body-par(none, inl(meta.lead_in)))
  }
  allegations(body)
  signature-block(meta.signature)
}
