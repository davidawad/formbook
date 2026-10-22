// U.S. Bankruptcy Court, Eastern District of Arkansas: adversary complaint.
//
// Rule-driven and content-agnostic. Rule IDs (AREB-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed complaint, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a convention)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // convention: vendored serif (no system fonts)
#let type-size = 12pt                      // AREB-FORM-004 (convention): no rule sets a size
#let page-margin = 1in                     // AREB-FORM-003 (convention): one-inch margins
#let paragraph-indent = 0.5in              // first-line indent of body and numbered paragraphs (FRCP 10(b) layout convention)
#let text-width = 8.5in - 2 * page-margin     // the text block of a US letter page
#let sig-width = 3.2in                     // the signature column, at the right margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/areb.lua sets the same twips).
#let pitch-body = 22.2pt                   // AREB-FORM-004 (convention): body about double spaced
#let pitch-single = 13.2pt                 // caption, counsel block, signature, quotations
#let numbered-below = 7.2pt                // a numbered paragraph's space below it
#let court-below = 19.2pt                  // caption: court name to the party block, and the party block to the title
#let title-below = 14.4pt                  // caption: title to the text
#let caption-pad = 10.8pt                  // caption: the rules stand off the last line by this much
#let caption-top = 2.4pt                   // caption: the party block's space above its first line
#let caption-inset = 0.2in                 // caption: the party block's text stands off the vertical rule
#let case-pad = 0.25in                     // caption: the case numbers stand off the vertical rule
// Headings: the space above and below each level (h1 centred bold, h2 bold, h3 italic).
#let heading-space = ((14.4pt, 12pt), (13.2pt, 10.8pt), (12pt, 9.6pt))

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with an explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, body)

/// A list item's body without the paragraph breaks a loose list puts around it (they may not occur inside a
/// paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Several lines, one paragraph each, with no space between them. Used instead of forced line breaks.
#let lines(items) = for s in items { line-block(inl(s)) }

#let need(meta, key) = {
  if key not in meta { panic("areb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("areb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b): court name, case title, case and adversary numbers, designation;
// FRBP 7010: FRCP 10 applies, caption substantially conforms to Official Form 416 (complaint caption)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let court = need(meta, "court")
  for k in ("name", "district", "division") {
    line-block(align(center, text(weight: "bold", upper(need(court, k)))))
  }

  let debtor = need(meta, "debtor")
  let plaintiffs = need(meta, "plaintiffs")
  let defendants = need(meta, "defendants")

  // Left: IN RE the debtor(s), then the parties, each side's names then its designation; a single line between the
  // groups. Right, at the bottom (its lines on the party block's own lines): the case numbers, a line apart.
  let party-block = {
    line-block[IN RE:]
    for n in debtor.names { line-block(align(center, inl(n))) }
    line-block(align(right, [Debtor#if debtor.names.len() > 1 [s].]))
    for (i, n) in plaintiffs.names.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, inl(n)) }
    line-block(align(right, inl(need(meta, "plaintiff_designation"))))
    line-block(above: pitch-single, below: pitch-single, align(center, [v.]))
    for n in defendants.names { line-block(inl(n)) }
    line-block(align(right, inl(need(meta, "defendant_designation"))))
  }
  block(above: court-below, below: 0pt, grid(
    columns: (3.5in, 1fr),
    block(
      width: 100%,
      inset: (right: caption-inset, bottom: caption-pad, top: caption-top),
      stroke: (right: 0.8pt + black, bottom: 0.8pt + black),
      party-block,
    ),
    align(bottom + left, pad(left: case-pad, bottom: caption-pad, {
      line-block[Case No. #need(debtor, "case_number")]
      line-block(above: pitch-single)[Chapter #need(debtor, "chapter")]
      line-block(above: pitch-single)[Adv. Proc. No. #need(meta, "adversary_number")]
    })),
  ))
  line-block(above: court-below, below: title-below, align(center, text(weight: "bold", inl(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Counsel and signature (LR 5005-4: address, telephone and state bar number on every
// filing; FRBP 9011: signature of the attorney)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let counsel = need(meta, "counsel")
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(breakable: false, above: title-below, below: 0pt, {
    if "date" in meta { line-block[Dated: #meta.date] }
    // Signature line as "s/ NAME" (FRBP 9011(a)); the signer's name is printed under it.
    block(above: if "date" in meta { title-below } else { 0pt }, below: 0pt, pad(left: text-width - sig-width, {
      line-block(below: 10.8pt)[Respectfully submitted,]
      lines((("s/ " + need(sig, "signer")),) + need(sig, "lines"))
    }))
  })
  // Counsel: every group's names and lines, then the telephone number (LR 5005-4).
  let counsel-lines = ()
  for g in counsel { counsel-lines += g.names + g.lines }
  counsel-lines.push(need(meta, "phone"))
  block(breakable: false, above: 18pt, below: 0pt, lines(counsel-lines))
}

// ---------------------------------------------------------------------------
// Page, text and heading styles
// ---------------------------------------------------------------------------

#let areb-complaint(meta, body) = {
  // Every page numbered, bottom centre; the number in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // Body paragraphs open with the half-inch indent, as the numbered ones (convention; the filed exemplars).
  set par(first-line-indent: (amount: paragraph-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. The numbered paragraphs are written
  // below (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // Headings print as written: upper() would turn "523(a)(6)" into "523(A)(6)". Sticky: a heading never ends a page.
  show heading: it => {
    let (above, below) = heading-space.at(calc.min(it.level, 3) - 1)
    let b = if it.level == 1 { align(center, text(weight: "bold", it.body)) } else if it.level == 2 {
      text(weight: "bold", it.body)
    } else { text(style: "italic", it.body) }
    block(sticky: true, width: 100%, above: above, below: below, text(size: type-size, b))
  }

  // Numbered paragraphs (FRCP 10(b)): every Markdown ordered-list item is one numbered
  // paragraph, numbered continuously through the complaint.
  let para-no = counter("areb-para-no")
  show enum: it => for item in it.children {
    para-no.step()
    block(above: 0pt, below: numbered-below, par(first-line-indent: (amount: paragraph-indent, all: true),
      [#context para-no.display(). #unloose(item.body)]))
  }

  show quote.where(block: true): it => block(above: 12pt, below: 12pt, {
    set text(..edges(pitch-single))
    pad(x: 0.5in, it.body)
  })
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: 6pt, clearance: 12pt, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  caption(meta)

  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature-block(meta)
}
