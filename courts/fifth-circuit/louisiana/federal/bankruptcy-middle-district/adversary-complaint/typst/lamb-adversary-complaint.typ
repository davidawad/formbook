// U.S. Bankruptcy Court, M.D. La.: adversary complaint (FRBP 7001; FRBP 7010 applies
// Fed. R. Civ. P. 10 with the Form 416 caption; FRBP 7008 jurisdiction and consent).
//
// Rule-driven and content-agnostic. Requirement IDs (LAMB-...) refer to ../README.md and ../../rules.md.
// No case-specific text, no coordinates measured off any filed pleading, no forced line
// breaks. The body is markdown rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman (vendored), the default per docs/FONTS.md
#let type-size = 12pt                   // LAMB-FORM-002: LR 5005-2(b), 12-point font
#let page-margin = 1in                  // LAMB-FORM-001: 8.5 x 11 page (LR 5005-2(a)); margins are a style choice
#let text-width = 8.5in - 2 * page-margin
#let para-indent = 0.5in                // first-line indent; the paragraph number sits at this indent
#let letter-box = 0.5in                 // a prayer item's letter "(a)", hanging half an inch in (docx: Prayer Item)
#let caption-gutter = 0.25in            // caption and signature: between the two columns
#let caption-col = (text-width - caption-gutter) / 2
#let caption-stroke = 0.75pt            // the rules at the right and foot of the party column (docx: w:sz 6)
#let caption-pad = 8.65pt               // the rules stand off the party column (docx: 173 twips)
#let case-pad = 0.1in                   // the case numbers stand off the gutter
#let label-indent = 1.5in               // caption: "Debtor.", "Plaintiff,", "Defendant."
#let v-indent = 0.75in                  // caption: "v."

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/lamb-adversary-complaint.lua sets the same
// twips, 20 x pt).
#let pitch-body = 31.3pt                // LAMB-FORM-003: LR 5005-2(b), double-spaced; the folder's pitch (README)
#let pitch-single = 15.65pt             // caption, title, signature block: single-spaced
#let court-below = 18pt                 // court name to the caption
#let in-re-gap = 2.4pt                  // caption: "In re:" to the debtor; between the case numbers
#let group-gap = 10.8pt                 // caption: the debtor group to the plaintiff
#let v-gap = 5.4pt                      // caption: above and below "v."
#let caption-below = 10.8pt             // the caption's rule to the title
#let title-below = 18pt                 // the title to the text
#let signature-above = 18pt             // the last paragraph to the signature block
#let signature-gap = 10.8pt             // signature: "Respectfully submitted," to the /s/ line

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Fail loudly when a required metadata field is missing.
#let need(meta, key) = {
  if key not in meta { panic("lamb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A metadata value that may be one string or a list of strings, as a list.
#let lines-of(v) = if type(v) == array { v } else { (v,) }

/// One single-spaced line (a paragraph of its own; a string as plain text), with an explicit space above it.
#let line-block(above: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  pad(left: left, body))

/// Caption (Form 416 style): court, debtor, parties, case numbers. Every string comes from metadata.
#let caption(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  line-block(align(center, strong[UNITED STATES BANKRUPTCY COURT]))
  line-block(align(center, strong[MIDDLE DISTRICT OF LOUISIANA]))
  let left = {
    line-block("In re:")
    line-block(above: in-re-gap, need(meta, "debtor"))
    line-block(left: label-indent, "Debtor.")
    for (i, l) in lines-of(need(meta, "plaintiff")).enumerate() {
      line-block(above: if i == 0 { group-gap } else { 0pt }, l)
    }
    line-block(left: label-indent, "Plaintiff,")
    line-block(above: v-gap, left: v-indent, "v.")
    for (i, l) in lines-of(need(meta, "defendants")).enumerate() {
      line-block(above: if i == 0 { v-gap } else { 0pt }, l)
    }
    line-block(left: label-indent, "Defendant.")
  }
  let right = {
    line-block("Case No. " + need(meta, "case_no"))
    line-block(above: in-re-gap, need(meta, "chapter"))
    line-block(above: in-re-gap, "Adversary Proceeding No. " + need(meta, "adv_no"))
  }
  // The rules beside and under the party column run the height of the caption (docx: the cell's borders).
  block(above: court-below, below: 0pt, grid(
    columns: (caption-col, caption-gutter, caption-col),
    grid.cell(stroke: (right: caption-stroke, bottom: caption-stroke), inset: (right: caption-pad, bottom: caption-pad),
      left),
    [],
    pad(left: case-pad, right),
  ))
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), unloose(content)))

/// Section heading: "# TEXT" centred, bold, capitals (the author writes it in any case); "## Text" bold, left;
/// "### Text" bold italic, left. All on the body pitch, kept with the block after them.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(s))) }
  else if level == 2 { strong(inl(s)) }
  else { strong(emph(inl(s))) }
})

/// Prayer or other lettered list: "(a)", "(b)", ... (FRCP 10 practice; the author writes "1." or "- " items), the
/// letter hanging in its box half an inch in.
#let lettered(c) = {
  let items = ()
  for l in c.split("\n") {
    let m = l.match(regex("^\\s*(?:-|\\*|\\d+\\.)\\s+(.*)$"))
    if m != none { items.push(m.captures.at(0)) } else if items.len() > 0 { items.at(-1) += " " + l.trim() }
  }
  for (i, it) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
      par(first-line-indent: 0pt, hanging-indent: letter-box,
        [#box(width: letter-box)[(#numbering("a", i + 1))]#unloose(inl(it))])))
  }
}

/// Split the body into blank-line-separated chunks and typeset each by its first characters.
/// Convention (LAMB-CONT-002): a chunk starting "WHEREFORE" is an unnumbered prayer lead-in.
/// The opening chunk, when it is not a heading, is an unnumbered lead-in too: both filed
/// M.D. La. complaints in usage/ leave it unnumbered (Hoven; Criss), and the
/// numbered allegations start after it. Every other paragraph is numbered (FRCP 10(b)); the number is generated.
#let body-blocks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(s => s.trim()).filter(s => s != "")
  let n = 0
  for (i, c) in chunks.enumerate() {
    if c.starts-with("#") {
      let level = c.match(regex("^(#+)")).captures.at(0).len()
      heading-block(level, c.replace(regex("^#+[ \t]*"), ""))
    } else if c.starts-with("- ") or c.starts-with("* ") or c.match(regex("^\\d+\\. ")) != none { lettered(c) }
    else if c.starts-with("WHEREFORE") or i == 0 { body-par(inl(c)) }
    else {
      n += 1
      body-par[#n. #unloose(inl(c))]
    }
  }
}

/// Signature block: "Dated" on the left; "Respectfully submitted", the signer and counsel lines on the right.
/// The space above it is spacing of its own (docx: an empty paragraph of that height); the block is kept whole.
#let signature(meta) = {
  let sig = need(meta, "signature")
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  v(signature-above)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, grid(
    columns: (caption-col, caption-gutter, caption-col),
    line-block("Dated: " + need(meta, "date")),
    [],
    {
      line-block("Respectfully submitted,")
      line-block(above: signature-gap, "/s/ " + sig.signer)
      for l in lines-of(sig.lines) { line-block(emph(l)) }
    },
  ))
}

// ---------------------------------------------------------------------------
// Entry: the whole complaint
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lamb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("title", "debtor", "case_no", "chapter", "adv_no", "plaintiff", "defendants", "date", "signature") {
    let _ = need(meta, k)
  }
  // LAMB-CONT-001: the statement of consent is required (FRBP 7008(a)); the body must state it.
  if not md.contains("consent") {
    panic("lamb-adversary-complaint: the body must state whether the pleader consents to the entry of final orders (FRBP 7008(a))")
  }

  // ---- document-wide settings ----
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  // Every page numbered, bottom centre; the number in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. No markdown lists reach typst's list layout.
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // ---- first page: caption and title ----
  caption(meta)
  block(width: 100%, above: caption-below, below: title-below,
    align(center, strong(upper(need(meta, "title")))))

  // ---- body: numbered allegations, headings, prayer ----
  body-blocks(md)

  // ---- signature ----
  signature(meta)
}
