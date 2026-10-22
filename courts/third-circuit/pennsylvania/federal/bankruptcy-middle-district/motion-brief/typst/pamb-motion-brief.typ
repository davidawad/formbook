// U.S. Bankruptcy Court, M.D. Pennsylvania: brief (memorandum of law) supporting a motion under Fed. R. Bankr. P. 9013.
//
// Rule-driven and content-agnostic. Requirement IDs (PAMB-MOT-...) refer to ../README.md, which quotes the
// rule text (FRBP 9013, 9014, 9004; L.B.R. 9004-1, 9013-1, 9013-2, 9013-3). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The metadata comes from the YAML frontmatter of the
// sample (schema: ../README.md); the body is read chunk by chunk (a blank line apart) and each chunk rendered by
// cmarker.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // No M.D. Pa. font rule found (../README.md, gaps): the house face, vendored
#let type-size = 12pt                    // FRBP 9004(a): clearly legible; no M.D. Pa. size rule. 12 pt, as the filed papers
#let margin = 1in                        // style choice (no local margin rule found)
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in
#let heading-tab = 0.5in                 // a heading's label in a box this wide, each level this much further in
#let cap-col = text-width / 2            // the caption's party column, ruled at its right and foot ...
#let cap-pad = 14pt                      // ... its text this far from the rule, the case column's as far right of it
#let cap-below = 12pt                    // the space above the rule
#let cap-rule = 0.75pt
#let name-indent = 0.5in                 // the debtor's name lines, indented under "IN RE:"
#let sig-col = 3.3in                     // the signature column; "Date:" sits left of its first line
#let page-limit = 15                     // L.B.R. 9013-2(a): no brief may exceed 15 pages without leave of court.

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/pamb.lua sets the same twips: 20 x pt).
#let pitch-body = 24pt                   // double spacing, as the filed brief (docx 480)
#let pitch-single = 14pt                 // court title, caption, title, signature, served persons, footer (docx 280)
#let cover-gap = 24pt                    // court title to caption, caption to title: a blank double line
#let title-below = 12pt                  // the title to the text
#let sig-above = 24pt                    // the last paragraph to the signature block
#let sig-gap = 24pt                      // inside the signature block: closing to signature
#let served-gap = 12pt                   // above each served person's block
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let need(meta, key) = {
  if key not in meta { panic("pamb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pamb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown.
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// A single-pitch line (one paragraph; it wraps on single lines).
#let sline(content, above: 0pt, left: 0pt, align-to: left) = block(width: 100%, above: above, below: 0pt,
  pad(left: left, align(align-to, par(first-line-indent: 0pt, content))))

/// A body paragraph on the double pitch, its first line indented.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: para-indent, content))

/// Headings (convention: I., A., 1., a.; see ../README.md): bold on the body pitch with no space of their own, kept
/// with the block after them; the label in a box `heading-tab` wide, `heading-tab` further in at each level, the
/// text hanging after it (docx: a tab and a hanging indent); level 1 in capitals.
#let heading-label(level, k) = {
  if level == 1 { numbering("I.", k) } else if level == 2 { numbering("A.", k) }
  else if level == 3 { numbering("1.", k) } else { numbering("a.", k) }
}

#let heading-block(level, lab, body) = block(width: 100%, above: 0pt, below: 0pt, sticky: true,
  pad(left: (level - 1) * heading-tab, par(first-line-indent: 0pt, hanging-indent: heading-tab,
    strong[#box(width: heading-tab, lab)#if level == 1 { upper(body) } else { body }])))

// ---------------------------------------------------------------------------
// Cover: court title, caption (FRBP 9004(b), L.B.R. 9004-1; a contested-matter pleading), title
// ---------------------------------------------------------------------------

#let court-title(meta) = for l in need(meta, "court") { sline(align-to: center, strong(upper(inl(l)))) }

/// The caption: the party column ruled at its right and foot (IN RE:, the debtor's names, "Debtor") and the case
/// column (chapter, case number); the rule runs the height of the row, the space above it is under both columns
/// (LibreOffice takes a cell's margin for the whole row; docx: a one-row table, the left cell bordered).
#let caption-table(meta) = {
  let debtor = need(meta, "debtor")
  let left-col = {
    sline[IN RE:]
    for (i, n) in debtor.name.enumerate() { sline(inl(n), left: name-indent, above: if i == 0 { pitch-single } else { 0pt }) }
    sline(above: pitch-single)[Debtor]
  }
  let right-col = {
    sline(inl(debtor.chapter))
    sline(above: pitch-single)[Case No. #debtor.case_number]
  }
  block(width: 100%, above: cover-gap, below: 0pt, breakable: false, grid(
    columns: (cap-col, 1fr),
    stroke: (x, y) => if x == 0 { (right: cap-rule, bottom: cap-rule) },
    inset: (x, y) => (bottom: cap-below, left: if x == 0 { 0pt } else { cap-pad }, right: if x == 0 { cap-pad } else { 0pt }),
    left-col, right-col,
  ))
}

/// The court title, the caption and a centered bold title under them.
#let cover(meta, title) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  court-title(meta)
  caption-table(meta)
  sline(above: cover-gap, align-to: center, strong(title))
  v(title-below)
}

// ---------------------------------------------------------------------------
// Signature lines (L.B.R. 9013-1; convention for the layout, see ../README.md)
// ---------------------------------------------------------------------------

/// Single lines from `sig-col`, kept on one page: rows of (content, space above); `left` left of the first line
/// (docx: a tab and a hanging indent there).
#let sig-lines(rows, left: [], above: sig-above) = block(width: 100%, above: above, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  for (i, (r, gap)) in rows.enumerate() {
    block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
      [#box(width: sig-col, if i == 0 { left })#r]))
  }
})

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let rows = (([Respectfully Submitted,], 0pt), ([By: /s/ #inl(sig.signer)], sig-gap))
  for l in sig.at("lines", default: ()) { rows.push((inl(l), 0pt)) }
  sig-lines(rows)
}

// ---------------------------------------------------------------------------
// Certificates (L.B.R. 9013-3, 9013-2(b))
// ---------------------------------------------------------------------------

/// L.B.R. 9013-3: (a) the title of the paper served; (b) the names and addresses of the persons served;
/// (c) the entities they represent; (d) when and how service was made. On a page of its own, under the caption.
#let certificate-of-service(meta) = {
  let cos = need(meta, "certificate_of_service")
  pagebreak()
  cover(meta, [Certificate of Service])
  body-par[The undersigned certifies that on #cos.date, the undersigned caused a true and correct copy of #inl(need(meta, "title")) to be served #cos.method, on the following persons:]
  for s in cos.served {
    block(width: 100%, above: served-gap, below: 0pt, breakable: false, {
      set text(..edges(pitch-single))
      sline(inl(s.name), left: para-indent)
      sline(inl(s.address), left: para-indent)
      sline([Represents: #inl(s.represents)], left: para-indent)
    })
  }
  sig-lines(((([/s/ #inl(cos.signer)]), 0pt), (inl(cos.signer), 0pt)), left: [Date: #cos.date])
}

/// L.B.R. 9013-2(b): a brief over 15 pages must carry a certificate that it complies with the 5,000-word limit,
/// and must state the actual number of words. Printed only when the sample states the count.
#let word-count-certificate(meta) = {
  let n = meta.at("word_count", default: none)
  if n == none { return }
  pagebreak()
  block(width: 100%, above: 0pt, below: 0pt, sticky: true,
    align(center, par(first-line-indent: 0pt, strong[Certificate of Compliance with Word-Count Limit])))
  body-par[The undersigned certifies that this brief contains #n words, as counted by the word-processing system used to prepare it, and complies with the 5,000-word limit of L.B.R. 9013-2(b).]
  let signer = need(meta, "signature").signer
  sig-lines((([/s/ #inl(signer)], 0pt), (inl(signer), 0pt)))
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let pamb-motion-brief(meta, md) = {
  for k in ("court", "debtor", "title", "signature", "certificate_of_service") { let _ = need(meta, k) }

  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 541"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} ?\\S+"): it => box(it)

  cover(meta, upper(inl(need(meta, "title"))))

  // Each chunk in turn: a heading (labelled by level) or a paragraph. The last chunk (the conclusion) is kept on one
  // page with the signature block, so the signature never stands alone.
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let counts = (0, 0, 0, 0)
  for (i, t) in chunks.enumerate() {
    let h = t.match(regex("^(#{1,6})[ \\t]+(.*)$"))
    let it = if h != none {
      let level = calc.min(h.captures.at(0).len(), 4)
      counts.at(level - 1) += 1
      for j in range(level, 4) { counts.at(j) = 0 }
      heading-block(level, heading-label(level, counts.at(level - 1)), inl(h.captures.at(1)))
    } else {
      body-par(inl(t))
    }
    if i + 1 == chunks.len() {
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, { it; signature-block(meta) })
    } else { it }
  }
  certificate-of-service(meta)
  word-count-certificate(meta)

  // ---- page limit (L.B.R. 9013-2(a), (d)): the template does not generate the table of contents and table of
  // authorities that a brief over 15 pages requires, so it stops rather than print a non-compliant brief. ----
  context {
    let n = counter(page).final().first()
    if n > page-limit {
      panic("pamb-motion-brief: " + str(n) + " pages. L.B.R. 9013-2(a) limits a brief to 15 pages; longer briefs need leave of court, a word-count certificate (9013-2(b)), and a table of contents and table of authorities (9013-2(d)), which this template does not generate. See ../README.md.")
    }
  }
}
