// Motion to dismiss with memorandum of points and authorities for the U.S. District Court for the
// District of Nevada (nvd). One filed document: LR 7-2(a) (the motion and its memorandum "must be combined
// into a single document that complies with the page limits in LR 7-3"), LR 7-3(b) (24 pages for a motion
// other than summary judgment), LR IA 10-1 (numbered lines, 28 per page, double-spaced text, 12 pt or larger,
// one-inch margins, numbered pages; quotations over 50 words indented and single spaced), LR IA 10-2 (first-page
// format). Fed. R. Civ. P. 12(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is explicit; the docx
// engine (docx/nvd-motion-brief.lua, docx/reference.xml) sets the same twips. Every vertical length below is a whole
// multiple of 4.6 pt (92 twips), and a run of single lines is set off that lattice by single-shift, so each single
// line's baseline is level with a line number or at least 4.6 pt clear of it (the numbers are text in the PDF, and
// this keeps each number on the same text line in both engines).
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR IA 10-1(a)(3) names no face: the house face (docs/FONTS.md)
#let type-size = 12pt                   // LR IA 10-1(a)(3): 12 pt or larger (the filed exemplar's size)
#let lines-per-page = 28                // LR IA 10-1(a)(1): no more than 28 numbered lines per page
#let page-w = 8.5in                     // LR IA 10-1(c): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 1in                   // LR IA 10-1(a)(6): margins at least one inch on all four sides
#let bottom-margin = 1in
#let pitch = 23pt                       // one numbered line (460 twips): 28 of them fit between the 1 in margins
#let pitch-single = 13.8pt              // a single-spaced line (276 twips): counsel, caption, quotations, signature
#let single-shift = 0.5pt               // space before a run of single lines (10 twips), and after it
#let single-resync = 4.1pt              // (82 twips): the run's lines sit level with a number or 4.6 pt clear of it
#let quote-gap = 4.6pt                  // more space above and below a quotation (92 twips)
#let left-margin = 1.5in                // room for the line numbers and the pleading rules
#let right-margin = 1in
#let number-right = 1.05in              // the line numbers end this far from the page's left edge (a one-digit number starts left of 1 in)
#let para-indent = 0.5in                // first-line indent of paragraphs; the heading label's box; the quotation's indents
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column's rule and the right column
#let caption-pad = 10pt                 // the party text stops this far left of the rule
#let caption-bottom = 8.7pt             // the bottom rule stands this far below the last party line (single-resync + 4.6 pt)
#let caption-right-pad = 0.1in          // the right column's text starts this far right of the gutter
#let designation-indent = 1.2in         // a party's designation stands this far in
#let sig-indent = 2.6in                 // the signature block's left edge
#let counsel-lines = 7                  // the counsel block occupies at least lines 1 to 7
#let footer-foot = 0.5in                // the footer's last line box ends this far above the page's bottom edge

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nvd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below; an empty string is
/// an empty single line.
#let line-block(above: 0pt, below: 0pt, left: 0pt, hang: 0pt, s) = block(width: 100%, above: above, below: below,
  if s == "" { v(pitch-single) } else {
    pad(left: left, {
      set text(..edges(pitch-single))
      par(first-line-indent: 0pt, hanging-indent: hang, inl(s))
    })
  })

/// A body block at the numbered pitch: `first` is the first-line indent.
#let body-block(first: 0pt, left: 0pt, hang: 0pt, sticky: false, align-to: left, body) = block(width: 100%,
  above: 0pt, below: 0pt, sticky: sticky, pad(left: left,
    align(align-to, par(first-line-indent: (amount: first, all: true), hanging-indent: hang, body))))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line (line boxes of the pitch from the top margin).
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: number-right, height: pitch,
        align(right, text(..edges(pitch), str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// The page number and, when the sample gives one, the paper's title, in single-spaced line boxes whose foot is
/// `footer-foot` above the page's bottom edge (LR IA 10-1(a)(5); 12 pt, LR IA 10-1(a)(3)).
#let footer-block(title) = {
  let n = if title == none { 1 } else { 2 }
  place(top + left, dx: left-margin, dy: page-h - footer-foot - n * pitch-single,
    block(width: page-w - left-margin - right-margin, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      align(center, context counter(page).display())
      if title != none { block(width: 100%, above: 0pt, below: 0pt, align(center, upper(title))) }
    }))
}

// ---------------------------------------------------------------------------
// Cover: counsel (single spaced, LR IA 10-2), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Counsel on lines 1 to 7 at least: single lines (an empty one is a blank line), then the space left to the 8th
/// numbered line (a longer block is followed by single-resync), then a blank numbered line.
#let counsel-block(meta) = {
  let h = meta.counsel.len() * pitch-single
  let target = calc.max(counsel-lines * pitch, single-shift + h + single-resync)
  v(single-shift)
  for c in meta.counsel { line-block(c) }
  v(target - single-shift - h)
  v(pitch)
}

#let caption(meta) = block(width: 100%, above: 0pt, below: 0pt, breakable: false, grid(
  columns: (caption-left, caption-gutter, 1fr),
  stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
  inset: (x, y) => if x == 0 { (top: single-shift, right: caption-pad, bottom: caption-bottom) } else if x == 2 {
    (top: single-shift, left: caption-right-pad, bottom: single-resync) } else { 0pt },
  {
    // Each party: its names, then its designation (indented); the separator ("v." or "vs.") between the parties,
    // a single line clear above and below it.
    let sep = meta.caption.at("separator", default: "v.")
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block(above: pitch-single, below: pitch-single, sep) }
      for n in p.names { line-block(n) }
      line-block(left: designation-indent, p.designation)
    }
  },
  [],
  {
    line-block("Case No.: " + meta.case_number)
    line-block(above: pitch-single, "**" + meta.brief_title + "**")
  },
))

#let cover(meta) = {
  counsel-block(meta)
  body-block(align-to: center, strong("UNITED STATES DISTRICT COURT"))
  body-block(align-to: center, strong("DISTRICT OF NEVADA"))
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body, signature, certificate of service
// ---------------------------------------------------------------------------

/// The date, a blank numbered line, then the signature block at `sig-indent`: the firm, a single line clear,
/// "By: /s/" and the signer's lines. One block that does not break.
#let signature-block(meta) = block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
  body-block(inl(meta.date))
  v(pitch + single-shift)
  for l in meta.signature.firm { line-block(left: sig-indent, l) }
  line-block(above: pitch-single, left: sig-indent, "By: /s/ " + meta.signature.signer)
  for l in meta.signature.lines { line-block(left: sig-indent, l) }
})

/// The certificate of service, on its own page after the signature (as in the exemplar): its heading, its
/// paragraphs (markdown) double spaced, then the service list half an inch in and, a numbered line below it, the
/// signature, both single spaced.
#let certificate-block(cert) = {
  pagebreak()
  body-block(align-to: center, strong("CERTIFICATE OF SERVICE"))
  for p in cert.paragraphs { body-block(first: para-indent, inl(p)) }
  v(single-shift)
  for r in cert.recipients { line-block(left: para-indent, r) }
  v(pitch)
  line-block(left: sig-indent, "By: /s/ " + cert.signer)
  for l in cert.lines { line-block(left: sig-indent, l) }
}

/// A heading's label ("I.", "A.") in a box of the paragraph indent, the text hanging after it.
#let labelled(text) = {
  let m = text.match(regex("^([IVXLC]+\\.|[A-Z]\\.|\\d+\\.)\\s+(.*)$"))
  if m == none { strong(inl(text)) } else { strong[#box(width: para-indent, m.captures.at(0))#inl(m.captures.at(1))] }
}

/// The memorandum. Each blank-line-separated chunk of markdown is one paragraph (first-line indent, double spaced),
/// a heading or a quotation. Paragraphs are not numbered in a memorandum. A heading stays on the page of the block
/// after it. A quotation is single spaced and indented half an inch on both sides (LR IA 10-1(a)(4)); its paragraphs
/// follow one another without space, and a number opening one ("1.") is text, as typed. The last paragraph and
/// `tail` (the signature block) form one block that does not break, so the signature never stands alone on a page.
#let memorandum(body, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let i = 0
  while i < chunks.len() {
    let t = chunks.at(i).trim()
    let h = t.match(regex("^(#+)\\s+(.*)$"))
    if h != none {
      let text = h.captures.at(1).trim()
      if h.captures.at(0).len() == 1 {
        body-block(sticky: true, align-to: center, strong(upper(inl(text))))
      } else {
        body-block(sticky: true, left: para-indent, hang: para-indent, labelled(text))
      }
      i += 1
    } else if t.starts-with(">") {
      // consecutive quoted chunks (a blank line inside a quotation) are one quotation
      let paras = ()
      while i < chunks.len() and chunks.at(i).trim().starts-with(">") {
        for p in chunks.at(i).trim().replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")) {
          if p.trim() != "" {
            // a number opening the paragraph is text; a straight double quote ending it closes a quotation (cmarker
            // would open one: the paragraph holds no opening mark), as pandoc reads it
            paras.push(p.trim().replace(regex("^(\\d+)\\.([ \\t])"), m => m.captures.at(0) + "\\." + m.captures.at(1))
              .replace(regex("(\\S)\"$"), m => m.captures.at(0) + "\u{201D}"))
          }
        }
        i += 1
      }
      v(quote-gap + single-shift)
      for p in paras {
        block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent, right: para-indent, line-block(p)))
      }
      v(single-resync + quote-gap)
    } else {
      if i == chunks.len() - 1 {
        block(width: 100%, breakable: false, above: 0pt, below: 0pt, { body-block(first: para-indent, inl(t)); tail })
      } else { body-block(first: para-indent, inl(t)) }
      i += 1
    }
  }
}

#let nvd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.at("footer_title", default: none)),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // numbered pitch.
  show: xengine.with(pitch: pitch, list-indent: none)

  cover(meta)
  memorandum(body, signature-block(meta))
  if "certificate" in meta and meta.certificate != none {
    certificate-block(meta.certificate)
  }
}
