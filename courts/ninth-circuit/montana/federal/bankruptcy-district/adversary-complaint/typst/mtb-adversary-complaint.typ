// U.S. Bankruptcy Court, D. Montana: adversary proceeding complaint (FRBP 7001 et seq.).
//
// Rule-driven and content-agnostic. Requirement IDs (MTB-...) refer to ../README.md and ../../rules.md, which quote
// the rule text: Mont. LBR 5005-2 (format), LBR 9004-1 (case numbers), Fed. R. Bankr. P. 7008, 7010 (Fed. R. Civ.
// P. 10 applies to the form of an adversary complaint) and 9004(b) (caption). No case-specific text, no coordinates
// measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes
// from the YAML frontmatter of the sample. docx/mtb.lua writes the same document for the docx engine.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // no face in the LBR; Times New Roman, the house standard (docs/FONTS.md) and the exemplar's
#let type-size = 12pt                    // MTB-FORM-002: LBR 5005-2(a)(2), at least 12 point (the exemplar's size)
#let margins = 1in                       // MTB-FORM-003: LBR 5005-2(a)(3), no less than one-inch margins
#let text-width = 8.5in - 2 * margins
#let para-indent = 0.5in                 // first-line indent of each body paragraph
#let caption-left = 3.6in                // width of the party column of the caption
#let caption-stroke = 0.75pt             // the rules at the right and foot of the party column (docx: w:sz 6)
#let cap-pad = 6pt                       // caption text to the rules, and above each caption row
#let case-pad = 12pt                     // the case-number column's text to the party column's rule
#let sig-col = 3.2in                     // signature and certificate signer: the right column
#let addressee-indent = 0.5in            // certificate of mailing: the addressees

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/mtb.lua sets the same twips, 20 x pt).
#let pitch-double = 24pt                 // MTB-FORM-004: LBR 5005-2(a)(5), double-spaced: the body and its headings
#let pitch-single = 14pt                 // counsel block, caption, title, signature, certificate lines
#let court-above = 36pt                  // the counsel block to the court title
#let caption-above = 24pt                // the court title to the caption
#let title-above = 24pt                  // the caption to the title of the paper
#let title-below = 12pt                  // the title to the body
#let sig-above = 24pt                    // the last paragraph to the signature block
#let sig-gap = 12pt                      // signature: the address lines to the /s/ line
#let cert-above = 36pt                   // the signature block to the certificate
#let cert-gap = 12pt                     // certificate: title, text and addressees apart
#let cert-sig-above = 24pt               // certificate: the addressees to the signer

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mtb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mtb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: 0pt,
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
// Counsel block, court title, caption, title (MTB-FORM-005, MTB-CONT-001)
// ---------------------------------------------------------------------------

/// Attorney or party identification, upper left of the first page (LBR 5005-2(b)).
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
// Body: paragraphs (the sample types its own paragraph numbers, MTB-CONT-003) and headings
// ---------------------------------------------------------------------------

#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

#let chunks(body) = for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
  let t = c.trim()
  if t.starts-with("#") { inl(t) } else { body-par(inl(t)) }
}

// ---------------------------------------------------------------------------
// Signature block and certificate of mailing (MTB-CERT-001)
// ---------------------------------------------------------------------------

/// The date at the left, the signer's block in the right column; kept whole (LBR 5005-2(c): conformed /s/ signature).
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: sig-above, below: 0pt, grid(columns: (1fr, sig-col),
    line-block(inl(sig.date)),
    {
      lines(sig.at("preamble", default: ()))
      line-block(above: sig-gap, inl("By /s/ " + sig.signer))
      line-block(inl(sig.signer_role))
    },
  ))
}

/// Certificate of mailing: title, statement (double-spaced), addressees, the signer's conformed signature in the
/// right column; kept whole.
#let certificate(meta) = {
  let c = meta.at("certificate", default: none)
  if c != none {
    block(width: 100%, breakable: false, above: cert-above, below: 0pt, {
      line-block(align(center, strong(upper(c.title))))
      block(width: 100%, above: cert-gap, below: cert-gap,
        par(first-line-indent: (amount: para-indent, all: true), inl(c.text)))
      lines(c.at("addressees", default: ()), left: addressee-indent)
      line-block(above: cert-sig-above, left: text-width - sig-col, inl("/s/ " + c.signer))
      line-block(left: text-width - sig-col, inl(c.signer))
      line-block(left: text-width - sig-col, inl("Dated: " + c.date))
    })
  }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let mtb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "adversary_number", "court", "counsel", "caption", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  // MTB-FORM-001: 8 1/2 x 11 inch, one-sided; MTB-FORM-003: consecutive page numbers at the bottom, centered in a
  // single-pitch line box (where Word's footer sets it).
  set page(
    paper: "us-letter",
    margin: margins,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set document(
    title: need(meta, "title") + ", Adv. No. " + need(meta, "adversary_number"),
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
  certificate(meta)
}
