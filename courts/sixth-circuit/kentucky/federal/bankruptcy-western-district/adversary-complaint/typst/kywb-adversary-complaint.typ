// U.S. Bankruptcy Court, W.D. Ky.: adversary complaint (Fed. R. Bankr. P. 7001, 7008, 7010).
//
// Rule-driven and content-agnostic. Requirement IDs (KYWB-...) refer to ../README.md, which quotes
// or paraphrases the rule text. No case-specific text, no coordinates measured off the exemplar,
// no forced line breaks. The body is rendered by cmarker from the markdown below the YAML
// frontmatter of the sample. Allegations are numbered here, one per blank-line-separated chunk.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // No W.D. Ky. type rule; Times New Roman (vendored), the default per docs/FONTS.md
#let type-size = 12pt                    // 12 pt, the exemplar's size (style choice).
#let margins = (top: 1in, bottom: 1in, x: 1in)
#let text-width = 8.5in - 2in
#let para-indent = 0.5in                 // First-line indent of the lead-in and the numbered allegations.
#let number-box = 0.5in                  // The allegation number "1." in a half-inch box, the text after it (docx: a tab stop at 1 in).
#let letter-box = 0.5in                  // A relief item's letter "A." hanging in a half-inch box half an inch in (docx: Prayer Item).
#let page-size = "us-letter"             // Fed. R. Bankr. P. 9004(a) (legibility) and Form 416 layout; letter paper is the convention.
#let caption-left = 3.5in                // The caption's party column (docx: 5040 twips).
#let cell-pad = 14.4pt                   // The caption's columns stand off their dividing rule (docx: 288 twips).
#let cell-top = 4.8pt                    // The adversary row's text below the debtor row (docx: 96 twips).
#let cell-bottom = 7.2pt                 // The party column's text above its rule (docx: 144 twips).
#let designation-indent = 1.8in          // "DEBTORS.", "PLAINTIFF", "DEFENDANT" (docx: 2592 twips).
#let v-indent = 0.9in                    // The "v." between the parties (docx: 1296 twips).
#let rule = 0.75pt                       // The rules at the right and foot of the party column (docx: w:sz 6).
#let signature-indent = 3in              // The signature block (docx: 4320 twips).
#let table-inset = 5pt                   // Exhibit table cells (docx: 100 twips cell margins).
#let table-stroke = 0.5pt                // Exhibit table rules (docx: w:sz 4).

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/kywb-adversary-complaint.lua sets the same
// twips, 20 x pt).
#let pitch-body = 24pt                   // Double spacing: the convention of the filed exemplar (style choice).
#let pitch-single = 14pt                 // Caption, title, signature block, exhibit tables: single-spaced.
#let half = 12pt                         // Half a body line: around a heading, inside the caption and signature.

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
  if key not in meta { panic("kywb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A metadata value that may be one string or a list of strings, as a list.
#let lines-of(v) = if type(v) == array { v } else { (v,) }

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kywb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line (a paragraph of its own), with an explicit space above it.
#let line-block(above: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  pad(left: left, unloose(body)))

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010: substantially Form 416; Fed. R. Bankr. P. 9004(b))
// ---------------------------------------------------------------------------

/// The court, then one table: the debtor block (In re) beside the bankruptcy identifiers, and the parties (ruled
/// at the right and foot) beside the adversary number; then the title.
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
// Allegations: one numbered paragraph per chunk (Fed. R. Civ. P. 10(b)). A chunk that starts with
// "# " is a heading; "~ " is an unnumbered paragraph; a markdown list item is a lettered relief item.
// ---------------------------------------------------------------------------

#let heading-line(c) = block(width: 100%, above: half, below: half, sticky: true,
  align(center, strong(upper(c))))

#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

#let allegations(body) = {
  let n = 0
  for raw in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let t = raw.trim()
    if t == "" { continue }
    if t.starts-with("# ") {
      heading-line(unloose(inl(t.slice(2))))
    } else if t.starts-with("~ ") {
      body-par(unloose(inl(t.slice(2))))
    } else if t.match(regex("^(\\d+\\.|-) ")) != none {
      let m = t.match(regex("^(\\d+)\\. "))
      let label = if m == none { [•] } else { numbering("A.", int(m.captures.at(0))) }
      block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
        par(first-line-indent: 0pt, hanging-indent: letter-box,
          [#box(width: letter-box, label)#unloose(inl(t.replace(regex("^(\\d+\\.|-) +"), "")))])))
    } else {
      n += 1
      body-par[#box(width: number-box)[#n.]#unloose(inl(t))]
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (no local rule sets its form; LBR 9004-1 requires the filer's address, telephone
// and email; LBR 9011-4 requires a proper signature). See ../README.md. Kept whole.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, pad(left: signature-indent, {
    for l in sig.at("firm_lines", default: (sig.firm,)) { line-block(strong(inl(l))) }
    line-block(above: half, [/s/ #sig.signer])
    for l in sig.at("lines", default: ()) { line-block(inl(l)) }
  }))
}

// ---------------------------------------------------------------------------
// Exhibits: one per page, each a table of the transfers or documents the complaint refers to.
// ---------------------------------------------------------------------------

#let exhibit(ex) = {
  pagebreak(weak: true)
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(width: 100%, above: 0pt, below: pitch-body, align(center, strong(underline(upper(inl(ex.title))))))
  let ncols = ex.header.len()
  let body-rows = ex.rows.map(r => r.map(c => unloose(inl(c))))
  table(
    columns: ex.at("widths", default: (1,) * ncols).map(w => w * 1fr),
    inset: table-inset,
    stroke: table-stroke,
    align: (x, y) => if x in ex.at("right", default: ()) { right } else { left },
    table.header(..ex.header.map(h => strong(unloose(inl(h))))),
    ..body-rows.flatten(),
    ..ex.at("total", default: ()).map(c => if c == "" { [] } else { strong(unloose(inl(c))) }),
  )
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let kywb-adversary-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  // Every page numbered, bottom centre; the number in a single-spaced line box (Word's footer).
  set page(paper: page-size, margin: margins, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set document(
    title: need(meta, "title"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. No markdown lists reach typst's list layout.
  show: xengine.with(pitch: pitch-body, list-indent: none)

  caption(meta)
  allegations(body)
  signature-block(meta)
  for ex in meta.at("exhibits", default: ()) { exhibit(ex) }
}
