// Complaint for the U.S. District Court for the Northern District of California (cand).
// Rules: Civil L.R. 3-4 (first page, numbered lines, text, footer), 3-5 (jurisdiction and divisional
// assignment paragraphs), 3-6 (jury demand); Fed. R. Civ. P. 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Civil L.R. 3-4(c)(2)(A): standard proportional font; the rule's example is Times New Roman (vendored, docs/FONTS.md)
#let type-size = 12pt                   // Civil L.R. 3-4(c)(2)(B): 12 point type or larger
#let footer-size = 10pt                 // the footer (page number, paper title, case number) is not text of the paper
#let lines-per-page = 27                // Civil L.R. 3-4(c)(2): no more than 28 lines per page
#let page-w = 8.5in                     // Civil L.R. 3-4(c)(1): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let number-col = 1in                   // the line numbers end this far from the page's left edge
#let para-indent = 0.5in                // first-line indent; the allegation number in a box of this width after it
#let list-indent = 0.5in                // prayer items: the label half an inch in, in a box of this width
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-inset = 10pt               // the party text stands off the caption's right rule
#let caption-pad = 8pt                  // the caption's bottom rule stands this far below the last party line
#let caption-gutter = 0.3in             // the right column starts this far right of the rule
#let signature-left = 2.8in             // the signing column starts here (the date at the margin)
#let counsel-lines = 7                  // Civil L.R. 3-4(a)(3): the court title starts on line 8

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // Civil L.R. 3-4(c)(2): double-spaced; the numbered lines are this pitch
#let pitch-single = 12pt                // counsel, caption and signature single spaced: two lines to a numbered line
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer
#let footer-top = 6pt                   // the footer starts this far below the last numbered line
#let footer-gap = 4pt                   // between the page number and the footer's title line
#let drop = 0.8 * (pitch - pitch-single) // a single-spaced run that starts on a numbered line drops this far, so its
                                        // first baseline (and every second one) is the numbered line's baseline

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cand-answer: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

/// One line block at the double pitch (a numbered line of its own).
#let grid-line(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, on the baselines of the body lines.
#let line-numbers() = {
  set text(font: font-family, size: type-size, ..edges(pitch))
  place(top + left, dy: top-margin, block(width: number-col, {
    set par(leading: 0pt, spacing: 0pt)
    for i in range(1, lines-per-page + 1) { block(width: 100%, above: 0pt, below: 0pt, align(right, str(i))) }
  }))
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// The footer (Civil L.R. 3-4(c)(3)): the page number centered, then the paper's title at the left and the case
/// number at the right, single spaced.
#let footer-block(title, case-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + footer-top,
  block(width: page-w - left-margin - right-margin, {
    set text(font: font-family, size: footer-size, ..edges(pitch-single))
    set par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt)
    block(width: 100%, above: 0pt, below: 0pt, align(center, context counter(page).display("-1-")))
    block(width: 100%, above: footer-gap, below: 0pt, [#upper(title)#h(1fr)CASE NO. #case-number])
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7), court title (line 8), caption, title of the paper
// ---------------------------------------------------------------------------

/// Counsel lines, single spaced; the court title then starts on numbered line 8 (Civil L.R. 3-4(a)(3)) unless more
/// counsel lines push it down ("except where additional space is required for counsel identification").
#let counsel-block(meta) = {
  v(drop)   // not weak: it holds at the top of the page
  for l in meta.counsel { line-block(l) }
}

#let court-title(meta, above) = {
  let lines = ("UNITED STATES DISTRICT COURT", "NORTHERN DISTRICT OF CALIFORNIA")
  if "division" in meta { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    grid-line(above: if i == 0 { above } else { 0pt }, align(center, text(weight: "bold", l)))
  }
}

/// The caption: the parties in a box ruled at its right and bottom; at its right the case number, the title of the
/// paper, the legend and the jury demand, half a numbered line apart.
#let caption(meta) = block(above: pitch + drop, below: 0pt, grid(
  columns: (caption-left, 1fr),
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for n in p.names { line-block(n) }
      line-block(p.designation)
    }
  }),
  pad(left: caption-gutter, {
    line-block("Case No. " + meta.case_number)
    line-block(above: pitch-single, text(weight: "bold", inl(meta.brief_title)))
    // An answer's dates and judge under the title ("Complaint Filed: July 17, 2026"), plain.
    for (i, l) in meta.at("caption_lines", default: ()).enumerate() {
      line-block(above: if i == 0 { pitch-single } else { 0pt }, inl(l))
    }
    if "legend" in meta and meta.legend != none {
      line-block(above: pitch-single, text(weight: "bold", upper(meta.legend)))
    }
    if "jury_demand" in meta and meta.jury_demand {
      line-block(above: pitch-single, text(weight: "bold", "DEMAND FOR JURY TRIAL"))
    }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta, calc.max(0pt, counsel-lines * pitch - drop - meta.counsel.len() * pitch-single))
  caption(meta)
  // An answer's body starts on the first page, on the numbered line after the one below the caption (the filed
  // answers in usage/): the caption ends between lines, so snap to the line grid (lines start at the top margin). The
  // marker block gives the caption's true end; `here()` inside the cross-engine line boxes does not.
  block(width: 100%, height: 0pt, above: 0pt, below: 0pt, [#metadata(none) <answer-caption-end>])
  context {
    let y = locate(<answer-caption-end>).position().y
    let past = calc.rem((y - top-margin) / 1pt, pitch / 1pt)
    v(pitch * 2 - past * 1pt)
  }
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block: the date at the margin; "Respectfully submitted,", the firm, the signature, the signer and
/// the signer's lines in the right-hand column, single spaced. It never breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch + drop, below: 0pt, grid(
  columns: (signature-left, 1fr),
  line-block("Dated: " + meta.date),
  {
    line-block("Respectfully submitted,")
    for (i, l) in meta.signature.firm.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, l) }
    line-block(above: pitch-single, "By: /s/ " + meta.signature.signer)
    line-block(meta.signature.signer)
    for l in meta.signature.lines { line-block(l) }
  },
))

/// A numbered allegation: the number after the first-line indent, in a box of the indent's width, then the text.
/// `keep`: the paragraph stays whole with the signature block after it.
#let allegation(n, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, par(first-line-indent: (amount: para-indent, all: true), {
    box(width: para-indent, [#n.])
    content
  }))

/// The level-1 headings after which paragraphs are no longer numbered responses: the jury demand, the affirmative
/// defenses and the prayer (the filed answers number only the paragraph-by-paragraph responses).
#let unnumbered-from = regex("(?i)^#\\s+.*(affirmative defenses|jury|prayer)")

/// An unnumbered paragraph: first-line indent, double spaced.
#let plain-para(content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, par(first-line-indent: (amount: para-indent, all: true), content))

/// Numbered responses. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one
/// numbered paragraph (Fed. R. Civ. P. 10(b)), answering the complaint's paragraph of the same number, until a
/// level-1 heading matching `unnumbered-from`; after it paragraphs are unnumbered. Headings and lists are rendered
/// unnumbered; a heading is sticky (kept with what follows it), as is the last block (kept with the signature block).
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  let numbered = true
  for (i, t) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      if t.match(unnumbered-from) != none { numbered = false }
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: 100%, above: 0pt, below: 0pt, sticky: last, pad(left: list-indent, md(t)))
    } else if not numbered {
      plain-para(md(t), keep: last)
    } else {
      n += 1
      allegation(n, md(t), keep: last)
    }
  }
}

#let cand-answer(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.case_number),
  )
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spaced); lists as a label box (list-indent) with the text hanging.
  show: xengine.with(pitch: pitch, list-indent: list-indent)
  // A doubled section sign stays with its number ("§§ 1114"; xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // A web address breaks only after "?", "=", "&", a hyphen or a slash that no digit (nor a second slash) follows:
  // each part is a box, so the PDF text keeps the author's characters. Without this typst breaks an address at any
  // character ("www.destinationcrm / .com"), which Word does not.
  show regex("(https?://|www\\.)\\S+"): it => {
    let parts = ("",)
    let cs = it.text.clusters()
    for (i, c) in cs.enumerate() {
      parts.last() += c
      let next = cs.at(i + 1, default: "")
      let prev = cs.at(i - 1, default: "")
      if c in ("?", "=", "&") or (c in ("/", "-") and next != "/" and not (c == "/" and prev == "/")
        and next.match(regex("^[0-9]$")) == none) { parts.push("") }
    }
    parts.filter(p => p != "").map(p => box(p)).join()
  }

  // Headings: one numbered line each, bold, kept with the text after them: level 1 a centered section in capitals,
  // level 2 centered, level 3 italic at the margin.
  show heading: it => block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, {
    set text(size: type-size, weight: "bold")
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, upper(it.body)) }
    else if it.level == 2 { align(center, it.body) }
    else { text(style: "italic", it.body) }
  })
  // Prayer items are numbered 1., 2., ... (the filed answers in usage/)
  set enum(numbering: "1.")

  cover(meta)

  if "lead_in" in meta {
    block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), inl(meta.lead_in)))
  }
  allegations(body)
  signature-block(meta)
}
