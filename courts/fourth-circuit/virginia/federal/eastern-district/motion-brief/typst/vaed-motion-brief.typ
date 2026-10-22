// Memorandum in support of a motion for the U.S. District Court for the Eastern District of Virginia (vaed).
// Rules (E.D. Va. Local Civil Rules, amended Dec. 1, 2024): L.R. 7(F)(1) (a brief accompanies each motion),
// 7(F)(3) (all briefs, including footnotes, in 12 point Roman, one-inch margins, double-spaced; opening
// brief not more than 30 pages), 7(B) (attorney's office address and telephone). Fed. R. Civ. P. 7(b)(1),
// 12(b)(6) (the motion this memorandum supports). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter and body, never from here.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (README.md, Known gaps)
#let type-size = 12pt                   // L.R. 7(F)(3): 12 point Roman, footnotes included (set below)
#let margin-in = 1in                    // L.R. 7(F)(3): one-inch margins
#let para-indent = 0.5in                // first-line indent of body text
#let label-w = 0.5in                    // the box a heading's label ("I.", "A.") hangs in
#let max-pages = 30                     // L.R. 7(F)(3): an opening brief shall not exceed 30 pages (exhibits and affidavits excluded)
#let caption-w = 3.3in                  // width of the party box in the caption
#let caption-inset = 0.15in             // the party box's inner margin, every side
#let caption-gutter = 0.25in            // between the party box and the case number
#let designation-indent = 1.4in         // "Plaintiff," / "Defendants." inside the party box
#let sig-indent = 3.25in                // the signature column, from the left margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                  // L.R. 7(F)(3) double spacing: a 24 pt pitch at 12 pt (body and headings)
#let pitch-single = 13.8pt              // single spacing (court title, caption, title, signature, service list): Word's single line, 1.15 x 12 pt
#let gap = 24pt                         // around the caption and the title: one double-spaced line
#let sig-gap = pitch-single             // inside the caption and the signature block: one single-spaced line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if m == none { panic("vaed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, bold, smart quotes) in a paragraph, heading or frontmatter value.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body, trimmed, without empty ones.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(s => s.trim()).filter(s => s != "")

/// Heading level and text of a `#`-prefixed chunk, or none.
#let heading-of(c) = {
  let m = c.match(regex("^(#{1,3})\\s+(.*)$"))
  if m == none { none } else { (level: m.captures.at(0).len(), text: m.captures.at(1)) }
}

/// Split "I. Title" or "A. Title" into the label ("I.") and the rest, so the label hangs in its box.
#let label-of(t) = {
  let m = t.match(regex("^([IVX]+|[A-Z]|\\d+)\\.\\s+(.*)$"))
  if m == none { (none, t) } else { (m.captures.at(0) + ".", m.captures.at(1)) }
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

/// A double-spaced body paragraph with a first-line indent.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// A heading at the body pitch, kept with what follows: level 1 centered capitals; levels 2 and 3 with the label in
/// a box and the text hanging after it, level 3 half an inch further in.
#let heading-block(hd) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if hd.level == 1 {
    align(center, strong(upper(hd.text)))
  } else {
    let (label, rest) = label-of(hd.text)
    pad(left: if hd.level == 2 { 0pt } else { label-w }, if label == none {
      strong(inl(rest))
    } else {
      par(hanging-indent: label-w, strong[#box(width: label-w, label)#inl(rest)])
    })
  }
})

/// The signature block (L.R. 7(B): office address and telephone are in the lines). `full`: with the date line, the
/// closing and the party (the brief's own signature); without, the signer's lines alone (the certificate's).
#let signature-lines(sig, full: true) = {
  if full and sig.at("date", default: none) != none { line-block(above: gap)[Date: #inl(sig.date)] }
  let first = true
  for k in if full { ("closing", "party", "by") } else { ("by",) } {
    if sig.at(k, default: none) != none {
      line-block(above: if first { gap } else { sig-gap }, left: sig-indent, inl(sig.at(k)))
      first = false
    }
  }
  for (i, l) in sig.lines.enumerate() {
    line-block(above: if i == 0 { if first { gap } else { sig-gap } } else { 0pt }, left: sig-indent, inl(l))
  }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let vaed-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin-in,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("¶¶ 3"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // Footnotes are part of the brief and carry the same 12 point type (L.R. 7(F)(3)).
  show footnote.entry: set text(size: type-size)

  // Court title, lines as the sample gives them: bold, single-spaced, centered.
  let court = meta.court
  for (i, line) in court.enumerate() {
    line-block(below: if i == court.len() - 1 { gap } else { 0pt }, align(center, strong(inl(line))))
  }

  // Caption: the party box on the left, the case number on the right, on the line of the first "v." (Fed. R. Civ.
  // P. 10(a)).
  let parties = meta.caption.parties
  let first-lines = parties.first().lines.len() + if parties.first().at("designation", default: none) != none { 1 } else { 0 }
  grid(
    columns: (caption-w, caption-gutter, 1fr),
    block(width: caption-w, stroke: 0.75pt + black, inset: caption-inset, above: 0pt, below: 0pt, {
      for (i, p) in parties.enumerate() {
        for line in p.lines { line-block(inl(line)) }
        if p.at("designation", default: none) != none { line-block(left: designation-indent, inl(p.designation)) }
        if i < parties.len() - 1 { line-block(above: sig-gap, below: sig-gap)[v.] }
      }
    }),
    [],
    line-block(above: 0pt, {
      v(caption-inset + first-lines * pitch-single + if parties.len() > 1 { sig-gap } else { 0pt })
      inl(meta.caption.case_number)
    }),
  )

  // Title of the paper: centered, bold, underlined (as the filed captions carry it), single-spaced.
  line-block(above: gap, below: gap, align(center, underline(strong(inl(meta.brief_title)))))

  // Body: headings and paragraphs (no numbered allegations in a brief). The last paragraph is kept on the
  // page with the signature block, so a signature never stands alone on a page.
  let all = chunks(body)
  let sig = meta.at("signature", default: none)
  for (i, c) in all.enumerate() {
    let hd = heading-of(c)
    if hd != none {
      heading-block(hd)
    } else if sig != none and i == all.len() - 1 {
      block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
        body-par(inl(c))
        signature-lines(sig)
      })
    } else {
      body-par(inl(c))
    }
  }

  // The certificate of service on its own page: the statement, the persons served, the signer.
  if meta.at("certificate", default: none) != none {
    let cert = meta.certificate
    pagebreak(weak: true)
    block(width: 100%, above: 0pt, below: 0pt, sticky: true, align(center, strong(upper(cert.title))))
    body-par(inl(cert.text))
    // the persons served, an empty entry ending one address: each address after a single-spaced blank line (the first
    // child's space above does not leave its container, so the container carries it)
    block(breakable: false, width: 100%, above: sig-gap, below: 0pt, {
      let above = sig-gap
      for l in cert.served {
        if l == "" { above = sig-gap } else { line-block(above: above, inl(l)); above = 0pt }
      }
    })
    if sig != none {
      block(breakable: false, width: 100%, above: gap, below: 0pt, signature-lines(sig, full: false))
    }
  }

  // The 30-page cap (L.R. 7(F)(3)): the build fails if the brief runs longer.
  context {
    let pages = counter(page).final().first()
    if pages > max-pages {
      panic("vaed-motion-brief: " + str(pages) + " pages exceed the " + str(max-pages) + "-page limit of Local Civil Rule 7(F)(3)")
    }
  }
}
