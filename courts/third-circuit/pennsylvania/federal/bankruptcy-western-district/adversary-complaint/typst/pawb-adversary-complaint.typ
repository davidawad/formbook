// Adversary complaint for the U.S. Bankruptcy Court, W.D. Pennsylvania (pawb).
// Rules: Fed. R. Bankr. P. 7010 (FRCP 10 applies; caption per Official Form 416D), 7008(a) (consent statement),
// W.PA LBR 7010-1 (caption: Form 416D plus the judge's initials after the case number), LBR 5005-13(b)
// (8.5 x 11 paper, sequential page numbers, paragraph numbers, 12-point type or larger including footnotes,
// text-searchable PDF), LBR 5005-6(d) (signature block). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Sans"    // no face is mandated (LBR 5005-13(b)(4) names Courier only as the size
                                        // benchmark); the audited exemplar's face, Arial's metrics (data/exemplar-fonts.json,
                                        // docs/FONTS.md), vendored; the only fonts typst may see (--ignore-system-fonts)
#let type-size = 12pt                   // LBR 5005-13(b)(4): "no smaller than 12 Courier or an equivalent font size"
#let margin = 1in                       // convention (both exemplars); no W.PA rule sets margins; LBR 5005-13(b)(1) letter
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                // first-line indent; a paragraph's number starts here ...
#let num-box = 0.5in                    // ... in a box this wide: the text starts 1 in in (docx: a tab at 1440)
#let cap-left = 3.4in                   // the caption's debtor and party column, ruled at its right ...
#let cap-rule = 0.75pt                  // ... (the debtor row also at its top, the party row at its foot)
#let cap-pad = 10pt                     // the party column's text this far from the rule
#let cap-gutter = 0.25in                // the case column's text this far right of the rule
#let cap-top1 = 6pt                     // the space below the top rule
#let cap-top2 = 12pt                    // the space above the parties
#let cap-below = 6pt                    // the space above the foot rule
#let desig-indent = 1.5in               // a designation ("Debtor.", "Plaintiff,")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/pawb.lua sets the same twips: 20 x pt).
#let pitch-body = 24pt                  // double spacing (docx 480)
#let pitch-single = 14pt                // court title, caption, title, signature, addresses, footer (docx 280)
#let cover-gap = 14pt                   // court title to caption, caption to title: a blank single line
#let title-below = 12pt                 // the title to the text
#let lines-gap = 14pt                   // a block of hard-broken lines (an address): a blank single line around it
#let sig-gap = 24pt                     // the signature block: above it, and between its parts
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pawb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// A single-pitch line (one paragraph; it wraps on single lines).
#let sline(content, above: 0pt, left: 0pt, align-to: left) = block(width: 100%, above: above, below: 0pt,
  pad(left: left, align(align-to, par(first-line-indent: 0pt, content))))

/// A body paragraph on the double pitch, its first line indented; `label` (a number) in a box `num-box` wide.
#let body-par(label, content) = block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: para-indent, {
  if label != none { box(width: num-box, label) }
  content
}))

/// Headings on the body pitch, bold, with no space of their own, kept with the block after them: level 1 centered
/// capitals (COUNT headings, CERTIFICATE OF SERVICE), level 2 centered, level 3 bold italic at the margin.
#let heading-block(level, body) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, par(strong(upper(body)))) }
  else if level == 2 { align(center, par(strong(body))) }
  else { par(strong(emph(body))) }
})

/// A chunk of hard-broken lines (an address), one single-pitch line each, a blank single line around it, kept whole.
#let hard-lines(t) = block(width: 100%, above: lines-gap, below: lines-gap, breakable: false, {
  set text(..edges(pitch-single))
  for l in t.split(regex("\\\\\\r?\\n")) { sline(inl(l.trim())) }
})

// ---------------------------------------------------------------------------
// Cover: court title, Form 416D caption, title of the paper
// ---------------------------------------------------------------------------

/// Form 416D: two rows; the left column (the debtor, then the parties) ruled at its right, the debtor row at its top
/// and the party row at its foot; the case column (case number and chapter, then the adversary number) beside it.
/// The rule runs the height of the row and a cell's top and bottom space is under both columns (LibreOffice takes a
/// cell's margin for the whole row; docx: a two-row table, the left cells bordered).
#let caption(meta) = {
  let row1-left = {
    sline[In re:]
    sline(inl(meta.debtor.name))
    sline(inl(meta.debtor.designation), left: desig-indent)
  }
  let row1-right = {
    sline[Case No. #meta.bankruptcy_case]
    sline(inl(meta.chapter))
  }
  let row2-left = {
    for (k, p) in meta.caption.parties.enumerate() {
      for (i, n) in p.names.enumerate() { sline(inl(n), above: if k > 0 and i == 0 { pitch-single } else { 0pt }) }
      sline(inl(p.designation), left: desig-indent)
    }
  }
  let adv = meta.at("adversary_number", default: "")
  let row2-right = sline(if adv != "" [Adv. Proc. No. #adv] else [Adv. Proc. No. \_\_\_\_\_\_\_\_\_\_\_\_\_\_])
  block(width: 100%, above: cover-gap, below: 0pt, breakable: false, grid(
    columns: (cap-left, 1fr),
    stroke: (x, y) => if x == 0 {
      if y == 0 { (right: cap-rule, top: cap-rule) } else { (right: cap-rule, bottom: cap-rule) }
    },
    inset: (x, y) => (
      top: if y == 0 { cap-top1 } else { cap-top2 },
      bottom: if y == 0 { 0pt } else { cap-below },
      left: if x == 0 { 0pt } else { cap-gutter },
      right: if x == 0 { cap-pad } else { 0pt },
    ),
    row1-left, row1-right, row2-left, row2-right,
  ))
}

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  sline(align-to: center, strong[IN THE UNITED STATES BANKRUPTCY COURT])
  sline(align-to: center, strong[FOR THE WESTERN DISTRICT OF PENNSYLVANIA])
  caption(meta)
  sline(above: cover-gap, align-to: center, strong(inl(meta.title)))
  v(title-below)
}

// ---------------------------------------------------------------------------
// Signature block: "/s/" above the name, then the name, Bar ID and address, phone and e-mail (LBR 5005-6(d))
// ---------------------------------------------------------------------------

/// Single lines at the margin: "Respectfully submitted,", the date, then each counsel block, `sig-gap` apart;
/// kept on one page.
#let signature-block(meta) = block(width: 100%, above: sig-gap, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  sline[Respectfully submitted,]
  sline(above: sig-gap)[Date: #meta.date]
  for b in meta.signature.blocks {
    sline(above: sig-gap)[/s/ #inl(b.signer)]
    for l in (upper(b.signer), b.pa_id) + b.lines { sline(inl(l)) }
  }
})

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, unnumbered lead-in, prayers and certificate
// ---------------------------------------------------------------------------

/// Numbered paragraphs (Fed. R. Bankr. P. 7010 applies FRCP 10(b); LBR 5005-13(b)(3)).
/// The text before the first heading is the unnumbered lead-in; a WHEREFORE clause is unnumbered (as in the
/// exemplar), as is the certificate. Each blank-line-separated chunk of markdown is one paragraph; a chunk with hard
/// line breaks (an address or a signature block) is set as single lines, unindented.
#let render-chunk(t, num) = {
  let h = t.match(regex("^(#{1,3})[ \\t]+(.*)$"))
  if h != none { heading-block(h.captures.at(0).len(), inl(h.captures.at(1))) }
  else if t.contains(regex("\\\\\\r?\\n")) { hard-lines(t) }
  else if num != none { body-par(str(num) + ".", inl(t)) }
  else { body-par(none, inl(t)) }
}

/// The chunks in order; `last` (the chunk the signature block follows) is kept on one page with it.
#let chunks-of(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

#let pawb-adversary-complaint(meta, body) = {
  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1408"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)

  // The certificate of service follows the signature block (exemplar order), so the body is split at it.
  let parts = body.split("# CERTIFICATE")
  let main = chunks-of(parts.at(0))
  let certificate = if parts.len() > 1 { chunks-of("# CERTIFICATE" + parts.slice(1).join("# CERTIFICATE")) } else { () }

  let n = 0
  let started = false
  for (i, t) in main.enumerate() {
    if t.starts-with("#") { started = true }
    let numbered = (started and not t.starts-with("#") and not t.starts-with("WHEREFORE")
      and not t.contains(regex("\\\\\\r?\\n")))
    if numbered { n += 1 }
    let it = render-chunk(t, if numbered { n } else { none })
    // the last chunk is kept on one page with the signature block, so the signature never stands alone
    if i + 1 == main.len() {
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, { it; signature-block(meta) })
    } else { it }
  }

  if certificate.len() > 0 {
    pagebreak()
    for t in certificate { render-chunk(t, none) }
  }
}
