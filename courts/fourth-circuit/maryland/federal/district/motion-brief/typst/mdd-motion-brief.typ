// U.S. District Court for the District of Maryland (mdd): memorandum in support of a motion (FRCP 12(b)).
//
// Rule-driven and content-agnostic. Requirement IDs (LR-..., FRCP-...) refer to ../README.md, which quotes
// the rule text (D. Md. Local Rules, effective Dec. 1, 2025; Fed. R. Civ. P.). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // LR-102.2.b: Times New Roman or larger typeface. Metric-compatible substitute, vendored in /fonts (docs/FONTS.md).
#let type-size = 12pt                   // LR-102.2.b: at least 12 pt text (Times New Roman 12 pt).
#let footnote-size = 10pt               // LR-102.2.b: at least 10 pt footnotes.
#let margin = 1in                       // LR-102.2.b: one-inch margin on all sides
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let item-indent = 0.5in                // list items: the label at this indent
#let item-label = 0.625in               // the label's box; the item's text hangs after it
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-pad = 0.2in                // the party text stops this far left of the caption's rule
#let designation-indent = 1.8in         // a party's designation stands this far in
#let sig-left = 3.4in                   // the signature grid: "Dated" column, then the signature column
#let max-memo-pages = 30                // LR-105.3: a memorandum in support shall not exceed thirty pages (excl. TOC)
#let toc-threshold = 15                 // LR-105.4: a table of contents is required above fifteen pages

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (court lines, caption, signature)
#let pitch-double = 2 * pitch-single    // LR-102.2.b: double-spaced (Times New Roman 12 pt, double in Word)
#let pitch-note = 11.5pt                // single-spaced 10 pt footnotes: 1.15 x 10 pt
#let gap-half = pitch-single            // half a double line: around "v.", before a designation, after the title
#let heading-above = 19.75pt            // space above a heading
#let case-top = 3.6pt                   // the case number stands this far below the caption's top
#let note-gap = 7pt                     // between two footnotes
#let note-clearance = 3.5pt             // from the last text line to the separator: with note-gap, the 10.5 pt LibreOffice keeps between the text and the first note

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, the section sign, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mdd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mdd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

// ---------------------------------------------------------------------------
// Caption and title. LR-102.2.a: every filing other than the original complaint carries a short caption:
// the names of the first plaintiff and the first defendant only, and the civil action number.
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let parties = need(meta, "caption").at("parties")
  if parties.len() != 2 {
    panic("mdd-motion-brief: LR-102.2.a: the short caption names the first plaintiff and the first defendant only (" + str(parties.len()) + " parties given)")
  }
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (caption-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: 0.75pt) } else { none },
    pad(right: caption-pad, bottom: gap-half, {
      for (k, p) in parties.enumerate() {
        if k > 0 { line-block(above: gap-half, below: gap-half, align(center, [v.])) }
        for n in p.names { line-block(inl(n)) }
        line-block(above: gap-half, left: designation-indent, inl(need(p, "designation")))
      }
    }),
    pad(left: caption-pad, top: case-top, line-block[Case No. #need(meta, "case_number")]),
  ))
}

// ---------------------------------------------------------------------------
// Signature block. LR-102.1.b.i: at the bottom of every court document, counsel states name, address,
// telephone, email and fax number, and bar number. LR-102.1.a: counsel signs.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  for k in ("name", "bar", "firm", "address", "phone", "fax", "email", "role") {
    if k not in sig { panic("mdd-motion-brief: LR-102.1.b.i: the signature block needs `" + k + "`") }
  }
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (sig-left, 1fr),
    if "date" in meta { line-block[Dated: #meta.date] } else { [] },
    for l in (
      "/s/ " + sig.name,
      sig.name,
      sig.bar,
      ..sig.firm,
      ..sig.address,
      "Telephone: " + sig.phone,
      "Facsimile: " + sig.fax,
      sig.email,
      sig.role,
    ) { line-block(inl(l)) },
  ))
}

// ---------------------------------------------------------------------------
// Certificate of service (LR-102.1.c). A paper filed through CM/ECF is served by its notice of electronic
// filing, so a certificate is optional here; a sample that carries one has it after the signature block.
// ---------------------------------------------------------------------------

#let certificate-block(meta) = {
  let cert = meta.at("certificate", default: none)
  if cert != none {
    heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
    par(inl(need(cert, "text")))
    line-block(above: pitch-double, "/s/ _______________________")
    line-block(inl(need(cert, "signer")))
  }
}

// ---------------------------------------------------------------------------
// Table of contents (LR-105.4). Built from the headings of the body, with page numbers in the body's numbering.
// ---------------------------------------------------------------------------

#let toc-section() = {
  line-block(below: gap-half, align(center, strong[TABLE OF CONTENTS]))
  outline(title: none, depth: 3, indent: 0.5in)
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let mdd-motion-brief(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "case_number", "brief_title", "signature") {
    let _ = need(meta, k)
  }
  let toc = meta.at("toc", default: false)

  // ---- document-wide settings ----
  // LR-102.2.b: page numbers at the bottom of every page after the first, centered in a single-spaced line box
  // where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    footer-descent: 30%,
    footer: context if here().page() > 1 {
      align(center, text(..edges(pitch-single), numbering(here().page-numbering(), ..counter(page).get())))
    },
  )
  set document(title: need(meta, "brief_title"), author: need(meta, "signature").name)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // Body paragraphs: every one indented, after a heading too (Word's Body Text).
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none, footnote-widows: false)
  // A doubled sign stays with its number too ("§§ 1983"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // A quotation mark right after sentence punctuation closes a quotation (cmarker reads an unmatched one as
  // opening; pandoc, the docx reader, as closing).
  show regex("[.,;:!?][\u{201C}]"): it => it.text.replace("\u{201C}", "\u{201D}")
  // Lists: the number at the item indent in a box, the text hanging after it, at the body pitch.
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      if item.has("number") and item.number != none { n = item.number }
      // a paragraph of its own (no pad or block around it: typst would set its footnote where the item starts)
      par(hanging-indent: item-indent + item-label, first-line-indent: (amount: item-indent, all: true),
        [#box(width: item-label, numbering("1.", n))#item.body])
      n += 1
    }
  }
  // Footnotes (LR-102.2.b): 10 pt, single-spaced; the mark, a space, the note (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings at the body pitch, kept with the text after them: level 1 centered bold capitals; level 2 bold,
  // hanging; level 3 bold italic.
  show heading: it => block(sticky: true, width: 100%, above: heading-above, below: 0pt, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 {
      par(hanging-indent: para-indent, strong(it.body))
    } else { strong(emph(it.body)) }
  })

  // Cover: court, short caption, title (LR-102.2.a; the title is the paper's, LR-102.1.b.i does not apply to it).
  let cover = {
    for c in need(meta, "court") { line-block(align(center, inl(c))) }
    caption(meta)
    block(width: 100%, above: pitch-double, below: gap-half, {
      set par(first-line-indent: 0pt)
      align(center, strong(upper(inl(meta.brief_title))))
    })
  }

  // The memorandum proper, then the signature block and the certificate, which never break across a page.
  let memo = {
    cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
      signature-block(meta)
      certificate-block(meta)
    })
    // ---- end check: LR-105.3 page limit (body only; the cover and TOC are not counted, LR-105.3(b)) ----
    context {
      let n = counter(page).get().first()
      if n > max-memo-pages {
        panic("mdd-motion-brief: LR-105.3: a memorandum shall not exceed " + str(max-memo-pages) + " pages (this one has " + str(n) + ")")
      }
      if not toc and n > toc-threshold {
        panic("mdd-motion-brief: LR-105.4: a memorandum over " + str(toc-threshold) + " pages needs a table of contents (set `toc: true`)")
      }
    }
  }

  if toc {
    page(numbering: none, footer: none, cover)
    page(numbering: "i", {
      counter(page).update(1)
      toc-section()
    })
    page(numbering: "1", {
      counter(page).update(1)
      memo
    })
  } else {
    cover
    memo
  }
}
