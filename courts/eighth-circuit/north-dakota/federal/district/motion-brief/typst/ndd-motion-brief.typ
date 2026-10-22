// Motion to dismiss with memorandum in support, for the U.S. District Court for the District of North Dakota (ndd).
// Rules: D.N.D. Civil Rule 5.1(B) (12-point type or larger, double-spaced, one-inch margins, page numbers at
// the bottom); Civil Rule 7.1(A)(1)(a) (a dispositive motion's memorandum: 40-page limit, tables optional and
// excluded from the limit); Fed. R. Civ. P. 7(b)(1) and 12(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Civil Rule 5.1(B)(2) sets a size, not a typeface; Times New Roman, as the exemplars
#let type-size = 12pt                   // Civil Rule 5.1(B)(2): 12-point font or larger
#let page-w = 8.5in                     // Civil Rule 5.1(B)(1): standard size paper
#let page-h = 11in
#let margin = 1in                       // Civil Rule 5.1(B)(2): minimum one-inch margin
#let para-indent = 0.5in                // first-line indent of body paragraphs; hanging indent of level 2 and 3 headings
#let list-box = 0.5in                   // lettered lists: the label in a box of this width, the text after it
#let quote-indent = 1in                 // quoted material (single-spaced, Civil Rule 5.1(B)(2)), indented both sides
#let caption-left = 3.4in               // party column of the caption
#let caption-paren = 0.3in              // the ")" column
#let caption-inset = 0.2in              // the right column stands off the ")" column
#let sig-indent = 3.25in                // signature and certificate signer lines stand in the right half of the page
#let served-indent = 0.5in              // the service list of the certificate

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // Civil Rule 5.1(B)(2): double-spaced (Word's double, 27.6 pt in the exemplar)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ndd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, section symbols, etc.). A straight double quote that ends a word and
/// stands before a space or the end is a closing quote even when it has no opening one (cmarker would set an
/// opening quote there; pandoc, the docx reader, sets a closing one).
#let closers(s) = s.replace(regex("([^\\s])\"(\\s|$)"), m => m.captures.at(0) + "\u{201D}" + m.captures.at(1))
#let inl(s) = cmarker.render(closers(s), raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(closers(s), raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it; an empty line keeps its
/// height (a blank line of a list).
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if body == "" { box(height: pitch-single) } else { body }
})

/// A body paragraph at the double pitch with the first-line indent.
#let body-par(above: 0pt, content) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = for s in (meta.court, meta.district, meta.division) {
  line-block(align(center, text(weight: "bold", upper(s))))
}

/// Party column, a column of ")" marks, and the case number and title. Each row is one single-spaced line,
/// so the two columns align. A party with no designation (an "In re" caption) has none printed.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names
    if "designation" in p and p.designation != "" { rows.push(p.designation) }
  }
  block(width: 100%, above: pitch-single, below: pitch-single, grid(
    columns: (caption-left, caption-paren, 1fr),
    column-gutter: 0pt,
    { for r in rows { line-block(inl(r)) } },
    { for r in rows { line-block(")") } },
    pad(left: caption-inset, {
      let case-no = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "____________" }
      line-block[Case No. #case-no]
      line-block(above: pitch-single, text(weight: "bold", upper(meta.title)))
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body: paragraphs, headings, signature, certificate of service
// ---------------------------------------------------------------------------

/// The signature block, never split across a page: an optional "Dated" line at the margin, then in the right half
/// the optional closing, the firm, and "/s/ signer" with the signer's lines, a double line between the groups.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  let dated = "date" in meta and meta.date != ""
  if dated { line-block[Dated: #meta.date] }
  // the space below the "Dated" line sits on a block around the pad: a space at the start of a container is dropped
  block(width: 100%, above: if dated { pitch-double } else { 0pt }, below: 0pt, pad(left: sig-indent, {
    let gap = 0pt
    if "closing" in meta {
      line-block(inl(meta.closing))
      gap = pitch-double
    }
    for (k, l) in meta.signature.firm.enumerate() { line-block(above: if k == 0 { gap } else { 0pt }, inl(l)) }
    line-block(above: pitch-double, inl("/s/ " + meta.signature.signer))
    for l in meta.signature.lines { line-block(inl(l)) }
  }))
})

/// The certificate of service, never split across a page: its heading, the text, the service list, and the
/// signer's "/s/" block in the right half.
#let certificate-block(meta) = {
  let c = meta.certificate
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    block(width: 100%, above: 0pt, below: 0pt, align(center, text(weight: "bold", upper(c.heading))))
    body-par(above: pitch-double, inl(c.text))
    pad(left: served-indent, { for l in c.served { line-block(if l == "" { "" } else { inl(l) }) } })
    // the space above sits on a block around the pad: a space at the start of a container is dropped
    block(width: 100%, above: pitch-double, below: 0pt, pad(left: sig-indent, {
      line-block(inl("/s/ " + c.signer))
      for l in c.signer_lines { line-block(inl(l)) }
    }))
  })
}

/// Blank-line-separated markdown chunks become: a heading, a list (lettered (a), (b), ...), a quotation
/// (single-spaced, indented both sides), or a body paragraph with a first-line indent. Briefs are not numbered.
#let body-chunks(body) = {
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: para-indent, md(t))
    } else if t.starts-with(">") {
      block(width: 100%, above: 0pt, below: pitch-single, pad(left: quote-indent, right: quote-indent, {
        set text(..edges(pitch-single))
        inl(t.split("\n").map(l => l.trim().trim(">", at: start).trim()).join(" "))
      }))
    } else {
      body-par(inl(t))
    }
  }
}

#let ndd-motion-brief(meta, body) = {
  assert("division" in meta, message: "ndd-motion-brief: the caption must designate the division (Civil Rule 3.1(A))")

  // Civil Rule 5.1(B)(1): page numbers at the bottom, centered, in a single-spaced line box (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (Civil Rule 5.1(B)(2): double-spaced); list items as a label box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: list-box)

  // Headings are double-spaced (Civil Rule 5.1(B)(2) allows single spacing only for the case title and quotations),
  // sticky (a heading never ends a page), at the type size, with no space of their own. Level 1: centered bold
  // caps. Level 2: bold, with a hanging indent so a wrapped lettered heading lines up. Level 3: bold italic, hanging.
  show heading: it => {
    set text(size: type-size)
    let b = if it.level == 1 {
      align(center, par(first-line-indent: 0pt, text(weight: "bold", upper(it.body))))
    } else {
      par(first-line-indent: 0pt, hanging-indent: para-indent,
        text(weight: "bold", style: if it.level >= 3 { "italic" } else { "normal" }, it.body))
    }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }
  set enum(numbering: "(a)")

  court-title(meta)
  caption(meta)
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }
  body-chunks(body)
  signature-block(meta)
  if "certificate" in meta { certificate-block(meta) }
}
