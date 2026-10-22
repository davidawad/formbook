// Motion with memorandum for the United States District Court of Guam (gud), FRCP 12(b) and 12(f).
// Rules: GNLR 5.1 (paper, double spacing, court title not less than 3 in. from the top, counsel in the
// upper left, title of the action below the court title, file number, civil designation and description
// at the right, pages numbered at the bottom); FRCP 7(b)(1) (grounds stated with particularity, relief
// stated), FRCP 10(a) (caption); FRCP 5(d)(1)(B) (no certificate of service is required for e-filing; the
// exemplar carries one, so the sample does too).
// See ../README.md for the rule text, the dates verified and the known gaps.
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // GNLR 5.1 sets no typeface; Times New Roman (vendored), the exemplars' face
#let type-size = 12pt                   // the convention of the exemplar
#let margin = 1in                       // GNLR 5.1 sets no margin; 1 in. on every side is the exemplar's convention
#let court-title-top = 3in              // GNLR 5.1(b): the court title commences not less than 3 in. from the top
#let counsel-w = 3.25in                 // GNLR 5.1(c)(1): counsel at the upper left; right of centre reserved for the filing stamp
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let list-indent = 0.5in                // lettered items: the label half an inch in
#let list-label = 0.4in                 // lettered items: the box of the label, the text hanging after it
#let caption-w = 3.25in                 // party column of the caption
#let caption-gutter = 0.25in
#let signature-indent = 3in             // the signature block stands 3 in. from the left margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // GNLR 5.1(a): double-spaced text, 2 x the type size
#let pitch-single = 13.8pt              // single spacing (counsel, court title, caption, signature, addresses): 1.15 x the size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gud-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names, italics).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// One single-spaced line block (a paragraph of its own), with explicit space above it. An empty line keeps its
/// height.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Cover: counsel, court title, caption (GNLR 5.1(b)-(c), FRCP 10(a))
// ---------------------------------------------------------------------------

/// Counsel block (GNLR 5.1(c)(1)) in the upper left. Its box is at least as tall as the space from the top margin to
/// a single line above the court title, and a single line follows it, so the court title commences at 3 in.
/// (GNLR 5.1(b)); a longer counsel block pushes the court title down, never up (Word: a table row of that least
/// height, the court title a single line below it).
#let counsel-block(meta) = context {
  let lines = block(width: counsel-w, for l in meta.counsel { line-block(l) })
  let h = measure(lines).height
  block(width: counsel-w, height: calc.max(court-title-top - margin - pitch-single, h), breakable: false,
    above: 0pt, below: 0pt, lines)
}

#let court-title(meta) = for (i, line) in meta.court_title.enumerate() {
  line-block(above: if i == 0 { pitch-single } else { 0pt }, align(center, text(weight: "bold", inl(line))))
}

/// The party column: each party's names, its designation an inch in, and between parties a blank line, the
/// "vs." half an inch in and a blank line; one single line each.
#let caption-left(meta) = {
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      line-block("")
      line-block(pad(left: 0.5in, inl(meta.caption.between)))
      line-block("")
    }
    for n in p.names { line-block(n) }
    line-block(pad(left: 1in, inl(p.designation)))
  }
}

/// The case column: file number, civil designation and any case notes (GNLR 5.1(c)(2)), then a double line below
/// them the title of the paper in bold (GNLR 5.1(c)(3): it names the memorandum) and a single line below it any
/// subtitle.
#let caption-right(meta) = {
  line-block(meta.case_number)
  line-block(meta.designation)
  for n in meta.at("case_notes", default: ()) { line-block(n) }
  line-block(above: pitch-double, text(weight: "bold", inl(meta.brief_title)))
  if "brief_subtitle" in meta { line-block(above: pitch-single, meta.brief_subtitle) }
}

/// Caption a double line below the court title; the body a double line below the caption.
#let caption(meta) = block(width: 100%, above: pitch-double, below: pitch-double, breakable: false, grid(
  columns: (caption-w, caption-gutter, 1fr),
  caption-left(meta), [], caption-right(meta),
))

// ---------------------------------------------------------------------------
// Signature (GNLR 5.1(d): the name typed below the signature)
// ---------------------------------------------------------------------------

/// A double line above "Respectfully submitted this <date>.", a double line below it the firm, a blank line, "/s/"
/// and the signer, and the signer's lines, 3 in. from the left margin; single spaced, never broken across a page.
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    line-block[Respectfully submitted this #inl(meta.date).]
    block(width: 100%, above: pitch-double, below: 0pt, pad(left: signature-indent, {
      for l in sig.firm { line-block(l) }
      line-block(above: pitch-single, "/s/ " + sig.signer)
      for l in sig.lines { line-block(l) }
    }))
  })
}

// ---------------------------------------------------------------------------
// Body: paragraphs, headings, lettered lists, addresses, signatures
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch with the first-line indent.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// A heading at the body pitch, bold, a double line above it; level 1 centered in capitals, level 2 at the margin;
/// sticky, so it never ends a page. A CERTIFICATE heading starts a new page.
#let heading-block(level, c) = {
  if level == 1 and upper(c).starts-with("CERTIFICATE") { pagebreak(weak: true) }
  block(width: 100%, above: pitch-double, below: 0pt, sticky: true, {
    set par(first-line-indent: 0pt)
    if level == 1 { align(center, text(weight: "bold", upper(inl(c)))) } else { text(weight: "bold", inl(c)) }
  })
}

/// Lettered items ((a), (b), ...; an item per line that starts with "1." or "-", a continuation line joins the item
/// before it): the label half an inch in, in a box of list-label, the text hanging after it, at the double pitch.
#let list-chunk(c) = {
  let items = ()
  for l in c.split("\n") {
    let m = l.match(regex("^\\s*(\\d+\\.|[-*+])\\s+(.*)$"))
    if m != none { items.push(m.captures.at(1)) } else if items.len() > 0 { items.last() += " " + l.trim() }
  }
  for (i, it) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
      par(first-line-indent: 0pt, hanging-indent: list-label,
        [#box(width: list-label, numbering("(a)", i + 1))#inl(it)])))
  }
}

/// Lines of an address (`<!-- single -->`): a single line each, a single line above them, never broken.
#let single-lines(c) = block(width: 100%, above: pitch-single, below: 0pt, breakable: false,
  for l in c.split("\n") { line-block(l.trim()) })

/// Each blank-line-separated chunk is a heading, a list, a paragraph, or one of two markers: `<!-- signature -->`
/// (the signature block goes here) and `<!-- single -->` (the lines of the chunk are single-spaced, e.g. an
/// address). The signature block is appended at the end if the sample has no `<!-- signature -->` marker.
#let memorandum(meta, body) = {
  for c in chunks(body) {
    if c.starts-with("<!-- signature -->") {
      signature-block(meta)
    } else if c.starts-with("<!-- single -->") {
      single-lines(c.replace(regex("^<!--[^>]*-->\\s*"), ""))
    } else if c.starts-with("## ") {
      heading-block(2, c.slice(3))
    } else if c.starts-with("# ") {
      heading-block(1, c.slice(2))
    } else if c.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      list-chunk(c)
    } else {
      body-par(inl(c))
    }
  }
  if not body.contains("<!-- signature -->") { signature-block(meta) }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let gud-motion-brief(meta, body) = {
  // Pages numbered consecutively at the bottom, centered (GNLR 5.1(a)); the number in a single-spaced line box, so it
  // sits where Word's footer sets it.
  set page(paper: "us-letter", margin: margin, header: none, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (GNLR 5.1(a): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: list-label)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  counsel-block(meta)
  court-title(meta)
  caption(meta)
  memorandum(meta, body)
}
