// Brief in support of a motion, for the United States District Court for the Western District of Arkansas (arwd).
// Rules: Local Rule 7.2(a) (a motion is accompanied by a brief of relevant facts and applicable law), 7.2(e)
// (a motion to dismiss is set out in a separate pleading accompanied by a separate brief), 5.5(a) (type not
// less than elite, double space, letter size, one side), 5.5(c)(1) (signature block); Fed. R. Civ. P. 12(b)
// (the defenses a motion may raise). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // LR 5.5(a): a proportional serif (vendored)
#let type-size = 12pt                   // LR 5.5(a): "type not less than elite" (elite = 12 cpi); 12 pt here
#let page-w = 8.5in                     // LR 5.5(a): letter size
#let page-h = 11in
#let margin = 1in                       // convention (no margin rule in LR 5.5); the exemplar is 1 inch
#let text-width = page-w - 2 * margin   // the text block of a letter page
#let para-indent = 0.5in                // first-line indent of body paragraphs (convention)
#let label-box = 0.5in                  // a list item's number in a box of this width: text at 1 in
#let caption-left = 3.6in               // width of the party column of the caption (convention)
#let column-gap = 0.2in                 // caption and signature: the gutter between the two columns
#let sig-left = 2.6in                   // signature: the "Dated:" column
#let quote-indent = 0.5in               // block quotations: indented on both sides

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/arwd-motion-brief.lua sets the same twips).
#let pitch-body = 27.6pt                // LR 5.5(a): double space; a 27.6 pt baseline pitch at 12 pt (README.md)
#let pitch-single = 13.8pt              // court title, caption, title, quotations, signature: single spaced
#let blank-line = pitch-body            // one double-spaced blank line: court title / caption / title; around headings
#let text-above = 19.8pt                // the space under the title and above the signature block (1.65 em)
#let single-gap = 12pt                  // around a quotation and the certificate's address; inside the signature

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("arwd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, smart quotes).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A block of markdown (headings, paragraphs, lists, quotations).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One line block (a paragraph of its own), with an explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, body)

/// One single-spaced line per item, no space between them. Used instead of forced line breaks.
#let lines(items) = for s in items { line-block(inl(s)) }

/// A list item's body without the paragraph breaks a loose list puts around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

// ---------------------------------------------------------------------------
// First page: court, caption, title of the paper
// ---------------------------------------------------------------------------

/// The court title, single spaced and centered: one line per entry of `court`, then `division`.
#let court-title(meta) = {
  set text(..edges(pitch-single))
  let lines = meta.court
  if "division" in meta { lines.push(meta.division) }
  for l in lines { line-block(align(center, upper(l))) }
}

/// The caption: party names on the left with their designation on the right; "v." and the case number
/// share the row between the two parties. Single spaced, every row one line box.
#let caption(meta) = {
  set text(..edges(pitch-single))
  let cells = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      cells += ([v.], [CASE NO. #meta.case_number])
    }
    for (i, n) in p.names.enumerate() {
      cells += (inl(n), if i == 0 { align(right, inl(p.designation)) } else { [] })
    }
  }
  block(above: blank-line, below: 0pt, grid(columns: (caption-left, 1fr), column-gutter: column-gap, ..cells))
}

/// The title of the paper: centered and bold, single spaced.
#let title-block(meta) = {
  set text(..edges(pitch-single))
  line-block(above: blank-line, below: text-above, align(center, text(weight: "bold", inl(meta.title))))
}

// ---------------------------------------------------------------------------
// Body, signature and certificate
// ---------------------------------------------------------------------------

/// The body, one chunk at a time, every line on the double-spaced pitch. Headings in a row are one block, one line
/// apart, a blank line above and below it, kept with the chunk after it (sticky). Paragraphs are not numbered (a
/// brief is not Fed. R. Civ. P. 10(b)). The last chunk is returned as `tail`, so the caller can keep it with the
/// signature block (the closing paragraph and the signature stay on one page, as in the exemplar).
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let flow = ()
  let tail = ()
  let pending = ()
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending.push(t)
      continue
    }
    let piece = if t.starts-with(">") or t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A quotation or a list: written by the show rules of the template.
      md(t)
    } else {
      block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), inl(t)))
    }
    let items = if pending.len() > 0 {
      (block(width: 100%, sticky: true, above: blank-line, below: blank-line, for h in pending { md(h) }), piece)
    } else {
      (piece,)
    }
    flow += tail
    tail = items
    pending = ()
  }
  if pending.len() > 0 {
    flow += tail
    tail = (block(width: 100%, above: blank-line, below: blank-line, for h in pending { md(h) }),)
  }
  (flow, tail)
}

/// The closing and signature block: the closing line ("Respectfully submitted,"), the party or firm lines,
/// "/s/" over the signer's name, and the signer's address, telephone, email, Arkansas Supreme Court ID
/// (LR 5.5(c)(1), when it applies) and role. A date line on the left when the frontmatter gives one.
#let signature-block(meta) = {
  set text(..edges(pitch-single))
  block(above: text-above, below: 0pt, grid(
    columns: (sig-left, 1fr),
    column-gutter: column-gap,
    if "date" in meta { line-block[Dated: #meta.date] } else [],
    {
      let above = 0pt
      if "closing" in meta {
        line-block(inl(meta.closing))
        above = single-gap
      }
      if "firm" in meta.signature {
        block(above: above, below: 0pt, lines(meta.signature.firm))
        above = single-gap
      }
      block(above: above, below: 0pt, lines(("By: /s/ " + meta.signature.signer,) + meta.signature.lines))
    },
  ))
}

/// The certificate of service (when the frontmatter has one): its heading, the sentence the filer wrote,
/// the names and address served, and the signature. Kept on one page.
#let certificate(meta) = if "certificate" in meta {
  let c = meta.certificate
  block(breakable: false, width: 100%, above: blank-line, below: 0pt, {
    line-block(below: 0pt, align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
    block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), inl(c.body)))
    set text(..edges(pitch-single))
    block(above: single-gap, below: 0pt, pad(left: para-indent, lines(c.served)))
    block(above: single-gap, below: 0pt, pad(left: sig-left + column-gap,
      lines(("/s/ " + meta.signature.signer, meta.signature.signer))))
  })
}

#let arwd-motion-brief(meta, body) = {
  // "Page n of N", bottom centre, in a single-spaced line box (Word's footer at the same 0.4 in).
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, ..edges(pitch-single),
      [Page #counter(page).display() of #counter(page).final().first()])),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are written below (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // Headings: level 1 is a centered bold section in capitals; level 2 a centered bold sub-heading as typed;
  // level 3 a bold left-aligned sub-heading. The space around them is the body's (one blank line).
  show heading: it => {
    let b = if it.level == 1 { align(center, upper(it.body)) } else if it.level == 2 {
      align(center, it.body)
    } else { it.body }
    block(width: 100%, above: 0pt, below: 0pt, text(size: type-size, weight: "bold", b))
  }

  // A quotation: single spaced and indented on both sides (no rule; the exemplar's quotation).
  show quote.where(block: true): it => block(width: 100%, above: single-gap, below: single-gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: quote-indent, it.body)
  })

  // Numbered lists: the number at the paragraph indent in a box of label-box, the text hanging after it.
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      if item.has("number") and item.number != none { n = item.number }
      block(above: 0pt, below: 0pt, par(hanging-indent: para-indent + label-box,
        first-line-indent: (amount: para-indent, all: true),
        [#box(width: label-box, numbering("1.", n))#unloose(item.body)]))
      n += 1
    }
  }

  // First page: court title, caption, title of the paper.
  court-title(meta)
  caption(meta)
  title-block(meta)

  // The closing paragraph is kept on the page with the signature block.
  let (flow, tail) = body-chunks(body)
  for x in flow { x }
  block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
    for x in tail { x }
    signature-block(meta)
  })
  certificate(meta)
}
