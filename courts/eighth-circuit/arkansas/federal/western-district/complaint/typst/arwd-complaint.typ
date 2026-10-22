// Complaint for the United States District Court for the Western District of Arkansas (arwd).
// Rules: Fed. R. Civ. P. 8(a) (short and plain statement, jurisdiction, demand) and 10(a)-(b) (caption,
// numbered paragraphs); W.D./E.D. Ark. Local Rule 5.5(a) (type not less than elite, double space, letter
// size, one side), 5.5(c)(1) (signature block with address, telephone and Arkansas Supreme Court ID number),
// 5.5(d) (the JS44 cover sheet is a separate filing). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "TeX Gyre Schola"    // LR 5.5(a): proportional serif; audited exemplar face per docs/FONTS.md
#let type-size = 12pt                   // LR 5.5(a): "type not less than elite" (elite = 12 cpi); 12 pt here
#let page-w = 8.5in                     // LR 5.5(a): letter size
#let page-h = 11in
#let margin = 1in                       // convention (no margin rule in LR 5.5); the exemplar is 1 inch
#let text-width = page-w - 2 * margin   // the text block of a letter page
#let para-indent = 0.5in                // first-line indent of numbered paragraphs (convention)
#let label-box = 0.5in                  // a paragraph's number (a list item's letter) in a box of this width: text at 1 in
#let caption-left = 3.6in               // width of the party column of the caption (convention)
#let column-gap = 0.2in                 // caption and signature: the gutter between the two columns
#let sig-left = 2.6in                   // signature: the "Dated:" column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/arwd-complaint.lua sets the same twips).
#let pitch-body = 27.6pt                // LR 5.5(a): double space; a 27.6 pt baseline pitch at 12 pt (README.md)
#let pitch-single = 13.8pt              // court title, caption, title, signature: single spaced (0.65 em + 0.5 em)
#let blank-line = pitch-body            // one double-spaced blank line: court title / caption / title; around headings
#let text-above = 19.8pt                // the space above the lead-in and above the signature block (1.65 em)
#let sig-gap = 12pt                     // signature: the firm lines to "/s/" (two single leadings)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("arwd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, smart quotes).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A block of markdown, rendered as a block (for headings, paragraphs and lists).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with an explicit space above and below it.
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
// First page: court, caption, title
// ---------------------------------------------------------------------------

/// The court title, single spaced and centered: one line per entry of `court` in the frontmatter, then `division`.
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

/// The title of the paper: centered and bold, in capitals, with an optional second line.
#let title-block(meta) = {
  set text(..edges(pitch-single))
  block(above: blank-line, below: 0pt, {
    line-block(align(center, text(weight: "bold", upper(inl(meta.title)))))
    if "subtitle" in meta { line-block(align(center, text(weight: "bold", inl(meta.subtitle)))) }
  })
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither
/// a heading nor a list is one numbered paragraph; headings and lists are not numbered. Headings in a row
/// (such as "COUNT I" over "STRICT LIABILITY") are one block, one line apart, a blank line above and below it,
/// kept with the chunk after it (sticky), so a heading never ends a page.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = ()
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending.push(t)
      continue
    }
    if pending.len() > 0 {
      block(width: 100%, sticky: true, above: blank-line, below: blank-line, for h in pending { md(h) })
    }
    pending = ()
    if t.starts-with("^ ") {
      // An unnumbered paragraph (the WHEREFORE clauses): indented like a numbered one, but not counted.
      block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true),
        inl(t.slice(2))))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists (lettered a., b. ... in the complaint) may break across pages; items one pitch apart.
      md(t)
    } else {
      para-counter.step()
      block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true),
        [#box(width: label-box, context [#para-counter.display()\.])#inl(t)]))
    }
  }
  if pending.len() > 0 {
    block(width: 100%, breakable: false, above: blank-line, below: blank-line, for h in pending { md(h) })
  }
}

/// Dated line, then the signature block: the firm, "/s/" over the signer's name, and the signer's
/// address, telephone, email, Arkansas Supreme Court ID (LR 5.5(c)(1), when it applies) and role.
#let signature-block(meta) = {
  set text(..edges(pitch-single))
  block(breakable: false, above: text-above, below: 0pt, grid(
    columns: (sig-left, 1fr),
    column-gutter: column-gap,
    line-block[Dated: #meta.date],
    {
      if "firm" in meta.signature { lines(meta.signature.firm) }
      block(above: if "firm" in meta.signature { sig-gap } else { 0pt }, below: 0pt,
        lines(("/s/ " + meta.signature.signer,) + meta.signature.lines))
    },
  ))
}

#let arwd-complaint(meta, body) = {
  let para-counter = counter("paragraph")

  // Every page numbered, bottom centre; the number in a single-spaced line box (Word's footer at the same 0.4 in).
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. The lettered lists are written below (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // Headings: level 1 is a centered bold section in capitals; level 2 a centered bold sub-heading as typed;
  // level 3 a bold left-aligned sub-heading. The space around them is the allegations' (one blank line).
  show heading: it => {
    let b = if it.level == 1 { align(center, upper(it.body)) } else if it.level == 2 {
      align(center, it.body)
    } else { it.body }
    block(width: 100%, above: 0pt, below: 0pt, text(size: type-size, weight: "bold", b))
  }

  // Lettered lists (the sample's "1." items as a., b., ...): the letter at the paragraph indent in a box of
  // label-box, the text hanging after it.
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      if item.has("number") and item.number != none { n = item.number }
      block(above: 0pt, below: 0pt, par(hanging-indent: para-indent + label-box,
        first-line-indent: (amount: para-indent, all: true),
        [#box(width: label-box, numbering("a.", n))#unloose(item.body)]))
      n += 1
    }
  }

  // First page: court title, caption, title of the paper.
  court-title(meta)
  caption(meta)
  title-block(meta)

  if "lead_in" in meta {
    block(width: 100%, above: text-above, below: 0pt, par(first-line-indent: (amount: para-indent, all: true),
      inl(meta.lead_in)))
  }

  allegations(body, para-counter)

  signature-block(meta)
}
