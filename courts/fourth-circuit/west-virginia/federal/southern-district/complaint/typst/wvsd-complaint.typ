// Complaint, United States District Court, S.D. W. Va. (wvsd).
// Rules: Fed. R. Civ. P. 8(a) (short and plain statement; jurisdiction; demand for relief), 10(a) (caption),
// 10(b) (numbered paragraphs); LR Civ P 3.4(a) (civil docket cover sheet is submitted with any complaint).
// The local rules set no paper or typeface rule for a complaint (LR Civ P 7.1(a)(3)-(4) apply to memoranda),
// so the layout follows the memorandum template (wvsd motion-brief) for one court-wide look. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // as the memorandum (LR Civ P 7.1(a)(4) presumed-legible list); Liberation Serif is its metric twin (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // 12 point, as LR Civ P 7.1(a)(4) requires for memoranda
#let margin = 1in                       // at least one inch on all four sides (LR Civ P 7.1(a)(3))
#let para-indent = 0.5in                // the number of an allegation sits at this indent, its text a box later
#let num-box = 0.5in                    // the box of an allegation's or a verification item's number
#let heading-tab = 0.5in                // a heading's number box; each deeper level starts this much further in
#let quote-indent = 0.5in               // block quotations, both sides
#let caption-left = 3.7in               // width of the party column of the caption (wide enough for a party's address on one line)
#let caption-paren = 0.3in              // the column of ")" marks between parties and the case number
#let caption-right-pad = 0.2in          // the case number and judge stand this far right of the ")" column
#let block-indent = 3.25in              // signature block starts here
#let toc-col = 36pt                     // the page column of the table of contents
#let toc-gap = 6pt                      // above each row of the table of contents

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/reference.xml and the filter set the same twips).
#let pitch-body = 24pt                  // double spacing (LR Civ P 7.1(a)(3) for memoranda): a 24 pt pitch at 12 pt
#let pitch-single = 13.8pt              // single spacing (caption, headings, table of contents, quotations, footnotes, signature): Word's single line, 1.15 x 12 pt
#let h1-above = 18pt                    // space above a level-1 heading
#let h-above = 12pt                     // space above a deeper heading
#let h-below = 12pt                     // space below every heading
#let quote-gap = 12pt                   // above and below a block quotation
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 12.6pt            // between the text and the footnote rule

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvsd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, addresses, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line (or paragraph) with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

/// A paragraph at the body pitch.
#let body-par(above: 0pt, first: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  pad(left: left, [#h(first)#body]))

/// Heading numbers, set by the template (never typed in the sample). Level 1 I., level 2 A., level 3 1.,
/// level 4 (i), level 5 (1), level 6 (A).
#let heading-numbering(..n) = {
  let level = n.pos().len()
  let num = n.pos().last()
  if level == 1 { numbering("I.", num) }
  else if level == 2 { numbering("A.", num) }
  else if level == 3 { numbering("1.", num) }
  else if level == 4 { numbering("(i)", num) }
  else if level == 5 { numbering("(1)", num) }
  else { numbering("(A)", num) }
}

/// Set while lists, enumerations and block quotations are laid out: their paragraphs are not allegations.
#let no-number = state("wvsd-complaint-no-number", false)

/// Allegations are numbered 1, 2, ... by the template (Fed. R. Civ. P. 10(b)); the counter runs through the body.
#let allegation = counter("wvsd-complaint-allegation")

// ---------------------------------------------------------------------------
// Cover page: court title, caption, title of the paper (the cover carries no page number)
// ---------------------------------------------------------------------------

/// The caption: one row per party line, a column of ")" marks, and the case number (and judge, if any) at the
/// right, in the rows at the middle of the caption. A side's `lead` is printed before it ("v." by default between
/// sides; "" for none). A blank row separates the sides.
#let caption(meta) = {
  let rows = ()
  for (k, side) in meta.caption.enumerate() {
    let lead = side.at("lead", default: if k == 0 { "" } else { "v." })
    if lead != "" { rows.push((0.5in, lead)) }
    for n in side.names { rows.push((0pt, n)) }
    rows.push((1.0in, side.designation))
    rows.push(none)
  }
  rows = rows.slice(0, rows.len() - 1)
  let right = ()
  if "civil_action" in meta { right.push(meta.civil_action) }
  if "judge" in meta { right.push(meta.judge) }
  let first = calc.floor((rows.len() - right.len()) / 2)
  let cells = ()
  for (i, r) in rows.enumerate() {
    cells.push(if r == none { line-block[] } else { line-block(left: r.at(0), inl(r.at(1))) })
    cells.push(line-block[)])
    let j = i - first
    cells.push(if j >= 0 and j < right.len() { line-block(left: caption-right-pad, inl(right.at(j))) } else { line-block[] })
  }
  block(above: 0pt, below: 0pt, grid(columns: (caption-left, caption-paren, 1fr), ..cells))
}

#let cover(meta) = {
  let court = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE SOUTHERN DISTRICT OF WEST VIRGINIA",
    upper(meta.division))
  for (i, l) in court.enumerate() {
    line-block(below: if i == court.len() - 1 { pitch-body } else { 0pt }, align(center, text(weight: "bold", l)))
  }
  caption(meta)
  line-block(above: pitch-body, align(center, text(weight: "bold", inl(meta.brief_title))))
}

// ---------------------------------------------------------------------------
// Table of contents: the number in a box at the heading's indent, the title hanging after it, a dot leader to
// the page column (the layout of lib/typst/xengine.typ listing-row, set in by the level).
// ---------------------------------------------------------------------------

#let toc-row(target, label, title, page, ind) = link(target, block(width: 100%, above: toc-gap, below: 0pt,
  breakable: false, inset: (left: ind), grid(columns: (1fr, toc-col), column-gutter: 0pt,
    par(hanging-indent: heading-tab, first-line-indent: 0pt, {
      box(width: heading-tab, label)
      title
      h(0.75em)
      box(width: 1fr, repeat[.])
    }),
    align(right + bottom, page))))

#let contents(depth) = {
  set text(..edges(pitch-single))
  line-block(below: h-below, align(center, text(weight: "bold")[TABLE OF CONTENTS]))
  context for h in query(heading).filter(h => h.level <= depth) {
    let loc = h.location()
    let label = numbering(heading-numbering, ..counter(heading).at(loc))
    let pg = numbering("1", ..counter(page).at(loc))
    toc-row(loc, label, h.body, pg, (h.level - 1) * heading-tab)
  }
}

// ---------------------------------------------------------------------------
// Signature and verification
// ---------------------------------------------------------------------------

/// Single-spaced lines at `left`; "" is a blank line (the next line stands one single line lower). `last`, if
/// given, is set at the left margin on the line of the last entry (the date beside the signature).
#let sig-lines(items, left: 0pt, above: 0pt, last: none) = {
  let skip = above
  let ls = ()
  for i in items {
    if i == "" { skip += pitch-single } else {
      ls.push((skip, i))
      skip = 0pt
    }
  }
  for (k, (sk, i)) in ls.enumerate() {
    if last != none and k == ls.len() - 1 {
      line-block(above: sk, [#box(width: left, inl(last))#inl(i)])
    } else {
      line-block(above: sk, left: left, inl(i))
    }
  }
}

/// The signature lines at the right, the date at the left on the line of the last of them, kept together.
#let signature-block(meta) = block(breakable: false, width: 100%, above: 24pt, below: 0pt,
  sig-lines(meta.signature, left: block-indent, last: meta.date))

/// A declaration under 28 U.S.C. § 1746 (verification), on its own page.
#let verification(v-meta) = {
  pagebreak()
  line-block(below: h-below, align(center, text(weight: "bold", underline(inl(v-meta.heading)))))
  body-par(inl(v-meta.lead))
  for (k, item) in v-meta.items.enumerate() {
    body-par(left: para-indent)[#box(width: num-box)[#(k + 1).]#inl(item)]
  }
  body-par(above: 12pt)[Executed on #inl(v-meta.executed).]
  block(breakable: false, width: 100%, above: 36pt, below: 0pt,
    sig-lines(v-meta.signature, left: block-indent))
}

// ---------------------------------------------------------------------------
// The complaint: cover (no number), optional table of contents, body numbered from 1, signature, verification
// ---------------------------------------------------------------------------

#let complaint(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set heading(numbering: heading-numbering)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body)
  // A doubled sign stays with its number ("§§ 1331"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Headings: single-spaced, 12 pt (levels 1 to 3 bold), the number in a box at the level's indent and the text
  // hanging after it; kept with the text after them.
  show heading: it => context {
    let lv = it.level
    no-number.update(true)
    block(width: 100%, above: if lv == 1 { h1-above } else { h-above }, below: h-below, sticky: true, {
      set text(size: type-size, weight: if lv <= 3 { "bold" } else { "regular" }, ..edges(pitch-single))
      set par(first-line-indent: 0pt)
      pad(left: (lv - 1) * heading-tab, par(hanging-indent: heading-tab,
        [#box(width: heading-tab, counter(heading).display(it.numbering))#it.body]))
    })
    no-number.update(false)
  }
  show quote.where(block: true): it => {
    no-number.update(true)
    block(above: quote-gap, below: quote-gap, {
      set text(..edges(pitch-single))
      pad(x: quote-indent, it.body)
    })
    no-number.update(false)
  }
  // Footnotes: 12 pt, single-spaced (as the memorandum, LR Civ P 7.1(a)(3)-(4)): the mark, a space, the note
  // (Word's footnote layout), 7 pt between notes.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    [#super(num) #note.body]
  }

  cover(meta)

  let footer(fmt) = context align(center, text(..edges(pitch-single), counter(page).display(fmt)))
  if meta.at("toc", default: false) {
    pagebreak()
    set page(footer: footer("i"))
    counter(page).update(1)
    contents(meta.at("toc_depth", default: 2))
  }

  pagebreak()
  set page(footer: footer("1"))
  counter(page).update(1)

  // Unnumbered lead-in paragraphs: the address to the court is flush left; the paragraphs after it are indented.
  for (k, p) in meta.at("lead_in", default: ()).enumerate() {
    body-par(first: if k == 0 { 0pt } else { para-indent }, inl(p))
  }

  // The body: each paragraph is an allegation (numbered); lists, enumerations and quotations are not.
  {
    show par: it => context {
      if no-number.get() { it } else {
        allegation.step()
        body-par[#h(para-indent)#box(width: num-box)[#context allegation.display().]#it.body]
      }
    }
    show list: it => {
      no-number.update(true)
      it
      no-number.update(false)
    }
    show enum: it => {
      no-number.update(true)
      it
      no-number.update(false)
    }
    cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }

  signature-block(meta)

  if "verification" in meta { verification(meta.verification) }
}
