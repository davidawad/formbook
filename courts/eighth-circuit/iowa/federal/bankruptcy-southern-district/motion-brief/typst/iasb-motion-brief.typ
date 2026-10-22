// Motion with supporting brief for the United States Bankruptcy Court, Southern District of Iowa (iasb).
// Rules (primary sources, verified 2026-10-14; see ../README.md):
//   Fed. R. Bankr. P. 9013: a request for an order is made by written motion; the motion states its grounds with
//     particularity and sets forth the relief requested; it is served on the parties the rules specify.
//   Fed. R. Bankr. P. 9014(a), (b): in a contested matter, reasonable notice and an opportunity to be heard; the motion
//     is served within the time of Rule 9006(d) and in the manner for serving a summons and complaint under Rule 7004.
//   Fed. R. Bankr. P. 9004(a), (b): legible; caption with the court's name, the title of the case, the case number (and the
//     adversary-proceeding number, if any), and a brief designation of the document.
//   Fed. R. Bankr. P. 9011(a): signed by an attorney of record, with the signer's address and telephone number.
// The court's local rules were abolished effective 2003-08-04 (court website), so there is no local rule on motion form,
// brief length, typeface or page limit. The brief in support is part of the same document (a convention the exemplar
// follows); no rule requires a separate memorandum. Typography is tier 2; see ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each is a convention or a rule; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")     // no typeface is mandated; the exemplar's Times (vendored)
#let type-size = 12pt                // convention: 12 point, the size the exemplar uses
#let footnote-size = 10pt            // convention: footnotes one size smaller
#let para-indent = 0.5in             // first-line indent of numbered and unnumbered body paragraphs
#let number-box = 0.5in              // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let letter-box = 0.4in              // a lettered item's letter box, hanging (docx: Prayer Item)
#let quote-indent = 0.75in           // a block quotation's indent on both sides
#let subheading-hang = 0.5in         // a level-2 heading's wrapped lines (its letter is part of the text, as filed)
#let margin = 1in                    // convention: one inch on all sides; 8 1/2 x 11 is the court's paper
#let text-width = 8.5in - 2 * margin
#let caption-left = 3.4in            // width of the party column of the caption
#let caption-gutter = 0.25in         // between the party column and the case numbers
#let caption-pad = 10pt              // the caption rules stand off the party block by this much
#let case-pad = 0.1in                // the case numbers stand off the gutter
#let sig-left = 2.8in                // signature blocks: the date column
#let sig-gutter = 0.2in              // signature blocks: between the date and the signature column
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF IOWA")  // FRBP 9004(b)(1)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/iasb-motion-brief.lua sets the same twips).
#let pitch-body = 24pt               // convention: double-spaced body text, as the exemplar's body
#let pitch-single = 14pt             // caption, block quotations, signature blocks, sub-headings
#let pitch-note = 11.5pt             // footnotes, single-spaced at 10 pt
#let court-below = 24pt              // court name to the caption
#let caption-gap = 12pt              // caption, right column: above the title and above the hearing line
#let caption-below = 24pt            // the caption's rule to the text
#let heading-above = 12pt            // every heading: the space above it
#let subheading-below = 6pt          // levels 2 and 3: the space below them (level 1 sits on the body pitch)
#let quote-above = 6pt               // a block quotation's space above and below it
#let quote-below = 12pt
#let signature-above = 24pt          // the paragraph before a signature block to the block
#let part-above = 24pt               // a verification's or the certificate's title: the space above it
#let part-title-below = 12pt         // ... and below it

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iasb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, quotations).
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
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, body)

/// Single-spaced lines, one paragraph each.
#let line-stack(items) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  for i in items { line-block(if type(i) == str { inl(i) } else { i }) }
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content, sticky: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  par(first-line-indent: (amount: para-indent, all: true), unloose(content)))

/// A numbered paragraph: the number in its box after the first-line indent, then the text.
#let numbered(n, content) = body-par[#box(width: number-box)[#n.]#unloose(content)]

/// A signature block: the date (left), the signature lines (right); `above` its space from the text before it.
#let signature-grid(date, lines) = block(width: 100%, breakable: false, above: signature-above, below: 0pt, grid(
  columns: (sig-left, sig-gutter, text-width - sig-left - sig-gutter),
  line-stack(("Dated: " + date,)),
  [],
  line-stack(lines),
))

/// The centred bold title of a verification or of the certificate.
/// It opens the block of its part; the space above the part is spacing of its own, v(part-above), which stays behind
/// when the part moves to the next page (docx: an empty paragraph of that height).
#let part-title(s) = block(width: 100%, sticky: true, above: 0pt, below: part-title-below, {
  set text(..edges(pitch-single))
  align(center, text(weight: "bold", upper(s)))
})

// ---------------------------------------------------------------------------
// Caption: court, debtor on the left; case number, chapter and the document's title on the right.
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  for line in court-name { line-block(align(center, text(weight: "bold", line))) }
  let left = ("In re:",) + meta.debtors + (meta.debtor_role,)
  let right = ("Case No. " + meta.case_number, "Chapter " + meta.chapter)
  if "adv_number" in meta and meta.adv_number != "" {
    right.push("Adv. Proc. No. " + meta.adv_number)
  }
  if "label" in meta and meta.label != "" {
    right.push(text(weight: "bold", meta.label))
  }
  // The rules beside and under the party column run the height of the caption (docx: the cell's borders).
  block(above: court-below, below: caption-below, grid(
    columns: (caption-left, caption-gutter, text-width - caption-left - caption-gutter),
    grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-pad, bottom: caption-pad),
      line-stack(left)),
    [],
    pad(left: case-pad, {
      line-stack(right)
      line-block(above: caption-gap, text(weight: "bold", inl(meta.brief_title)))
      if "hearing" in meta and meta.hearing != "" {
        line-block(above: caption-gap, inl(meta.hearing))
      }
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered lists, block quotations, footnotes
// ---------------------------------------------------------------------------

/// A heading is kept with the block after it, so it never ends a page. Level 1: a centered section in capitals on
/// the body pitch. Level 2: a bold sub-heading with a hanging indent; level 3 bold italic; both single-spaced.
#let heading-block(level, s) = {
  if level == 1 {
    block(width: 100%, sticky: true, above: heading-above, below: 0pt,
      align(center, text(weight: "bold", upper(s))))
  } else {
    set text(..edges(pitch-single))
    block(width: 100%, sticky: true, above: heading-above, below: subheading-below,
      if level == 2 {
        par(first-line-indent: 0pt, hanging-indent: subheading-hang, text(weight: "bold", inl(s)))
      } else {
        par(first-line-indent: 0pt, text(weight: "bold", style: "italic", inl(s)))
      })
  }
}

/// The footnote definitions of the body ("[^n]: text"). They are appended to each chunk that refers to them, because
/// cmarker resolves a reference only against the definitions in the same string.
#let footnote-definitions(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c.starts-with("[^")).join("\n\n")

/// The body in document order. Numbered paragraphs run 1, 2, ...; WHEREFORE paragraphs are unnumbered.
#let body-content(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = footnote-definitions(body)
  let with-notes(t) = t + if t.contains("[^") { "\n\n" + defs } else { "" }
  let n = 0
  let out = []
  for t in chunks {
    if t.starts-with("[^") {
      // A footnote definition is rendered with the paragraph that refers to it.
    } else if t.starts-with("#") {
      let level = t.match(regex("^(#+)")).captures.at(0).len()
      out += heading-block(level, t.replace(regex("^#+[ \t]*"), ""))
    } else if t.starts-with(">") {
      // A block quotation is single-spaced and indented on both sides.
      out += block(width: 100%, above: quote-above, below: quote-below, pad(x: quote-indent, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        inl(with-notes(t.replace(regex("(?m)^>[ \t]?"), "")))
      }))
    } else if t.starts-with("- ") {
      // A list is lettered A., B., C.; the letter hangs in its box half an inch in.
      let items = t.split("\n").map(l => l.trim()).filter(l => l.starts-with("- ")).map(l => l.slice(2))
      for (i, item) in items.enumerate() {
        out += block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
          par(first-line-indent: 0pt, hanging-indent: letter-box,
            [#box(width: letter-box)[#numbering("A.", i + 1)]#unloose(inl(with-notes(item)))])))
      }
    } else if t.starts-with("WHEREFORE") {
      // Sticky: the conclusion stays on the page with the signature block that follows it.
      out += body-par(inl(with-notes(t)), sticky: true)
    } else {
      n += 1
      out += numbered(n, inl(with-notes(t)))
    }
  }
  out
}

/// Verifications (declarations under penalty of perjury), each with its own title, body and signature, on one page.
/// The body's list items are numbered paragraphs, as the motion's.
#let declarations-block(decls) = for d in decls {
  v(part-above)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    part-title(d.title)
    show enum: it => {
      let k = if it.start == auto { 1 } else { it.start }
      for item in it.children {
        if item.has("number") and item.number != none { k = item.number }
        numbered(k, item.body)
        k += 1
      }
    }
    block(width: 100%, above: 0pt, below: 0pt, {
      set par(first-line-indent: (amount: para-indent, all: true))
      cmarker.render(d.body, raw-typst: false, smart-punctuation: true)
    })
    signature-grid(d.date, ("/s/ " + d.signer, d.signer))
  })
}

/// Certificate of service, last in the document, on one page; the signature in the signature column.
#let certificate-block(svc) = v(part-above) + block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
  part-title(svc.title)
  body-par(inl(svc.text))
  block(above: signature-above, below: 0pt, pad(left: sig-left + sig-gutter, line-stack(("/s/ " + svc.signer, svc.signer))))
})

#let iasb-motion-brief(meta, body) = {
  // Every page numbered, bottom centre; the number in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. Lists are laid out here (list-indent:
  // none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: 6pt, clearance: 12pt, indent: 0pt)
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  caption(meta)

  if "lead_in" in meta { body-par(inl(meta.lead_in)) }

  body-content(body)
  signature-grid(meta.date, ("/s/ " + meta.signature.signer,) + meta.signature.lines)
  if "declarations" in meta { declarations-block(meta.declarations) }
  if "service" in meta { certificate-block(meta.service) }
}
