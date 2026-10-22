// Motion with memorandum for the U.S. District Court for the District of Oregon (ord).
// Rules: LR 10-1 (double spacing, 12-point minimum for all typewritten material including footers and footnotes,
// one-inch margins, no page numbers down the left margin, footer with a description and consecutive page numbers);
// LR 10-2 (counsel information upper left, court title centered, party names, case number at the center of the
// page, title); LR 7-1 (conferral certification in the first paragraph; the memorandum is combined with the motion
// in one document; table of contents and table of authorities for a memorandum over 20 pages, not generated here);
// LR 7-2(b) (35 pages or 11,000 words; not counted here). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no rule names a face; Times New Roman (vendored, docs/FONTS.md), as both filed exemplars
#let type-size = 12pt                   // LR 10-1(c): no smaller than 12 point, footer and footnotes included
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (LR 10-1(f)(1))
#let margin = 1in                       // LR 10-1(d): one inch on all four sides
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading3-indent = 0.5in            // a level 3 heading is set half an inch in
#let quote-inset = 0.5in                // a block quotation is indented half an inch on both sides
#let caption-split = text-width / 2     // LR 10-2(f): the case number starts at the center of the page
#let caption-gap = 0.3in                // between the party column and the center line
#let sig-col = 3.1in                    // the signature's right column starts here; the date sits left of it
#let service-indent = 0.5in             // the certificate's service list and method, half an inch in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/motion.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                  // LR 10-1(b): double-spaced; 27 lines fill the 9-inch text height
#let pitch-single = 13.8pt              // single spacing (LR 10-1(b) exceptions): counsel, caption, title, quotations, signature, footer
#let counsel-below = 1in                // LR 10-2(b): the court title at least one inch below the counsel information
#let caption-above = 12pt               // the court title to the caption
#let title-above = 24pt                 // LR 10-2(g): the title at least two lines below the case number
#let legend-above = 12pt                // the title to the legend ("(Oral Argument Requested)")
#let quote-gap = 12pt                   // above and below a block quotation
#let sig-above = 24pt                   // the last paragraph to the signature block
#let sig-by-gap = 12pt                  // the firm to the "By: /s/" line
#let service-gap = 12pt                 // the certificate's paragraph, service list and method apart
#let service-sig-above = 24pt           // the method to the certificate's signature
// LR 10-1(e)(1): the footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ord-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names with italics, section symbols, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Single-spaced lines, one paragraph each; an empty item is a blank single line. `above`: the space before the
/// first line; `left`: an indent. An item is a string (markdown) or content.
#let line-stack(items, above: 0pt, left: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let g = above
  for i in items {
    if i == "" { g += pitch-single } else {
      block(width: 100%, above: g, below: 0pt, pad(left: left, par(unloose(if type(i) == str { inl(i) } else { i }))))
      g = 0pt
    }
  }
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content, above: 0pt) = block(width: 100%, above: above, below: 0pt, par(unloose(content)))

// ---------------------------------------------------------------------------
// Cover: counsel (upper left, LR 10-2(a)), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// LR 10-2(b): the court title capitalized, centered and double-spaced, at least one inch below the counsel lines.
#let court-title(meta) = {
  let lines = meta.court.map(upper)
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    block(width: 100%, above: if i == 0 { counsel-below } else { 0pt }, below: 0pt,
      align(center, par(first-line-indent: 0pt, text(weight: "bold", l))))
  }
}

/// The caption: the parties single-spaced at the left margin (LR 10-2(d)), "vs." between them; from the page center
/// the case number on the line of the first plaintiff (LR 10-2(f)), the title of the paper in capitals,
/// single-spaced (LR 10-2(g)), and the legend.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("vs.") }
    rows += p.names + (p.designation,)
  }
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (caption-split - caption-gap, caption-gap, 1fr),
    line-stack(rows),
    [],
    {
      line-stack(("Case No. " + meta.case_number,))
      line-stack(above: title-above, (text(weight: "bold", inl(upper(meta.brief_title))),))
      if "legend" in meta and meta.legend != none { line-stack(above: legend-above, (meta.legend,)) }
    },
  ))
}

// ---------------------------------------------------------------------------
// Body, signature and certificate of service
// ---------------------------------------------------------------------------

/// Headings at the type size on the body pitch, with no space of their own, kept with the block after them: level 1
/// centered bold capitals; level 2 bold; level 3 bold, half an inch in.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set align(center) if level == 1
  pad(left: if level >= 3 { heading3-indent } else { 0pt },
    par(first-line-indent: 0pt, text(weight: "bold", if level == 1 { upper(unloose(inl(s))) } else { unloose(inl(s)) })))
})

/// A block quotation, single-spaced and indented on both sides (LR 10-1(b) exempts quotations from double spacing).
#let quotation(s) = block(width: 100%, above: quote-gap, below: quote-gap, pad(left: quote-inset, right: quote-inset, {
  set text(..edges(pitch-single))
  par(first-line-indent: 0pt, unloose(inl(s)))
}))

/// The body. Each blank-line-separated chunk of markdown is a `#` heading (levels 1 to 3), a `>` block quotation,
/// or a paragraph (first-line indent; motions are not numbered).
#let body-text(chunks) = for t in chunks {
  if t.starts-with("#") {
    let level = t.match(regex("^#+")).end
    heading-block(calc.min(level, 3), t.slice(level).trim())
  } else if t.starts-with(">") {
    quotation(t.replace(regex("(?m)^>[ \t]?"), ""))
  } else {
    body-par(inl(t))
  }
}

/// The signature block (Fed. R. Civ. P. 11(a)), single-spaced: "DATED:" and the date at the left of the first line;
/// the firm, "By: /s/" with the signer and the signer's lines in a column from `sig-col` (docx: a tab and a hanging
/// indent there).
#let signature-block(meta) = {
  let sig = meta.signature
  let lines = sig.firm.map(l => (l, 0pt))
  lines.push(("By: /s/ " + sig.signer, sig-by-gap))
  lines += sig.lines.map(l => (l, 0pt))
  block(width: 100%, above: sig-above, below: 0pt, {
    set text(..edges(pitch-single))
    for (i, (l, gap)) in lines.enumerate() {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if i == 0 [DATED: #meta.date])#unloose(inl(l))]))
    }
  })
}

/// Certificate of service: the form wording, with the document title, the date, the parties served and the method
/// filled from the sample, on a page of its own. Generated, not written by the author.
#let certificate-of-service(meta) = {
  let cos = meta.certificate_of_service
  pagebreak()
  heading-block(1, "CERTIFICATE OF SERVICE")
  body-par(inl("The undersigned declares under penalty of perjury, under the laws of the State of Oregon, that on "
    + cos.date + ", I arranged for service of the foregoing " + upper(meta.brief_title)
    + " on the party to this action as follows:"))
  line-stack(above: service-gap, left: service-indent, cos.served)
  line-stack(above: service-gap, left: service-indent, ("by: " + cos.method,))
  line-stack(above: service-sig-above, left: sig-col, ("s/ " + meta.signature.signer, meta.signature.signer))
}

#let ord-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // LR 10-1(e)(1): a footer on every page with the page number and a brief description of the document, 12 pt.
    footer-descent: footer-descent,
    footer: context par(first-line-indent: 0pt, text(..edges(pitch-single),
      [Page #counter(page).display() - #unloose(inl(upper(meta.footer_title)))])),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays whole and with its number ("¶¶ 28-29."): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  line-stack(meta.counsel)
  court-title(meta)
  caption(meta)
  pagebreak()

  // The last paragraph stays on the page with the signature block: a signature never starts a page alone.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  body-text(chunks.slice(0, -1))
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    body-text(chunks.slice(-1))
    signature-block(meta)
  })

  if "certificate_of_service" in meta { certificate-of-service(meta) }
}
