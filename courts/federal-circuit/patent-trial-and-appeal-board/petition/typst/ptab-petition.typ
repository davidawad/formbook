// U.S. Patent and Trademark Office, Patent Trial and Appeal Board: petition for inter partes review.
//
// Rule-driven and content-agnostic. Requirement IDs (PTAB-PET-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed petition, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md, "Markdown contract").
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the next. The docx engine (../docx/) sets the same pitches and spaces (twips = 20 x pt).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // PTAB-PET-FORM-002: 14-point Times New Roman proportional font. Vendored metric-compatible stand-in (README, gap 1).
#let type-size = 14pt                      // PTAB-PET-FORM-002: footnotes and headers too (no exception).
#let pitch-double = 32pt                   // PTAB-PET-FORM-003: double spacing (Word's double line for 14-point Times, 32 pt).
#let pitch-single = 16pt                   // single spacing: headings, cover, contents, signature, certificates' lists, footnotes.
#let pitch-quote = 24pt                    // PTAB-PET-FORM-003: block quotations 1.5 spaced.
#let page-margin = 1in                     // PTAB-PET-FORM-004: at least 1 inch (2.5 cm) on all sides.
#let para-indent = 0.5in
#let label-box = 0.5in                     // a heading's or list item's label sits in a box this wide
#let toc-page-col = 36pt                   // the contents' page-number column
#let sig-indent = 3in                      // the signature block starts here
#let petition-word-limit = 14000           // PTAB-PET-LEN-001: 37 C.F.R. 42.24(a)(1)(i).
#let toc-depth = 2
#let running-title = "Petition for Inter Partes Review of"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, smart-punctuation: true, raw-typst: false)

/// Heading numbers: I. / A. / 1. / a. (a convention of the form, not a rule).
#let heading-number(..nums) = {
  let n = nums.pos()
  if n.len() == 1 { numbering("I.", n.at(0)) }
  else if n.len() == 2 { numbering("A.", n.at(1)) }
  else if n.len() == 3 { numbering("1.", n.at(2)) }
  else { numbering("a.", n.at(3)) }
}

#let need(meta, key) = {
  if key not in meta { panic("ptab-petition: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line block (cover, signature, service list): `above` pt before it, none after.
#let line-block(above, body, al: left, inset: 0pt) = block(above: above, below: 0pt, width: 100%,
  pad(left: inset, align(al, body)))

/// A centered bold heading of the front matter and the certificates (not numbered, not in the contents).
#let plain-heading(body) = block(above: 0pt, below: 16pt, sticky: true, width: 100%, {
  set text(..edges(pitch-single))
  align(center, strong(body))
})

// ---------------------------------------------------------------------------
// Cover (not numbered)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  line-block(0pt, al: center)[UNITED STATES PATENT AND TRADEMARK OFFICE]
  line-block(12pt, al: center)[BEFORE THE PATENT TRIAL AND APPEAL BOARD]
  line-block(34pt, al: center, strong(inl(need(meta, "petitioner").at("name"))))
  line-block(0pt, al: right, need(meta, "petitioner").at("role"))
  line-block(17pt, al: center)[v.]
  line-block(17pt, al: center, strong(inl(need(meta, "patent-owner").at("name"))))
  line-block(0pt, al: right, need(meta, "patent-owner").at("role"))
  line-block(34pt, al: center, need(meta, "patent-number"))
  line-block(12pt, al: center, need(meta, "patent-title"))
  line-block(12pt, al: center, need(meta, "case-number"))
  line-block(34pt, al: center, strong(need(meta, "title")))
}

// ---------------------------------------------------------------------------
// Signature block and certificates (PTAB-PET-FORM-008, -009)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  // "Dated:" 24 pt below the text above, the signature 32 pt below it (32 pt below the text when undated); the
  // block is never split. The space above is the block's own, so it holds inside a kept block too.
  block(breakable: false, above: if "date" in meta { 24pt } else { 32pt }, below: 0pt, {
    if "date" in meta { line-block(0pt)[Dated: #meta.date] }
    line-block(if "date" in meta { 32pt } else { 0pt }, inset: sig-indent)[/s/ #sig.signer]
    line-block(0pt, inset: sig-indent)[#sig.signer-name (Reg. No. #sig.reg-no)]
    for line in sig.at("lines", default: ()) { line-block(0pt, inset: sig-indent, line) }
  })
}

/// 10543 -> "10,543".
#let thousands(n) = {
  let s = str(n)
  let groups = ()
  while s.len() > 3 {
    groups.insert(0, s.slice(s.len() - 3))
    s = s.slice(0, s.len() - 3)
  }
  groups.insert(0, s)
  groups.join(",")
}

/// A certificate's statement: double spaced, first line indented, never split.
#let statement(body) = block(above: 0pt, below: 0pt, breakable: false, {
  set text(..edges(pitch-double))
  set par(first-line-indent: (amount: para-indent, all: true))
  par(body)   // a lone text in a block is not a paragraph in typst: no first-line indent without par()
})

#let certificate-of-word-count(meta) = {
  let words = need(meta, "word-count")
  if words > petition-word-limit {
    panic("ptab-petition: word count " + str(words) + " exceeds the " + str(petition-word-limit) + "-word limit (42.24(a)(1)(i))")
  }
  pagebreak(weak: true)
  plain-heading[CERTIFICATION UNDER 37 C.F.R. § 42.24]
  statement[Under the provisions of 37 C.F.R. § 42.24, the undersigned hereby certifies that the word count for the foregoing Petition for inter partes review (excluding the table of contents, table of authorities, mandatory notices, certificate of service or word count, and appendix of exhibits or claim listing) totals #thousands(words) words, which is within the word limit allowed under 37 C.F.R. § 42.24(a)(1)(i).]
  signature-block(meta)
}

#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  pagebreak(weak: true)
  plain-heading[CERTIFICATE OF SERVICE]
  statement[Pursuant to 37 C.F.R. §§ 42.6(e) and 42.105(a), the undersigned hereby certifies service on the Patent Owner of a copy of this Petition and its respective exhibits, by #svc.manner, on the following at the addresses shown:]
  {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    for party in svc.recipients {
      block(breakable: false, above: 12pt, below: 0pt, {
        line-block(0pt, inset: para-indent, party.name)
        for line in party.lines { line-block(0pt, inset: para-indent, line) }
      })
    }
  }
  signature-block(meta)
}

// ---------------------------------------------------------------------------
// Headings and the table of contents
// ---------------------------------------------------------------------------

#let style-heading(it) = {
  set text(size: type-size, ..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  let lab = if it.numbering != none { counter(heading).display(it.numbering) } else { none }
  if it.level == 1 {
    // Level 1: centered, bold, capitals.
    block(above: 16pt, below: 12pt, sticky: true, width: 100%,
      align(center, strong({ if lab != none { lab + " " }; upper(it.body) })))
  } else {
    // Levels 2 and deeper: flush left, bold (level 3 and deeper also italic).
    let body = if it.level >= 3 { emph(it.body) } else { it.body }
    block(above: 14pt, below: 10pt, sticky: true, width: 100%,
      strong({ if lab != none { lab + " " }; body }))
  }
}

/// One contents row: the label in a box at the heading's depth, the title hanging after it, a dot leader to the page.
#let toc-entry(it) = {
  let hd = it.element
  let ind = (hd.level - 1) * label-box
  let lab = if hd.numbering != none { numbering(hd.numbering, ..counter(heading).at(hd.location())) } else { none }
  listing-row(hd.location(), {
    h(ind)
    box(width: label-box, lab)
    hd.body
  }, it.page(), toc-page-col, ind + label-box, if hd.level == 1 { 10pt } else { 7pt })
}

// ---------------------------------------------------------------------------
// The petition
// ---------------------------------------------------------------------------

#let petition(meta, body) = {
  // Page setup: letter, 1-inch margins, 14-point Times New Roman everywhere.
  let folio = context block(above: 0pt, below: 0pt, width: 100%, align(center, counter(page).display()))
  set page(paper: "us-letter", margin: page-margin, numbering: none, footer-descent: 30%, footer: none)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, no kerning or ligatures, no hyphenation, double-spaced line boxes,
  // footnote marks at 58 %, list labels in a half-inch box, a section sign kept with its number.
  show: xengine.with(pitch: pitch-double, list-indent: label-box)
  set heading(numbering: heading-number)
  show heading: style-heading

  // Block quotations: indented from both margins, 1.5 spaced (42.6(a)(2)(iii)).
  show quote.where(block: true): it => block(above: 12pt, below: 12pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-quote))
    set par(first-line-indent: 0pt)
    it.body
  }))

  // Footnotes: 14-point, single spaced; the mark, a space, the note.
  set footnote.entry(gap: 7pt, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 7pt)   // footnotes do not inherit the body's par rules
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Cover: no page number.
  {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    cover(meta)
  }
  pagebreak()

  // Table of contents, roman page numbers.
  set page(numbering: "i", footer: { set text(..edges(pitch-single)); folio })
  counter(page).update(1)
  {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    plain-heading[TABLE OF CONTENTS]
    show outline.entry: toc-entry
    outline(title: none, depth: toc-depth, indent: 0pt)
  }
  pagebreak()

  // Body: arabic page numbers from 1; the running identification (PTAB-FORM-010) under the page number.
  set page(numbering: "1", footer: {
    set text(..edges(pitch-single))
    folio
    block(above: 0pt, below: 0pt, width: 100%, align(right, [#running-title #need(meta, "patent-number")]))
  })
  counter(page).update(1)
  counter(heading).update(0)
  // The last paragraph of the body is kept on the page of the signature block (unless the body ends with a
  // heading or a footnote definition), so the signature never stands alone on a page.
  let text-md = body.trim(at: end)
  let breaks = text-md.matches(regex("\n[ \t]*\n"))
  let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
  let tail = text-md.slice(cut)
  let keep = tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^")
  let render(s) = cmarker.render(s, smart-punctuation: true, raw-typst: false)
  if keep {
    render(text-md.slice(0, cut))
    block(breakable: false, above: 0pt, below: 0pt, { render(tail); signature-block(meta) })
  } else {
    render(text-md)
    signature-block(meta)
  }

  // Then the two certificates.
  certificate-of-word-count(meta)
  certificate-of-service(meta)
}
