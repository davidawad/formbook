// U.S. Bankruptcy Court, W.D. Ky.: memorandum of law in support of a motion (Fed. R. Bankr. P. 9013;
// W.D. Ky. L.B.R. 9004-1, 9013-1).
//
// Rule-driven and content-agnostic. Requirement IDs (KYWB-...) refer to ../README.md, which quotes
// or paraphrases the rule text. No case-specific text, no coordinates measured off the exemplar,
// no forced line breaks. The body is rendered by cmarker from the markdown below the YAML
// frontmatter of the sample. Paragraph numbers and heading numerals are typed by the author, as
// filed; this template adds neither.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // No W.D. Ky. type rule; Times New Roman (vendored), the default per docs/FONTS.md
#let type-size = 12pt                    // 12 pt, the exemplar's size, footnotes too (style choice).
#let footer-size = 11pt                  // Page number only (docx footer: w:sz 22).
#let margins = (top: 1in, bottom: 1in, x: 1in)
#let text-width = 8.5in - 2in
#let para-indent = 0.5in                 // First-line indent of body paragraphs.
#let subheading-indent = 0.5in           // Left edge of a level-3 heading's label; its later lines hang half an inch more (docx: 1440 left, 720 hanging).
#let page-size = "us-letter"             // Fed. R. Bankr. P. 9004(a) (legibility); letter paper is the convention.
#let caption-left = 3.5in                // The caption's party column (docx: 5040 twips).
#let cell-pad = 14.4pt                   // The caption's columns stand off their dividing rule (docx: 288 twips).
#let cell-top = 4.8pt                    // The adversary row's text below the debtor row (docx: 96 twips).
#let cell-bottom = 7.2pt                 // The party column's text above its rule (docx: 144 twips).
#let designation-indent = 1.8in          // "Debtors.", "Plaintiff,", "Defendant." (docx: 2592 twips).
#let v-indent = 0.9in                    // The "v." between the parties (docx: 1296 twips).
#let rule = 0.75pt                       // The rules at the right and foot of the party column (docx: w:sz 6).
#let dated-col = 3in                     // Signing block: "Dated" column; the signature and counsel to its right (docx: 4320 twips).

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/kywb-motion-brief.lua and docx/reference.xml set
// the same twips, 20 x pt).
#let pitch-body = 24pt                   // Double spacing: the convention of the filed exemplar (style choice).
#let pitch-single = 14pt                 // Caption, title, signing blocks, footnotes: single-spaced.
#let half = 12pt                         // Half a body line: around a heading, inside the caption, above a signing block.
#let group-gap = 6pt                     // Signing block: between two counsel groups.
#let note-gap = 6pt                      // Between two footnotes (docx: Footnote Text 120 twips after).
#let note-clearance = 12pt               // The body text to the footnote rule.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if type(body) != content or body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

#let need(meta, key) = {
  if key not in meta { panic("kywb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A metadata value that may be one string or a list of strings, as a list.
#let lines-of(v) = if type(v) == array { v } else { (v,) }

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kywb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line (a paragraph of its own), with an explicit space above it.
#let line-block(above: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  pad(left: left, unloose(body)))

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010 and 9004(b): court, title of the case, case number and adversary
// number, and the title of the document). Layout follows the caption of the filed exemplar: one table,
// the debtor block beside the bankruptcy identifiers, the parties (ruled at the right and foot) beside the
// adversary number and judge.
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let c = need(meta, "caption")
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  for l in lines-of(need(meta, "court")) { line-block(align(center, strong(upper(inl(l))))) }
  let debtor = {
    for (i, l) in lines-of(c.debtor_names).enumerate() { line-block(left: if i == 0 { 0pt } else { 0.5in }, inl(l)) }
    line-block(above: half, left: designation-indent, inl(c.debtor_designation))
  }
  let numbers = for l in lines-of(c.bankruptcy_lines) { line-block(inl(l)) }
  let parties = {
    for (i, side) in c.parties.enumerate() {
      for (k, n) in lines-of(side.names).enumerate() { line-block(above: if i > 0 and k == 0 { half } else { 0pt }, inl(n)) }
      line-block(left: designation-indent, inl(side.designation))
      if i < c.parties.len() - 1 { line-block(above: half, left: v-indent, [v.]) }
    }
  }
  let number = if c.adversary_number == "" { "Adv. Proc. No. " + "_" * 12 } else { "Adv. Proc. No. " + c.adversary_number }
  let adversary = {
    line-block(number)
    if "judge" in c { line-block(above: half, inl(c.judge)) }
  }
  block(above: pitch-body, below: 0pt, grid(
    columns: (caption-left, text-width - caption-left),
    grid.cell(inset: (right: cell-pad), debtor),
    grid.cell(inset: (left: cell-pad), numbers),
    grid.cell(stroke: (right: rule, bottom: rule), inset: (right: cell-pad, top: cell-top, bottom: cell-bottom), parties),
    grid.cell(inset: (left: cell-pad, top: cell-top), adversary),
  ))
  block(width: 100%, above: pitch-body, below: half, align(center, strong(upper(inl(need(meta, "title"))))))
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service (no local rule sets their form; L.B.R. 9004-1 requires
// the filer's address, telephone and email; L.B.R. 9011-4 requires a proper signature). See ../README.md.
// ---------------------------------------------------------------------------

/// One signing block, kept whole: "Dated" on the left, the signature and the counsel groups on the right.
#let signing-block(date, signer, groups, attorneys-for: none) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(width: 100%, breakable: false, above: half, below: 0pt, grid(
    columns: (dated-col, text-width - dated-col),
    line-block([Dated: #date]),
    {
      line-block([By: /s/ #signer])
      for (gi, g) in groups.enumerate() {
        for (k, l) in g.enumerate() { line-block(above: if gi > 0 and k == 0 { group-gap } else { 0pt }, inl(l)) }
      }
      if attorneys-for != none {
        for (k, l) in attorneys-for.enumerate() { line-block(above: if k == 0 { group-gap } else { 0pt }, inl(l)) }
      }
    },
  ))
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  signing-block(need(sig, "date"), need(sig, "signer"), need(sig, "groups"),
    attorneys-for: sig.at("attorneys_for", default: none))
}

#let certificate(meta) = {
  let cert = meta.at("certificate", default: none)
  if cert != none {
    pagebreak(weak: true)
    block(width: 100%, above: 0pt, below: half, sticky: true, align(center, strong(upper(inl(cert.heading)))))
    block(width: 100%, above: 0pt, below: 0pt, par(unloose(inl(cert.text))))
    signing-block(cert.date, cert.signer, cert.groups)
  }
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let kywb-motion-brief(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  // Every page numbered "- n -", bottom centre; the number in a single-spaced line box (Word's footer).
  set page(paper: page-size, margin: margins, footer-descent: 30%, footer: context align(center,
    text(size: footer-size, ..edges(pitch-single), [#"- "#counter(page).display()#" -"])))
  set document(
    title: need(meta, "title"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. No markdown lists in this contract.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings: level 2 is a centered Roman-numeral heading; level 3 a hanging sub-heading. The numerals
  // are part of the text as filed, so nothing here numbers them. On the body pitch, half a line above and below.
  show heading.where(level: 2): it => block(width: 100%, above: half, below: half, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 3): it => block(width: 100%, above: half, below: half, sticky: true,
    pad(left: subheading-indent, par(first-line-indent: 0pt, hanging-indent: subheading-indent,
      text(size: type-size, weight: "bold", it.body))))

  caption(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  certificate(meta)
}
