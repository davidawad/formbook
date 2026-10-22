// U.S. Bankruptcy Court, District of Hawaii: motion with a memorandum of points and authorities,
// filed in an adversary proceeding (FRBP 9013; LBR 9004-1, 9013-1, 9013-2).
//
// Rule-driven and content-agnostic. Requirement IDs (HIB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same sample file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // vendored in /fonts; the local rules name no typeface (HIB-FORM-008): the house face
#let type-size = 14pt                    // HIB-FORM-002: LBR 9004-1(b)(1), all memoranda including footnotes: 14-point type
#let margin = 1in                        // HIB-FORM-004: LBR 9004-1(b)(3): margins 1 inch from the edge
#let para-indent = 0.5in
#let heading-tab = 0.5in                 // a heading's label box; each deeper level half an inch further in
#let caption-inset = 0.2in               // the caption's text stands off the rule between its columns
#let caption-pad = 12pt                  // the bottom rule stands off the last party line
#let designation-indent = 1.8in          // a party's designation ("Plaintiff,") under its names
#let sig-column = 3.2in                  // the signature column, at the right
#let toc-col = 0.5in                     // the contents' page column
#let toa-col = 0.75in                    // the authorities' page column
#let toa-hang = 0.35in                   // an authority's lines after the first
#let row-gap = 8pt                       // between two rows of a table
#let note-gap = 7pt                      // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt              // from the text to the footnote rule: with note-gap, the space LibreOffice keeps above its separator
#let passim-threshold = 7                // an authority cited on this many pages or more is listed as "passim"

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 32.2pt               // HIB-FORM-003: double spacing, two single lines
#let pitch-single = 16.1pt               // a single line: 1.15 x the type size (Word's single line in this face); counsel,
                                         // caption, footnotes, tables, signature (LBR 9004-1(b)(2))

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("hib-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("hib-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own) with explicit space above it; an empty string is a blank
/// single line.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  if body == "" { block(height: pitch-single) } else {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(left: indent, if type(body) == str { inl(body) } else { body })
  })

// ---------------------------------------------------------------------------
// Headings: numbering
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", 3 "A.", 4 "1.", 5 "a.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) }
  else if lv == 3 { numbering("A.", k) }
  else if lv == 4 { numbering("1.", k) }
  else if lv == 5 { numbering("a.", k) }
  else { "" }
}

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = (level - 2) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities (LBR 9013-2(b))
// ---------------------------------------------------------------------------

/// A table's title, centered and bold, and its page column's heading at the right.
#let table-title(title, col) = block(width: 100%, sticky: true, above: 0pt, below: 0pt, {
  line-block(align(center, strong(title)))
  line-block(above: pitch-single, align(right, strong(col)))
})

/// The page label of a location.
#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// Table of contents from the body headings (levels 2 to 4). Level 1 is an unnumbered title and is not listed.
#let toc-section() = {
  table-title[TABLE OF CONTENTS][Page]
  context {
    set text(..edges(pitch-single))
    for hd in query(heading.where(outlined: true)) {
      if hd.level < 2 or hd.level > 4 { continue }
      let lab = heading-num(..counter(heading).at(hd.location()).slice(0, hd.level))
      let ind = label-indent(hd.level)
      // the label in its box at the level's indent, the title's lines hanging after it
      listing-row(hd.location(), {
        h(ind)
        box(width: heading-tab, lab)
        hd.body
      }, page-label(hd.location()), toc-col, ind + heading-tab, row-gap)
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Statutes"),
  ("rule", "Rules"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  table-title[TABLE OF AUTHORITIES][Page(s)]
  context {
    set text(..edges(pitch-single))
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("hib-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(width: 100%, sticky: true, above: pitch-single, below: 0pt, line-block(strong(title)))
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        listing-row(none, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
        }, page-text, toa-col, toa-hang, row-gap)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover: counsel, court title, caption, title of the paper, hearing (HIB-FORM-001, -005, -006)
// ---------------------------------------------------------------------------

/// Counsel block, upper left, single-spaced (identification of counsel is exempt from double spacing).
#let counsel-block(meta) = {
  for l in need(meta, "counsel") { line-block(l) }
  if "counsel_role" in meta { line-block(emph(inl(meta.counsel_role))) }
}

/// One party: its names, then its designation.
#let caption-side(side) = {
  for n in side.names { line-block(n) }
  line-block(indent: designation-indent, side.designation)
}

/// Caption (FRBP 9004(b)(1)-(4)). Row 1: the bankruptcy case lines (if any), the first party, and on
/// the right the adversary number and the title of the paper. Row 2: the remaining parties ("v."), with the rule
/// closing the party column, and on the right the noticed hearing. Each row is unbreakable, so a row moves whole to
/// the next page and no cell is torn. (The filed exemplar's caption also runs onto a second page; see README.md.)
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let bankruptcy = meta.at("bankruptcy", default: ())
  let row(left, right, last) = block(width: 100%, breakable: false, above: 0pt, below: 0pt, grid(
    columns: (1fr, 1fr),
    block(width: 100%, stroke: if last { (right: 0.75pt, bottom: 0.75pt) } else { (right: 0.75pt) },
      inset: (right: caption-inset, bottom: caption-pad), left),
    pad(left: caption-inset, right),
  ))
  let left1 = {
    for l in bankruptcy { line-block(l) }
    if bankruptcy.len() > 0 { line-block("") }
    caption-side(sides.at(0))
  }
  let right1 = {
    line-block(need(meta, "adversary_number"))
    line-block("")
    line-block(strong(upper(inl(need(meta, "brief_title")))))
  }
  // Noticed hearing date, time and judge, opposite the remaining parties (LBR 9013-1(c)(1)).
  let hearing = {
    let h = meta.at("hearing", default: (:))
    for (k, lab) in (("date", "Date:"), ("time", "Time:"), ("place", "Place:"), ("judge", "Judge:")) {
      if k in h { line-block(lab + " " + h.at(k)) }
    }
  }
  row(left1, right1, sides.len() == 1)
  for (i, side) in sides.slice(1).enumerate() {
    row({
      line-block(align(center)[v.])
      line-block("")
      caption-side(side)
    }, if i == 0 { hearing }, i == sides.len() - 2)
  }
}

#let cover(meta) = {
  counsel-block(meta)
  for (i, l) in need(meta, "court").enumerate() {
    line-block(above: if i == 0 { pitch-single } else { 0pt }, align(center, strong(upper(inl(l)))))
  }
  block(width: 100%, above: pitch-single, below: 0pt, caption-table(meta))
}

// ---------------------------------------------------------------------------
// Signature block (HIB-FORM-007: convention; no local rule text on signatures)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let blocks = need(meta, "signature")
  block(width: 100%, breakable: false, above: pitch-single, below: 0pt, grid(
    columns: (1fr, sig-column),
    line-block("DATED: " + need(meta, "date")),
    {
      for (i, b) in blocks.enumerate() {
        if i > 0 { line-block("") }
        for l in b { line-block(l) }
      }
    },
  ))
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

/// The page number, centered in a single line; the first page of the cover carries none (DEF-COVER-001: a long
/// caption runs onto page 2, which prints its number "2", as the filed example does).
#let running-footer = context {
  let n = counter(page).get()
  if here().page() > 1 { align(center, text(..edges(pitch-single), numbering(here().page-numbering(), ..n))) }
}

#let hib-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "counsel", "adversary_number", "brief_title", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  // LBR 9004-1(a)(2): 8 1/2 x 11 inch
  set page(paper: "us-letter", margin: margin, numbering: "1", footer-descent: 30%, footer: running-footer)
  set document(title: need(meta, "brief_title"))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch.
  show: xengine.with(pitch: pitch-double)
  // A doubled sign stays with its number ("§§ 548"; the docx filter binds it with a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  // Footnotes at the text size (HIB-FORM-002), single lines, under a 30 % rule, 7 pt between notes; the mark and a
  // space before the text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Block quotations: single-spaced, half an inch in on both sides, a single line off the text (HIB-FORM-003).
  show quote.where(block: true): it => block(width: 100%, above: pitch-single, below: pitch-single, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: para-indent, it.body)
  })

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      [#metadata(key)<toa-hit>#it.body]
    } else {
      it
    }
  }

  // Headings at the body size and pitch, bold, no space of their own; sticky, so a heading never ends a page.
  // Level 1 a centered title in capitals; deeper levels their label in a half-inch box at the level's indent, the
  // title's lines hanging after it.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 {
      block(width: 100%, above: 0pt, below: 0pt, sticky: true, align(center, strong(upper(it.body))))
    } else {
      let lab = numbering(it.numbering, ..counter(heading).at(it.location()).slice(0, it.level))
      let ind = label-indent(it.level)
      block(width: 100%, above: 0pt, below: 0pt, sticky: true,
        par(hanging-indent: ind + heading-tab, { h(ind); box(width: heading-tab, lab); strong(it.body) }))
    }
  }

  // The cover: the first page has no number; a caption that runs on is numbered from 2.
  cover(meta)
  // The tables in lower roman from i, each on a page of its own.
  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)
  // The memorandum in arabic from 1; its last paragraph stays whole with the signature block. Footnote definitions
  // are read with both parts, so a mark in either finds its note.
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = chunks.filter(c => c.trim().starts-with("[^"))
  let text-chunks = chunks.filter(c => not c.trim().starts-with("[^"))
  let render(cs) = cmarker.render((cs + defs).join("\n\n"), raw-typst: false, smart-punctuation: true, h1-level: 1)
  render(text-chunks.slice(0, -1))
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, [#render(text-chunks.slice(-1))#parbreak()])
  signature-block(meta)
}
