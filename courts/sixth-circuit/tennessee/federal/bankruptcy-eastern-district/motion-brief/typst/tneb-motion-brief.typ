// Memorandum (brief) in support of a motion, United States Bankruptcy Court, E.D. Tennessee (tneb).
// Rules (see ../README.md): FRBP 9004(a)-(b) (legible; caption with the court, title, case number and adversary
// number, and a designation of the document), E.D. Tenn. LBR 9004-1(a) (8 1/2 by 11 inches, double-spaced except
// quoted material, paginated at the bottom from page 2), LBR 9004-2(a) (the caption identifies the division and the
// case number with the judge's initials), LBR 9013-1(b) (the motion the brief supports states its grounds and the
// relief requested; the brief is filed with it), LBR 9013-3(b) (certificate of service: the paper served, and for
// each person served the name, service address, manner and date). The proposed order and the Notice of Hearing
// legend are separate papers (LBR 9013-1(c), (f)); not produced here (see README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter and body, never from this file. The
// markdown is rendered by cmarker; no coordinates measured off the exemplar, no forced line breaks.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no rule names a font for this court (LBR 9004-1 is silent); Times New Roman substitute, vendored in /fonts (docs/FONTS.md), the face of the filed exemplar
#let type-size = 12pt                   // the usual 12-point text; the rules set no minimum for this court
#let margin = 1in                       // 1-inch margins (convention; the exemplar's are the same); LBR 9004-1(a): 8 1/2 by 11 inches
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let label-box = 0.5in                  // a heading's typed label ("I.", "A.") in a box this wide, the text hanging after it
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-mid = 0.3in                // the ")" column
#let sig-indent = 3.25in                // the signature block and the certificate's signer
#let served-gutter = 0.3in              // between the two columns of persons served

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                  // double spacing at 12 pt (LBR 9004-1(a)): body paragraphs, the certificate's text
#let pitch-single = 13.8pt              // single spacing (court title, caption, title, headings, signature, persons served, page number): Word's single line, 1.15 x 12 pt
#let gap = pitch-single                 // a blank single line: around the caption, between the signature's groups and the persons served
#let title-below = 12pt                 // the title to the lead-in paragraph
#let heading-gap = 12pt                 // above and below a heading, and below the certificate's title
#let block-gap = pitch-body             // the body to the signature block, and the persons served to the certificate's signer
#let served-above = 12pt                // the certificate's text to the persons served

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, bold, escapes, smart quotes) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, sticky: false, body) = block(width: 100%, above: above,
  below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, body)
  })

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (FRBP 9004(b); LBR 9004-2)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  line-block(align(center, strong("IN THE " + meta.court)))
  line-block(align(center, strong(meta.district)))
  if "division" in meta { line-block(align(center, strong(upper(meta.division)))) }
  // The caption: one single-spaced row per frontmatter row, the party text, a ")" and the case information.
  block(width: 100%, above: gap, below: 0pt, grid(
    columns: (caption-left, caption-mid, 1fr),
    ..meta.caption.map(r => (
      line-block(inl(r.at("left", default: ""))),
      line-block(align(center)[)]),
      line-block(inl(r.at("right", default: ""))),
    )).flatten(),
  ))
  // The designation of the paper (FRBP 9004(b)): bold, underlined, centered, single-spaced, as filed.
  line-block(above: gap, below: title-below, sticky: true, align(center, strong(underline(inl(meta.title)))))
}

// ---------------------------------------------------------------------------
// Body, signature and certificate of service
// ---------------------------------------------------------------------------

/// Blank-line-separated chunks of the markdown body.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// A heading (`#` a roman-numeral section, `##` a lettered argument): the typed label ("I.", "A.") in a half-inch
/// box and the text hanging after it; level 1 at the margin, bold and underlined, level 2 half an inch in,
/// underlined (as filed). Kept with the text after it.
#let heading-of(c) = {
  let level = c.match(regex("^#+")).text.len()
  let t = c.replace(regex("^#+[ \t]*"), "")
  let m = t.match(regex("^([IVXLC]+|[A-Za-z]|[0-9]+|[ivx]+)\\.[ \t]+([\\s\\S]*)$"))
  let (label, rest) = if m == none { (none, t) } else { (m.captures.at(0) + ".", m.captures.at(1)) }
  let style(x) = if level == 1 { strong(underline(x)) } else { underline(x) }
  line-block(above: heading-gap, below: heading-gap, sticky: true, left: if level >= 2 { label-box } else { 0pt },
    if label == none { style(inl(rest)) } else {
      par(hanging-indent: label-box, [#box(width: label-box, if level == 1 { strong(label) } else { label })#style(inl(rest))])
    })
}

/// A body paragraph: double-spaced, a half-inch first-line indent.
#let paragraph(c) = block(width: 100%, above: 0pt, below: 0pt, par(inl(c)))

/// The signature block at 3.25 in, single-spaced, a blank single line between its groups. Kept on one page.
#let signature(sig) = block(width: 100%, breakable: false, above: block-gap, below: 0pt, {
  if "lead" in sig { line-block(below: gap, left: sig-indent, inl(sig.lead)) }
  if "firm" in sig { line-block(below: gap, left: sig-indent, inl(sig.firm)) }
  if "by" in sig { line-block(left: sig-indent, inl(sig.by)) }
  for l in sig.at("lines", default: ()) { line-block(left: sig-indent, inl(l)) }
})

/// Certificate of service (LBR 9013-3(b)): the paper served, the persons served in two columns, the signer. On
/// its own page, as filed.
#let certificate(cert) = {
  pagebreak(weak: true)
  line-block(below: heading-gap, sticky: true, align(center, strong(underline[CERTIFICATE OF SERVICE])))
  block(width: 100%, above: 0pt, below: 0pt, par(inl(cert.text)))
  block(width: 100%, above: served-above, below: 0pt, breakable: false, grid(
    columns: (1fr, 1fr), column-gutter: served-gutter, row-gutter: gap,
    ..cert.served.map(s => s.split("\n").map(l => line-block(inl(l))).join()),
  ))
  line-block(above: block-gap, left: sig-indent, inl(cert.signer))
}

#let motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // LBR 9004-1(a): paginated consecutively at the bottom, beginning with the second page; the number centered in
    // a single-spaced line box (Word's footer).
    footer-descent: 30%,
    footer: context {
      if counter(page).get().first() > 1 {
        align(center, text(..edges(pitch-single), counter(page).display()))
      }
    },
  )
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body)
  // A doubled sign stays with its number ("¶¶ 2, 5"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  cover(meta)

  // The lead-in and the body; the last paragraph is kept on one page with the signature block, so the signature
  // never stands alone on a page.
  let cs = chunks(body)
  if "lead_in" in meta { cs = (meta.lead_in,) + cs }
  let tail = if cs.len() > 0 and not cs.last().starts-with("#") { cs.last() } else { none }
  let head = if tail == none { cs } else { cs.slice(0, -1) }
  for c in head {
    if c.starts-with("#") { heading-of(c) } else { paragraph(c) }
  }
  if "signature" in meta {
    block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
      if tail != none { paragraph(tail) }
      signature(meta.signature)
    })
  } else if tail != none { paragraph(tail) }
  if "certificate" in meta { certificate(meta.certificate) }
}
