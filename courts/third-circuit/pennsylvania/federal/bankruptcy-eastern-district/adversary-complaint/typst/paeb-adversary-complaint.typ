// Adversary complaint for the United States Bankruptcy Court, E.D. Pennsylvania (paeb).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; caption must substantially conform to Form 416),
// 9004(a) (clearly legible), 9004(b) (caption: court, title, case number and adversary number, designation);
// L.B.R. 9004-1(b) (8 1/2 x 11 inch paper). The 7008(a) consent statement is author content (see ../README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // no E.D. Pa. rule names a font: the house face (README.md)
#let type-size = 12pt                   // convention; the Krueger and TIG exemplars are 12 point
#let margin = 1in                       // convention (no E.D. Pa. margin rule)
#let para-indent = 0.5in                // first-line indent; an allegation's number starts here ...
#let num-box = 0.5in                    // ... in a box this wide: the text starts 1 in in (docx: a tab at 1440)
#let list-indent = 0.5in                // a list item's label starts here ...
#let list-box = 0.5in                   // ... in a box this wide; the text hangs at 1 in (docx: the same)
#let designation-indent = 1.2in         // "Plaintiffs," and "Defendant." sit under the names
#let caption-cols = (3.4in, 0.35in, 2.75in)  // party column, colon column, case column (6.5 in text width)
#let sig-col = 3in                      // the signature column; "Dated:" sits left of it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/paeb-adversary-complaint.lua and
// docx/reference.xml set the same twips: 20 x pt).
#let pitch-body = 24pt                  // double spaced (docx 480)
#let pitch-single = 14pt                // court title, caption, title, signature, certificate lists, footer (docx 280)
#let cover-gap = 14pt                   // a blank single line: court title to caption, caption to title, title to text
#let heading-space = 12pt               // above and below a heading (docx 240)
#let sig-above = 24pt                   // the last paragraph to the signature block
#let cert-above = 24pt                  // the signature block to the certificate of service
#let cert-gap = 14pt                    // in the certificate: between its parts and between the served parties
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("paeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown.
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// A single-pitch line (one paragraph; it wraps on single lines). `above`: the space before it.
#let sline(content, above: 0pt, align-to: left) = block(width: 100%, above: above, below: 0pt,
  align(align-to, par(first-line-indent: 0pt, content)))

/// A body paragraph on the double pitch: its first line indented, `label` (a number) in a box `num-box` wide.
#let body-par(label, content) = block(width: 100%, above: 0pt, below: 0pt, par({
  if label != none { box(width: num-box, label) }
  content
}))

/// Headings at the type size on the body pitch, bold, `heading-space` above and below, kept with the block after
/// them: level 1 centered capitals, levels 2 and 3 at the margin.
#let heading-block(level, s) = block(width: 100%, above: heading-space, below: heading-space, sticky: true,
  align(if level == 1 { center } else { left }, par(first-line-indent: 0pt,
    text(weight: "bold", if level == 1 { upper(inl(s)) } else { inl(s) }))))

// ---------------------------------------------------------------------------
// Cover: court, caption, title (Fed. R. Bankr. P. 9004(b), 7010)
// ---------------------------------------------------------------------------

/// Caption rows: (party column, case column). The case column carries the chapter, the case number
/// and the adversary number; the party column carries the debtor, the parties and "v.".
#let caption-rows(meta) = {
  let desig(s) = [#h(designation-indent)#inl(s)]
  let rows = ()
  rows.push(("IN RE:", "Chapter " + meta.chapter))
  rows.push((meta.debtor.name, "Case No. " + meta.case_number))
  if meta.debtor.designation != "" { rows.push((desig(meta.debtor.designation), "")) }
  rows.push(("", ""))
  for (k, p) in meta.parties.enumerate() {
    if k > 0 { rows += (("", ""), ("v.", ""), ("", "")) }
    for (j, name) in p.names.enumerate() {
      rows.push((name, if k == 0 and j == 0 { "Adv. Proc. No. " + meta.adversary_number } else { "" }))
    }
    if p.designation != "" { rows.push((desig(p.designation), "")) }
  }
  rows
}

/// The caption: one row per single line, a colon beside every line (docx: a borderless table, one row per line).
#let caption(meta) = {
  let cell(s) = if s == "" { block(height: pitch-single) } else {
    block(width: 100%, par(if type(s) == str { inl(s) } else { s }))
  }
  block(width: 100%, above: cover-gap, below: 0pt, breakable: false,
    grid(columns: caption-cols, ..caption-rows(meta).map(((l, r)) => (cell(l), par[:], cell(r))).flatten()))
}

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  sline(align-to: center, text(weight: "bold", upper(inl(meta.court))))
  sline(align-to: center, text(weight: "bold", upper(inl(meta.district))))
  caption(meta)
  sline(above: cover-gap, align-to: center, text(weight: "bold", inl(meta.title)))
  v(cover-gap)
}

// ---------------------------------------------------------------------------
// Signature and certificate
// ---------------------------------------------------------------------------

/// Single lines from `sig-col`; `left` (one entry per line) set left of the first lines.
#let column-lines(rows, left) = {
  let gap = 0pt
  for (n, r) in rows.enumerate() {
    if r == "" and n >= left.len() { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, left.at(n, default: []))#inl(r)]))
      gap = 0pt
    }
  }
}

/// "Dated:" at the left; "Respectfully submitted,", the firm, "By: /s/" and the signer's lines in the column.
#let signature-block(meta) = {
  let s = meta.signature
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
    set text(..edges(pitch-single))
    column-lines(("Respectfully submitted,", "", s.firm, "", "By: /s/ " + s.signer) + s.lines,
      ([Dated: #inl(s.date)],))
  })
}

/// The certificate of service, kept on one page: the heading, the statement, the method and the parties served
/// (single lines, a blank line between parties), then "Date:" and "By: /s/".
#let certificate(meta) = {
  let c = meta.certificate
  block(width: 100%, above: cert-above, below: 0pt, breakable: false, {
    heading-block(1, "Certificate of Service")
    body-par(none, [I, #inl(c.signer), hereby certify that I served a true and correct copy of the foregoing document upon the following parties in the manner indicated:])
    set text(..edges(pitch-single))
    sline(above: cert-gap, inl(c.method + ":"))
    for (k, lines) in c.served.enumerate() {
      for (i, l) in lines.enumerate() { sline(above: if i == 0 { cert-gap } else { 0pt }, inl(l)) }
    }
    block(width: 100%, above: cert-gap, below: 0pt, column-lines(("By: /s/ " + c.signer,), ([Date: #inl(c.date)],)))
  })
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lists
// ---------------------------------------------------------------------------

/// A list chunk ("1. ..." items): one paragraph per item, the label (the sample's `list_numbering`, "(a)" by
/// default) `list-indent` in, in a `list-box`, the text hanging after it; `last` wraps the last item.
#let list-items(t, meta, last) = {
  let items = ()
  for l in t.split(regex("\\r?\\n")) {
    let m = l.match(regex("^(?:\\d+\\.|[-*+])[ \\t]+([\\s\\S]*)$"))
    if m != none { items.push(m.captures.at(0)) } else if items.len() > 0 { items.at(-1) += " " + l.trim() }
  }
  for (k, item) in items.enumerate() {
    let b = block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent, par(first-line-indent: 0pt,
      hanging-indent: list-box,
      [#box(width: list-box, numbering(meta.at("list_numbering", default: "(a)"), k + 1))#inl(item)])))
    if k + 1 == items.len() { last(b) } else { b }
  }
}

/// One chunk. Paragraphs are numbered in order (Fed. R. Civ. P. 10(b), applied by Rule 7010). A chunk that starts
/// with ">" is unnumbered (a WHEREFORE clause). Headings and lists are not numbered.
/// `tail` (the signature block) is kept on one page with the chunk's last paragraph.
#let render-chunk(t, meta, para, tail: none) = {
  let with-tail(c) = if tail == none { c } else {
    block(width: 100%, breakable: false, above: 0pt, below: 0pt, { c; tail })
  }
  let h = t.match(regex("^(#{1,3})[ \\t]+(.*)$"))
  if h != none {
    heading-block(h.captures.at(0).len(), h.captures.at(1))
    if tail != none { tail }
  } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
    list-items(t, meta, with-tail)
  } else if t.starts-with(">") {
    // kept with the block after it (docx: keepNext)
    with-tail(block(width: 100%, above: 0pt, below: 0pt, sticky: true, body-par(none, inl(t.slice(1).trim()))))
  } else {
    para.step()
    with-tail(context body-par(str(para.get().first()) + ".", inl(t)))
  }
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let adversary-complaint(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let para = counter("allegation")

  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 151"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  // The last paragraph (a list's last item) is kept on one page with the signature block, so a signature never
  // starts a page alone.
  for (i, t) in chunks.enumerate() {
    render-chunk(t, meta, para, tail: if i + 1 == chunks.len() { signature-block(meta) })
  }
  if chunks.len() == 0 { signature-block(meta) }
  if "certificate" in meta { certificate(meta) }
}
