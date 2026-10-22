// Complaint in an adversary proceeding, U.S. Bankruptcy Court, District of South Carolina (scb).
// Rules: Fed. R. Bankr. P. 7010 (caption: Official Form 416, the adversary-complaint version; Fed. R. Civ. P. 10), 7008(a) (jurisdiction
// statement and consent to final orders), 9004(a)-(b) (legible; caption with court, title, case and
// adversary numbers, and the document's character), 9037(a) (redaction of identifiers). Local: SC LBR
// 9011-4 (signature block). Fed. R. Civ. P. 10(b) (numbered paragraphs, as applied by Rule 7010). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // No SC bankruptcy rule names a typeface; Times New Roman substitute per docs/FONTS.md, vendored in /fonts.
#let type-size = 12pt                   // no SC bankruptcy rule sets a size; the 12 pt convention (docs/FONTS.md)
#let page-margin = 1in
#let para-indent = 0.5in                // first-line indent of unnumbered opening text
#let number-box = 0.5in                 // an allegation number's box: the text starts half an inch in; wrapped lines return to the margin (docx: a tab)
#let list-indent = 0.5in                // a prayer item's letter starts half an inch in ...
#let letter-box = 0.5in                 // ... in a box of its own; the text wraps under the text (docx: a hanging indent)
#let quote-indent = 0.5in               // block quotations: indented both sides
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case column ...
#let caption-pad = 0.15in               // ... the divider stands off the party lines by this much ...
#let case-pad = 0.25in                  // ... and the case column stands off the gutter by this much
#let designation-indent = 1.4in         // "Plaintiff," / "Defendant." under the party names
#let versus-indent = 0.4in              // "v." between the parties
#let sig-left = 3.25in                  // the signature block's left edge

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/scb-adversary-complaint.lua and
// docx/reference.xml set the same twips).
#let pitch-body = 24pt                  // double spacing: the line pitch of body text
#let pitch-single = 16.2pt              // court title, caption, block quotations, signature block
#let caption-gap = 12pt                 // between the blocks of the caption's party column
#let cover-gap = 24pt                   // court title to caption, caption to text
#let case-gap = 72pt                    // the chapter line to the adversary number ...
#let title-gap = 36pt                   // ... and the adversary number to the title, in the case column
#let heading-above = 12pt               // a heading: the space above it (none below; it sits on the body pitch)
#let quote-above = 12pt                 // a block quotation: the space above it ...
#let quote-below = 12pt                 // ... below it ...
#let quote-gap = 10.8pt                 // ... and between its paragraphs
#let signature-above = 24pt             // the last paragraph to the signature block ...
#let dated-above = 24pt                 // ... and the signature block to the "Dated" line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("scb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Required frontmatter field: a missing key fails loudly rather than printing nothing.
#let need(meta, key) = {
  if key not in meta { panic("scb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Inline markdown (italic case names, smart quotes) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-spaced line (a paragraph of its own), with an explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// A horizontal rule across the column, taking no height (docx: the paragraph above carries a bottom border).
#let rule() = block(width: 100%, above: 0pt, below: 0pt, line(length: 100%, stroke: 0.75pt))

// ---------------------------------------------------------------------------
// Cover: court title and caption (Official Form 416A layout; Fed. R. Bankr. P. 7010, 9004(b))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = need(meta, "court")
  for (i, l) in lines.enumerate() {
    line-block(align(center, if i == lines.len() - 1 { text(weight: "bold", l) } else { l }))
  }
}

/// The caption: the bankruptcy case (In re: / Debtor.) above the adversary parties, with the case number,
/// chapter, adversary number and document title in the right column. Lines close the debtor block and the
/// party block, as on the filed form.
#let caption(meta) = {
  let b = need(meta, "bankruptcy")
  let parties = need(meta, "caption").parties
  let left = {
    line-block[In re:]
    for (i, d) in b.debtor.enumerate() { line-block(above: if i == 0 { caption-gap } else { 0pt }, inl(d)) }
    line-block(above: caption-gap, align(right)[Debtor.])
    rule()
    for (i, p) in parties.enumerate() {
      for (j, n) in p.names.enumerate() { line-block(above: if j == 0 { caption-gap } else { 0pt }, inl(n)) }
      line-block(pad(left: designation-indent, inl(p.designation)))
      if i < parties.len() - 1 { line-block(above: caption-gap, pad(left: versus-indent)[v.]) }
    }
    rule()
  }
  let right = {
    line-block(inl(b.case_number))
    line-block(inl(b.chapter))
    line-block(above: case-gap, inl(need(meta, "adversary_number")))
    line-block(above: title-gap, text(weight: "bold", inl(need(meta, "title"))))
  }
  block(above: cover-gap, below: cover-gap, grid(
    columns: (caption-left, caption-gutter, 1fr),
    grid.cell(stroke: (right: 0.75pt), inset: (right: caption-pad), left),
    [],
    pad(left: case-pad, right),
  ))
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b), by Rule 7010). Headings, quotations and lists are not
// numbered. A paragraph that directly follows a quotation or list is a continuation and is not numbered; a
// paragraph that leads into a list ("WHEREFORE ... for:") is not numbered either.
// ---------------------------------------------------------------------------

#let chunk-kind(t) = {
  if t.starts-with("#") { "heading" }
  else if t.starts-with(">") { "quote" }
  else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) { "list" }
  else { "para" }
}

#let numbered-para(kinds, i) = {
  let prev = if i > 0 { kinds.at(i - 1) } else { "heading" }
  let next = if i + 1 < kinds.len() { kinds.at(i + 1) } else { "" }
  kinds.at(i) == "para" and prev not in ("quote", "list") and next != "list"
}

/// A body paragraph at the body pitch.
#let body-par(indent: 0pt, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: indent, all: true), unloose(content)))

/// A heading (`##`): a centered bold line on the body pitch, kept with the text after it (docx: Heading 2).
#let heading-block(s) = block(width: 100%, sticky: true, above: heading-above, below: 0pt,
  { set par(first-line-indent: 0pt); align(center, text(weight: "bold", inl(s))) })

/// A block quotation: single-spaced, indented both sides, its paragraphs apart (docx: Block Text).
#let quote-block(t) = block(width: 100%, above: quote-above, below: quote-below,
  pad(left: quote-indent, right: quote-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: quote-gap)
    inl(t.replace(regex("(?m)^>[ \t]?"), ""))
  }))

/// A lettered list (the prayer): a., b., ... half an inch in, the text hanging (docx: List Letter).
#let letter-list(t) = {
  let item-re = regex("^(\\d+\\.|[-*+])[ \\t]+")
  let items = t.split("\n").map(l => l.trim()).filter(l => l.starts-with(item-re)).map(l => l.replace(item-re, ""))
  for (i, item) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
      par(first-line-indent: 0pt, hanging-indent: letter-box,
        [#box(width: letter-box)[#numbering("a.", i + 1)]#unloose(inl(item))])))
  }
}

/// Walk the markdown body chunk by chunk (a chunk is one blank-line-separated block).
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let kinds = chunks.map(chunk-kind)
  let out = ()
  let n = 0
  for (i, c) in chunks.enumerate() {
    let k = kinds.at(i)
    if k == "heading" { out.push(heading-block(c.replace(regex("^#+[ \t]*"), ""))) }
    else if k == "quote" { out.push(quote-block(c)) }
    else if k == "list" { out.push(letter-list(c)) }
    else if numbered-para(kinds, i) {
      n += 1
      out.push(body-par[#box(width: number-box)[#n.]#unloose(inl(c))])
    } else {
      out.push(body-par(inl(c)))
    }
  }
  out
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: signature-above, below: 0pt, pad(left: sig-left, {
    line-block[/s/ #sig.signer]
    for l in sig.lines { line-block(inl(l)) }
    line-block(inl(sig.role))
  }))
  line-block(above: dated-above)[Dated: #sig.date]
}

/// The last two chunks (the prayer's lead-in and its list, or a closing heading and its paragraph) go on
/// one page with the signature block, so a signature never stands alone (docx: keep with next).
#let place-with-signature(parts, sig-block) = {
  let keep = calc.max(0, parts.len() - 2)
  for p in parts.slice(0, keep) { p }
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    for p in parts.slice(keep) { p }
    sig-block
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let scb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "bankruptcy", "caption", "adversary_number", "title", "signature") {
    let _ = need(meta, k)
  }

  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  // Every page numbered, bottom centre; the number in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. No markdown lists reach typst's list layout (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  court-title(meta)
  caption(meta)

  if "lead_in" in meta and meta.lead_in != none {
    body-par(indent: para-indent, inl(meta.lead_in))
  }

  place-with-signature(allegations(md), signature-block(meta))
}
