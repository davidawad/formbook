// U.S. Bankruptcy Court, D. Montana: motion (Fed. R. Bankr. P. 9013; Mont. LBR 9013-1 and 9013-2).
//
// Rule-driven and content-agnostic. Requirement IDs (MTB-...) refer to ../README.md, which quotes the rule text:
// Mont. LBR 5005-2 (format), 9004-1 (case numbers), 9013-1 (motion content and the notice of opportunity to respond),
// 9013-2 (memoranda of law). No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the sample.
// docx/mtb.lua writes the same document for the docx engine.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // no face in the LBR; Times New Roman, the house standard (docs/FONTS.md) and the exemplar's
#let type-size = 12pt                    // MTB-FORM-002: LBR 5005-2(a)(2), at least 12 point (the exemplar's size)
#let margins = 1in                       // MTB-FORM-004: LBR 5005-2(a)(3), no less than one-inch margins
#let text-width = 8.5in - 2 * margins
#let para-indent = 0.5in                 // first-line indent of each body paragraph
#let quote-inset = 0.5in                 // block quotations are indented on both sides
#let caption-left = 3.6in                // width of the party column of the caption
#let caption-stroke = 0.75pt             // the rules at the right and foot of the party column (docx: w:sz 6)
#let cap-pad = 6pt                       // caption text to the rules, and above each caption row
#let case-pad = 12pt                     // the case-number column's text to the party column's rule
#let sig-col = 3.2in                     // signature and certificate signer: the right column
#let addressee-indent = 0.5in            // certificate of service: the addressees
#let notice-stroke = 0.75pt              // the notice's box (docx: w:sz 6)
#let notice-pad = 8pt                    // the notice's text to its box
#let hearing-indent = 1.2in              // the notice: "Date:", "Time:", "Location:"
#let table-inset = 5pt                   // the table's cell padding, left and right (docx: 100 twips)
#let table-pad = 3pt                     // the table's cell padding, top and bottom (docx: 60 twips)
#let table-rule = 0.5pt                  // the table's rules (docx: w:sz 4)
#let table-cap = 40                      // a column's width: its longest cell, at most this many characters

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/mtb.lua sets the same twips, 20 x pt).
#let pitch-double = 24pt                 // MTB-FORM-003: LBR 5005-2(a)(5), double-spaced: the body and its headings
#let pitch-single = 14pt                 // quotations and tables (LBR 5005-2(a)(5) exceptions); counsel block, caption,
                                         // title, signature, notice, certificate lines
#let court-above = 36pt                  // the counsel block to the court title
#let caption-above = 24pt                // the court title to the caption
#let title-above = 24pt                  // the caption to the title of the paper
#let title-below = 12pt                  // the title to the body
#let quote-space = 12pt                  // a block quotation's space above and below it
#let table-space = 12pt                  // the table's space above and below it
#let sig-above = 24pt                    // the last paragraph to the signature block
#let sig-gap = 12pt                      // signature: the firm lines to the /s/ line
#let notice-above = 24pt                 // the signature block to the notice
#let notice-gap = 8pt                    // the notice: between its parts
#let cert-above = 36pt                   // the notice to the certificate
#let cert-gap = 12pt                     // certificate: title, text and addressees apart
#let cert-sig-above = 24pt               // certificate: the addressees to the signer

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mtb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mtb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

/// Single lines, one per item; an empty item is a blank line of the single pitch.
#let lines(items, left: 0pt) = for i in items {
  if i == "" { block(width: 100%, height: pitch-single, above: 0pt, below: 0pt) } else { line-block(left: left, inl(i)) }
}

// ---------------------------------------------------------------------------
// Counsel block, court title, caption, title (MTB-FIRST-001..003)
// ---------------------------------------------------------------------------

/// Attorney identification, upper left of the first page (LBR 5005-2(b)).
#let counsel-block(meta) = {
  lines(need(meta, "counsel"))
  if "counsel_role" in meta and meta.counsel_role != "" { line-block(emph(inl(meta.counsel_role))) }
}

/// Court name, centered, bold capitals (FRBP 9004(b)(1)).
#let court-title(meta) = for (i, l) in need(meta, "court").enumerate() {
  line-block(above: if i == 0 { court-above } else { 0pt }, align(center, strong(upper(l))))
}

/// Caption (FRBP 9004(b)(2)-(3)): one row per caption block, parties left, case number right; the party column
/// ruled at its right and foot (docx: the cell's borders and margins).
#let caption-table(meta) = block(width: 100%, above: caption-above, below: 0pt, grid(
  columns: (caption-left, 1fr),
  ..need(meta, "caption").map(b => (
    grid.cell(stroke: (right: caption-stroke, bottom: caption-stroke),
      inset: (top: cap-pad, right: cap-pad, bottom: cap-pad), lines(b.left)),
    grid.cell(inset: (top: cap-pad, left: case-pad), lines(b.right)),
  )).flatten(),
))

#let title-block(t) = block(width: 100%, above: title-above, below: title-below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  align(center, strong(upper(inl(t))))
})

// ---------------------------------------------------------------------------
// Body: paragraphs (the sample types its own paragraph numbers), headings, block quotations, the table
// ---------------------------------------------------------------------------

#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// A pipe table (GitHub markdown), ruled and single-spaced, the width of the text. A column's width is in proportion
/// to its longest cell (characters, emphasis marks not counted), at most `table-cap`, rounded to the twip; the last
/// column takes the rest; a column whose delimiter ends in ":" is set flush right, one with ":" at both ends centered
/// (docx: the same arithmetic in docx/mtb.lua). The header row repeats on every page.
#let pipe-table(t, width) = {
  let row(l) = {
    let s = l.trim()
    if s.starts-with("|") { s = s.slice(1) }
    if s.ends-with("|") { s = s.slice(0, -1) }
    s.split("|").map(c => c.trim())
  }
  let all = t.split("\n").map(l => l.trim()).filter(l => l != "")
  let aligns = row(all.at(1)).map(d => if d.starts-with(":") and d.ends-with(":") { center }
    else if d.ends-with(":") { right } else { left })
  let rows = all.enumerate().filter(((i, l)) => i != 1).map(((i, l)) => row(l))
  let ncol = rows.first().len()
  let chars(c) = c.replace("*", "").clusters().len()
  let need = range(ncol).map(j => calc.min(table-cap, calc.max(..rows.map(r => chars(r.at(j, default: ""))))))
  let total = need.sum()
  let widths = need.slice(0, -1).map(n => calc.round(width.pt() * n / total * 20) / 20 * 1pt)
  widths.push(width - widths.sum(default: 0pt))
  let cells(r) = range(ncol).map(j => align(aligns.at(j, default: left), inl(r.at(j, default: ""))))
  // Word sets each rule in a height of its own above a row (and below the last): the cell pads above by the rule.
  table(columns: widths, inset: (x: table-inset, top: table-pad + table-rule, bottom: table-pad), stroke: table-rule,
    table.header(..cells(rows.first())),
    ..rows.slice(1).map(cells).flatten())
}

#let chunks(body) = for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
  let t = c.trim()
  if t.starts-with("#") {
    inl(t)
  } else if t.starts-with(">") {
    // Single-spaced, indented on both sides (MTB-FORM-003: quoted material).
    for q in t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).filter(s => s.trim() != "") {
      line-block(above: quote-space, below: quote-space, pad(x: quote-inset, inl(q.trim())))
    }
  } else if t.starts-with("|") {
    // The table is single-spaced and ruled; the space around it is spacing of its own (docx: empty paragraphs).
    v(table-space)
    block(width: 100%, above: 0pt, below: 0pt, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      pipe-table(t, text-width)
    })
    v(table-space + table-rule)
  } else {
    body-par(inl(t))
  }
}

// ---------------------------------------------------------------------------
// Signature block (MTB-SIG-001), notice of opportunity to respond (MTB-NOTICE-001), certificate (MTB-CERT-001)
// ---------------------------------------------------------------------------

/// The date at the left, the signer's block in the right column; kept whole (LBR 5005-2(c): conformed /s/ signature).
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: sig-above, below: 0pt, grid(columns: (1fr, sig-col),
    line-block(inl(sig.date)),
    {
      lines(sig.at("preamble", default: ()))
      line-block(above: sig-gap, inl("/s/ " + sig.signer))
      line-block(inl(sig.signer))
      line-block(inl(sig.signer_role))
    },
  ))
}

/// LBR 9013-1(f): after each motion, in bold and conspicuous print, in one ruled box kept whole. The response period
/// is the rule's 14 days unless the sample sets `response_days` for a period set by another rule (LBR 9013-1(g)).
#let notice-block(days) = block(width: 100%, breakable: false, above: notice-above, below: 0pt,
  stroke: notice-stroke, inset: notice-pad, {
    set text(weight: "bold")
    line-block(align(center)[NOTICE OF OPPORTUNITY TO RESPOND AND REQUEST A HEARING])
    line-block(above: notice-gap)[If you object to the motion, you must file a written responsive pleading and request a hearing within #days days of the motion's date. The responding party shall schedule the hearing on the motion at least 21 days after the date of the response and request for a hearing and shall include in the caption of the responsive pleading in bold and conspicuous print the date, time, and location of the hearing by inserting in the caption the following:]
    line-block(above: notice-gap, align(center)[NOTICE OF HEARING])
    line-block(above: notice-gap, left: hearing-indent)[Date:]
    line-block(left: hearing-indent)[Time:]
    line-block(left: hearing-indent)[Location:]
    line-block(above: notice-gap)[If no objections are timely filed, the Court may grant the relief requested as a failure to respond by any entity shall be deemed an admission that the relief requested should be granted.]
  })

/// Certificate of service: title (kept with the statement), statement (double-spaced), addressees, the signer's
/// conformed signature in the right column (kept whole).
#let certificate(meta) = {
  let c = meta.at("certificate", default: none)
  if c != none {
    block(width: 100%, sticky: true, above: cert-above, below: 0pt, line-block(align(center, strong(upper(c.title)))))
    block(width: 100%, above: cert-gap, below: cert-gap,
      par(first-line-indent: (amount: para-indent, all: true), inl(c.text)))
    lines(c.at("addressees", default: ()), left: addressee-indent)
    block(width: 100%, breakable: false, above: cert-sig-above, below: 0pt, {
      line-block(left: text-width - sig-col, inl("/s/ " + c.signer))
      line-block(left: text-width - sig-col, inl(c.signer))
      line-block(left: text-width - sig-col, inl("Dated: " + c.date))
    })
  }
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let mtb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "counsel", "caption", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  // MTB-FORM-001: 8 1/2 x 11 inch, one-sided; MTB-FORM-005: consecutive page numbers at the bottom, centered in a
  // single-pitch line box (where Word's footer sets it).
  set page(
    paper: "us-letter",
    margin: margins,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("§§ 157"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Section headings: centered bold capitals on the body pitch, kept with the text after them.
  show heading: it => block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    align(center, strong(upper(it.body)))
  })

  counsel-block(meta)
  court-title(meta)
  caption-table(meta)
  title-block(need(meta, "title"))
  chunks(md)
  signature-block(meta)
  notice-block(meta.at("response_days", default: 14))
  certificate(meta)
}
