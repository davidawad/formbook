// Memorandum of law in support of a motion for the United States District Court for the Northern District
// of New York (nynd). Rules: N.D.N.Y. L.R. 7.1(b)(1) (memorandum of law: 25 pages, double-spaced, unless
// leave; table of contents; numbered pages; the rule or statute the motion is based on), 10.1(a) (form:
// 12-point type, one-inch margins, double-spaced body, consecutive pages), 10.1(c)(1) (caption), 10.1(c)(2)
// (filer identification). See ../README.md. Content-agnostic: case words come from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")     // L.R. 10.1 names no typeface; Times New Roman, the house standard and the exemplar's face, vendored in fonts/
#let type-size = 12pt                // L.R. 10.1(a)(1): at least 12-point type, text and footnotes
#let margin = 1in                    // L.R. 10.1(a)(2): one-inch margins on all four sides
#let para-indent = 0.5in             // first-line indent of every body paragraph
#let list-indent = 0.5in             // bulleted items: the bullet in a box of half an inch, the text hanging after it
#let caption-left = 3.6in            // width of the party column in the caption
#let caption-gutter = 0.3in          // between the party column and the case column
#let caption-case-pad = 0.1in        // the case column's text this far into its column
#let caption-pad = 10pt              // the party column's text this far inside its rules (top and bottom)
#let between-indent = 0.5in          // "v." between the parties
#let designation-indent = 2in        // "Plaintiff," / "Defendants." under the names
#let cover-title-above = 144pt       // the paper's title six double lines below the caption, near the middle of the cover
#let cover-firm-above = 120pt        // the filing firm five double lines below the title, toward the foot of the cover
#let firm-indent = 3.25in            // the filing firm on the cover
#let toc-indent = 0.5in              // a contents row of heading level n stands (n - 1) x this far in
#let page-col = 0.5in                // the contents' page-number column; the title wraps before it
#let signature-w = 3.25in            // the signature column at the right
#let signature-gutter = 0.2in
#let by-line = 2.6in                 // the signature line after "By:"
#let quote-indent = 1in              // block quotations, both sides
#let rule = 0.75pt
#let max-pages = 25                  // L.R. 7.1(b)(1): a memorandum of law may not exceed 25 pages, double-spaced, unless leave

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt             // L.R. 10.1(a)(3): double-spaced body, 2 x the type size
#let pitch-single = 13.8pt           // single spacing, 1.15 x the size: cover, contents rows, quotations, footnotes,
                                     // signature (L.R. 10.1(a)(4) lets block quotations and footnotes be single-spaced)
#let quote-space = 12pt              // space above and below a block quotation
#let note-gap = 7pt                  // between two footnotes (docx: Footnote Text 140 twips after)
#let note-clearance = 12pt           // the body text to the footnote rule

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nynd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names, section signs, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it. An empty line keeps its
/// height.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

#let check-bar-roll(sig) = for s in sig.signers {
  assert(s.at("bar_roll", default: "") != "",
    message: "nynd-motion-brief: L.R. 10.1(c)(2) requires the bar roll number of each signing attorney (frontmatter: signature.signers[].bar_roll)")
}

// ---------------------------------------------------------------------------
// Cover and caption (L.R. 10.1(c)(1))
// ---------------------------------------------------------------------------

/// The court's name at the margin; a double line below it the caption: the party column between a rule above and
/// below, 10 pt off its text, "v." between the parties a single line apart and each designation under its names; the
/// case column with the case number and the judges' initials, its first line level with the party column's. Never
/// split.
#let caption(meta) = {
  assert(meta.at("judges", default: "") != "",
    message: "nynd-motion-brief: L.R. 10.1(c)(1) requires the assigned judge's initials in the caption (frontmatter: judges)")
  line-block[UNITED STATES DISTRICT COURT]
  line-block[NORTHERN DISTRICT OF NEW YORK]
  let left = for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { line-block(above: pitch-single, pad(left: between-indent, inl(meta.caption.between))) }
    for (i, n) in p.names.enumerate() { line-block(above: if k > 0 and i == 0 { pitch-single } else { 0pt }, n) }
    line-block(pad(left: designation-indent, inl(p.designation)))
  }
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-gutter, 1fr),
    block(width: 100%, inset: (top: caption-pad, bottom: caption-pad), stroke: (top: rule, bottom: rule), left),
    [],
    pad(left: caption-case-pad, top: caption-pad, line-block[Case No. #meta.case_number (#meta.judges)]),
  ))
}

/// The filing firm (L.R. 10.1(c)(2)), single-spaced: the firm in bold capitals, each signer's name, bar roll number
/// and e-mail, the address, the telephone and the role in italics.
#let firm-lines(sig, role) = {
  line-block(strong(upper(inl(sig.firm))))
  for s in sig.signers {
    line-block(s.name)
    line-block(s.bar_roll)
    line-block(s.email)
  }
  for a in sig.address { line-block(a) }
  line-block(sig.phone)
  line-block(emph(inl(role)))
}

/// The cover: caption, the title of the paper near the middle of the page, and the filing firm 3.25 in. from the
/// left margin toward the foot.
#let cover(meta) = {
  check-bar-roll(meta.signature)
  caption(meta)
  line-block(above: cover-title-above, align(center, strong(upper(inl(meta.brief_title)))))
  block(width: 100%, above: cover-firm-above, below: 0pt, breakable: false,
    pad(left: firm-indent, firm-lines(meta.signature, meta.counsel_role)))
}

// ---------------------------------------------------------------------------
// Table of contents (L.R. 7.1(b)(1): a table of contents with numbered pages), generated from the headings
// ---------------------------------------------------------------------------

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// The title, a double line below it the rows: single-spaced, a heading of level n (n - 1) x toc-indent in, the
/// title wrapping before the page column and a dot leader to its page.
#let toc() = {
  line-block(align(center, strong[TABLE OF CONTENTS]))
  block(width: 100%, above: pitch-double, below: 0pt, context {
    set text(..edges(pitch-single))
    for hd in query(heading.where(outlined: true)) {
      pad(left: toc-indent * (hd.level - 1),
        listing-row(hd.location(), hd.body, page-label(hd.location()), page-col, 0pt, 0pt))
    }
  })
}

// ---------------------------------------------------------------------------
// Signature block (L.R. 10.1(c)(2): signature, typed name, bar roll number, office address, telephone, e-mail)
// ---------------------------------------------------------------------------

/// A double line below the conclusion: the date at the left; the firm, a double line below it "By:" and the
/// signature line, the signing attorneys, a blank line, the address, telephone and role at the right. Never split.
#let signature-block(sig, role) = block(width: 100%, above: pitch-double, below: 0pt, breakable: false, grid(
  columns: (1fr, signature-gutter, signature-w),
  line-block[Dated: #inl(sig.dated)],
  [],
  {
    line-block(strong(upper(inl(sig.firm))))
    line-block(above: pitch-double)[By: #box(width: by-line, line(length: 100%, stroke: 0.5pt))]
    for s in sig.signers {
      line-block(s.name)
      line-block(s.bar_roll)
      line-block(s.email)
    }
    for (i, a) in sig.address.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, a) }
    line-block(sig.phone)
    line-block(emph(inl(role)))
  },
))

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let running-footer = context align(center,
  text(..edges(pitch-single), numbering(here().page-numbering(), ..counter(page).get())))

#let nynd-motion-brief(meta, body) = {
  assert("motion_basis" in meta and meta.motion_basis != "",
    message: "nynd-motion-brief: L.R. 7.1(b)(1) requires the moving party to specify the rule or statute the motion is based on (frontmatter: motion_basis)")
  // Pages numbered at the bottom, centered; the number in a single-spaced line box, where Word's footer sets it.
  set page(paper: "us-letter", margin: margin, footer-descent: 30%)
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // Every body paragraph indented half an inch, after a heading too (L.R. 10.1(a)(3): double-spaced).
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number; lists with the bullet in a half-inch box.
  show: xengine.with(pitch: pitch-double, list-indent: list-indent)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the type size (L.R. 10.1(a)(1)), single-spaced, 7 pt apart; the mark, a space, the text.
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    [#super(numbering(note.numbering, ..counter(footnote).at(note.location())))#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(width: 100%, above: quote-space, below: quote-space,
    pad(x: quote-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      it.body
    }))

  // Headings on the body pitch, bold, sticky: level 1 centered capitals (a POINT heading may run to two lines), level
  // 2 centered, level 3 at the margin.
  show heading: it => block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(upper(it.body))) }
    else if it.level == 2 { align(center, strong(it.body)) }
    else { strong(it.body) }
  })

  // Page 1: the cover (no page number).
  page(numbering: none, footer: none, cover(meta))

  // Front matter: the table of contents, numbered i, ii, ...
  set page(numbering: "i", footer: running-footer)
  counter(page).update(1)
  toc()
  pagebreak()

  // Body: numbered 1, 2, ... from the first page of text (the preliminary statement). The last section (the
  // conclusion) is kept whole with the signature block, so a sign-off never stands alone. The body is one markdown
  // document, so footnote references and their definitions resolve together: the conclusion is the text from the
  // last level-1 heading up to the first footnote definition.
  set page(numbering: "1", footer: running-footer)
  counter(page).update(1)
  let notes-at = body.position(regex("\n\[\^[^\]]+\]:"))
  let (text-part, notes) = if notes-at == none { (body, "") } else { (body.slice(0, notes-at), body.slice(notes-at)) }
  let parts = text-part.split("\n# ")
  if parts.len() > 1 {
    cmarker.render(parts.slice(0, -1).join("\n# ") + "\n" + notes, raw-typst: false, smart-punctuation: true,
      h1-level: 1)
    block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
      cmarker.render("# " + parts.last(), raw-typst: false, smart-punctuation: true, h1-level: 1)
      signature-block(meta.signature, meta.counsel_role)
    })
  } else {
    cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    signature-block(meta.signature, meta.counsel_role)
  }

  // L.R. 7.1(b)(1): the body (from the first numbered page to the end, signature included) may not exceed 25
  // pages, double-spaced, unless the judge granted leave (frontmatter: leave.pages).
  context {
    let limit = if "leave" in meta { meta.leave.pages } else { max-pages }
    let n = counter(page).final().first()
    assert(n <= limit,
      message: "nynd-motion-brief: the memorandum body is " + str(n) + " pages; L.R. 7.1(b)(1) allows " + str(limit) + " without leave (frontmatter: leave.pages)")
  }
}
