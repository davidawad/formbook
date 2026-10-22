// Complaint for the U.S. District Court for the Western District of Virginia (vawd).
// Rules: Fed. R. Civ. P. 10(a) (caption: court, title, file number, Rule 7(a) designation), 10(b) (numbered
// paragraphs); W.D. Va. Local Rule 11(a) (attorney's office address, telephone, e-mail and bar number on the
// pleading). The local rules set no type size, margin or spacing for pleadings: the values below are the
// convention both filed exemplars show (see ../README.md). Content-agnostic: every case word comes from the
// sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to the exemplars; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no rule; Times New Roman substitute per docs/FONTS.md, vendored in fonts/. See README "Known gaps".
#let type-size = 12pt                   // no rule sets a size; 12 pt, the size of the Times used by the exemplars (docs/FONTS.md)
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)
#let para-indent = 0.5in                // first line of a paragraph; a paragraph number sits in a box this wide after it
#let item-indent = 0.5in                // prayer items: the label stands half an inch in
#let item-label = 0.4in                 // the label's box; the text hangs after it
#let caption-width = 3.3in              // width of the party block in the box caption
#let caption-inset = 9pt                // the party block's text stops this far from its right and bottom rules
#let caption-top = 4.5pt                // and starts this far below the top of the block
#let case-gap = 0.25in                  // from the party block's rule to the file number
#let sig-indent = 3.25in                // the signature lines stand this far in
#let footer-size = 12pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 27.6pt                // double spacing: baseline-to-baseline distance measured on both exemplars
#let pitch-single = 13.8pt              // one single-spaced line (1.15 x 12 pt, word-processor single spacing)
#let gap = 27.6pt                       // one blank double-spaced line: after the court title and the caption, in the signature block
#let head-gap = 13.8pt                  // above a heading (a heading right after another has none)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vawd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A frontmatter field the template cannot do without: a missing one stops the build.
#let need(meta, key) = {
  if key in meta and meta.at(key) != none { meta.at(key) } else { panic("vawd-complaint: the sample frontmatter needs `" + key + "`") }
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// A paragraph at the body pitch.
#let body-par(above: 0pt, content) = block(width: 100%, above: above, below: 0pt, par(first-line-indent: 0pt, content))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF VIRGINIA", upper(need(meta, "division")))
  for (i, l) in lines.enumerate() {
    line-block(below: if i == lines.len() - 1 { gap } else { 0pt }, align(center, l))
  }
}

/// The lines of the party block: each name, "v." between the parties, each designation.
#let party-lines(meta) = {
  let items = ()
  for (i, p) in need(meta, "caption").parties.enumerate() {
    if i > 0 { items.push(pad(left: 0.6in, [v.])) }
    for n in p.names { items.push(inl(n)) }
    items.push(pad(left: 1.5in, inl(p.designation)))
  }
  items
}

#let case-line(meta) = [#meta.at("case_label", default: "Civil Action No.") #need(meta, "case_number")]

/// Box caption: the party block is closed by a rule at its right and bottom; the file number sits opposite, centered
/// on the block's height. A blank single line between the lines of the party block.
#let caption-box(meta) = block(above: 0pt, below: gap, grid(
  columns: (caption-width, 1fr),
  block(width: caption-width, stroke: (right: 0.75pt, bottom: 0.75pt),
    inset: (right: caption-inset, bottom: caption-inset, top: caption-top),
    for (i, c) in party-lines(meta).enumerate() { line-block(above: if i > 0 { pitch-single } else { 0pt }, c) }),
  align(horizon, pad(left: case-gap, line-block(case-line(meta)))),
))

/// ")" caption: a column of ")" marks beside the party block. Each party line is one row of the grid; its ")"
/// column gets as many marks as the line takes up (a name can wrap), so the marks follow the text.
#let caption-parens(meta) = {
  let cell-lines(c) = calc.max(1, int(calc.round(measure(width: caption-width, line-block(c)).height / pitch-single)))
  let row(c) = context {
    let n = cell-lines(c)
    grid(columns: (caption-width, 0.4in), line-block(c),
      for _ in range(n) { line-block(align(center)[)]) })
  }
  block(above: 0pt, below: pitch-single, for c in party-lines(meta) { block(above: 0pt, below: 0pt, row(c)) })
  line-block(below: gap, case-line(meta))
}

#let cover(meta) = {
  court-title(meta)
  if need(meta, "caption").at("style", default: "box") == "parens" { caption-parens(meta) } else { caption-box(meta) }
  if "title" in meta and meta.title != none {
    line-block(above: pitch-single, below: gap, align(center, strong(upper(inl(meta.title)))))
  }
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b))
// ---------------------------------------------------------------------------

/// Headings at the body pitch, kept with the text after them: level 1 a centered caps section; level 2 a centered
/// bold sub-heading (COUNT I, its title); level 3 a bold left-aligned sub-heading.
#let heading-block(t, above) = {
  let lv = t.position(regex("[^#]"))
  let body = inl(t.slice(lv).trim())
  block(width: 100%, above: above, below: 0pt, sticky: true, {
    set par(first-line-indent: 0pt)
    if lv == 1 { align(center, strong(upper(body))) }
    else if lv == 2 { align(center, strong(body)) }
    else { strong(body) }
  })
}

/// Lettered items a., b., ... of a list: the label half an inch in, the text hanging after it. An array of blocks.
#let items(t) = {
  let marker = regex("^(\\d+\\.|[-*+])[ \\t]+")
  let its = ()
  for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
    if l.starts-with(marker) or its.len() == 0 { its.push(l.replace(marker, "")) } else { its.last() += " " + l }
  }
  its.enumerate().map(((i, s)) => block(width: 100%, above: 0pt, below: 0pt, par(hanging-indent: item-indent + item-label, first-line-indent: 0pt,
    [#h(item-indent)#box(width: item-label, numbering("a.", i + 1))#inl(s)])))
}

/// The body: each blank-line-separated chunk of markdown that is neither a heading nor a list is one numbered
/// paragraph. Headings and lists are unnumbered; the first paragraph after the prayer heading (the WHEREFORE clause)
/// is unnumbered too. The last block (a prayer item, as a rule) is kept with the signature block `tail`, so the
/// signature never stands alone on a page.
#let allegations(body, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let out = ()
  let n = 0
  let unnumbered-next = false
  let after-heading = false
  for t in chunks {
    if t.starts-with("#") {
      if t.contains("PRAYER") { unnumbered-next = true }
      out.push(heading-block(t, if after-heading { 0pt } else { head-gap }))
      after-heading = true
      continue
    }
    after-heading = false
    if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      out += items(t)
    } else if unnumbered-next {
      out.push(body-par[#h(para-indent)#inl(t)])
    } else {
      n += 1
      out.push(body-par[#h(para-indent)#box(width: para-indent)[#n.]#inl(t)])
    }
    unnumbered-next = false
  }
  if out.len() > 0 and not after-heading {
    for b in out.slice(0, -1) { b }
    block(breakable: false, width: 100%, { out.last(); tail })
  } else {
    for b in out { b }
    block(breakable: false, width: 100%, tail)
  }
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Civ. P. 11(a); W.D. Va. Local Rule 11(a))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let s(above: 0pt, body) = line-block(above: above, pad(left: sig-indent, body))
  line-block(above: gap)[DATED: #need(meta, "date").]
  s(above: gap)[Respectfully submitted,]
  for (i, l) in sig.at("firm", default: ()).enumerate() { s(above: if i == 0 { gap } else { 0pt }, inl(l)) }
  s(above: gap)[By: /s/ #sig.signer]
  s(inl(sig.signer))
  for l in sig.at("lines", default: ()) { s(inl(l)) }
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let vawd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "division", "caption", "date", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set document(
    title: "Complaint, No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  // The page number centered in the bottom margin, in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margins,
    footer-descent: 30%,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1331"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    body-par[#h(para-indent)#inl(meta.lead_in)]
  }

  allegations(body, signature-block(meta))
}
