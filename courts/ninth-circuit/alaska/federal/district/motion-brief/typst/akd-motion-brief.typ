// Memorandum in support of a motion to dismiss for the United States District Court for the District of
// Alaska (akd). Rules: D. Alaska Local Civil Rule 7.5(a) (double-spaced; margins of at least 1 inch,
// footers included; a page number and a footer with the case name and number on every page of a
// multi-page document; at least 13-point proportionally spaced font), 7.5(b) (first-page layout), 7.5(c)
// (signature block), 7.1(a) (a motion states the relief and the points and authorities), 7.4(a)(1) (a
// Rule 12(b) memorandum is limited to 35 pages or 10,000 words, the caption, signature and tables
// excluded: 7.4(a)(4); the template does not count pages or words), 8.1 (pleadings; not applicable to a
// memorandum but its statute-under-the-title line is kept for the motion's citation). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // L.R. 7.5(a)(1)(D): proportionally spaced; vendored in fonts/
#let type-size = 13pt                   // L.R. 7.5(a)(1)(D): at least 13-point
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let margin = 1in                       // L.R. 7.5(a)(1)(B): at least 1 inch on all sides
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 8pt               // between the caption's rule and the case number
#let caption-inset = 8pt                // the party text stands off the rule (right and below)
#let court-drop = 0.8in                 // L.R. 7.5(b)(2): the court title at least half an inch below the counsel block
#let sig-indent = 2.5in                 // the signature block, right of centre
#let heading-tab = 0.5in                // the label of a numbered heading hangs in this space; each deeper level steps in by it
#let passim-threshold = 7               // an authority cited on this many pages or more prints "passim"
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 72pt                // authorities: the page lists keep the last inch
#let toa-hang = 0.35in                  // authorities: the wrapped lines of an entry

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 30pt                // L.R. 7.5(a)(1)(A): double-spaced, twice the single pitch
#let pitch-single = 15pt                // headings, counsel block, caption, quotations, footnotes, tables, signature, footer
#let half-gap = 15pt                    // below a heading, around quotations, between caption parties, above table groups
#let small-gap = 6pt                    // between a party's names and its designation, between table rows
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt             // from the text to the footnote rule (the space LibreOffice keeps above it)
#let footer-gap = 6pt                   // between the text area and the footer (three 15 pt lines, in the bottom margin)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("akd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field; a missing one fails the build with its name.
#let need(meta, k) = {
  if k not in meta { panic("akd-motion-brief: the sample frontmatter needs `" + k + "`") }
  meta.at(k)
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Heading labels. Level 1 (the section headings INTRODUCTION, BACKGROUND, ...) is unnumbered; level 2
/// is I., II.; level 3 is A., B.; level 4 is 1., 2.; level 5 is a., b.
#let heading-num(..nums) = {
  let v = nums.pos()
  let n = v.last()
  if v.len() == 2 { numbering("I.", n) } else if v.len() == 3 { numbering("A.", n) } else if v.len() == 4 {
    numbering("1.", n)
  } else if v.len() == 5 { numbering("a.", n) } else { "" }
}

#let label-indent(level) = calc.max(level - 2, 0) * heading-tab

/// The printed page label of a location.
#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Footer on every page: page number, the short title of the paper, then the case name and number
/// (L.R. 7.5(a)(1)(C)), single lines, in the bottom margin.
#let running-footer(meta) = context {
  line-block(align(center, counter(page).display()))
  line-block(align(center, inl(need(meta, "footer_title"))))
  line-block(align(center)[#inl(need(meta, "case_name")), Case No. #need(meta, "case_number")])
}

// ---------------------------------------------------------------------------
// Cover: counsel block, court title, caption, title (L.R. 7.5(b))
// ---------------------------------------------------------------------------

#let cover(meta) = {
  // Counsel block, upper left, single-spaced (L.R. 7.5(b)(1)(A)-(C)).
  for l in need(meta, "counsel") { line-block(inl(l)) }
  // Court title, centered, one line per entry (L.R. 7.5(b)(2)).
  for (i, l) in need(meta, "court").enumerate() {
    line-block(above: if i == 0 { court-drop } else { 0pt }, align(center, strong(upper(l))))
  }
  // Caption: parties on the left, closed by a rule on the right and bottom; the case number and the judge's name
  // on the right (L.R. 7.5(b)(3)(B)).
  let sides = need(meta, "caption")
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-inset), {
      for (i, s) in sides.enumerate() {
        for (j, n) in s.names.enumerate() { line-block(above: if i > 0 and j == 0 { half-gap } else { 0pt }, inl(n)) }
        line-block(above: small-gap, align(right, inl(s.designation)))
      }
    }),
    {
      line-block[No. #need(meta, "case_number")]
      if "judge" in meta { line-block(inl(meta.judge)) }
    },
  ))
  // Document title, centered and bold, with the statute under it (L.R. 8.1(a)) and an optional oral-argument
  // legend (L.R. 7.1(f)).
  line-block(above: pitch-double, align(center, strong(upper(inl(need(meta, "title"))))))
  if "statute" in meta { line-block(align(center)[(#inl(meta.statute))]) }
  if meta.at("oral_argument", default: false) { line-block(align(center, strong[Oral Argument Requested])) }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

/// A table's title (centered, bold capitals) and the label of its page column at the right.
#let table-head(title, col) = {
  line-block(align(center, strong(upper(title))))
  line-block(above: half-gap, align(right, strong(col)))
}

/// One contents row: the label in its box at the heading's indent, the title hanging after it.
#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = heading-num(..nums)
  let ind = label-indent(hd.level)
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  listing-row(hd.location(), { h(ind); if lab != "" { box(width: heading-tab, lab) }; title },
    page-label(hd.location()), toc-page-col, ind + heading-tab, small-gap)
}

#let toc-section() = {
  table-head("Table of Contents", "Page")
  context {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    for hd in query(heading.where(outlined: true)) {
      if hd.level <= 4 { toc-entry(hd) }
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Statutes"),
  ("rule", "Rules"),
  ("regulation", "Regulations"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("sort", default: a.at("name", default: a.at("cite", default: ""))))

/// Table of authorities, built from the `toa:` links found in the body (L.R. 7.4 is silent on it; the
/// convention is kept from the exemplar).
#let toa-section(authorities) = {
  table-head("Table of Authorities", "Page(s)")
  context {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("akd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(sticky: true, width: 100%, above: half-gap, below: 0pt, strong(title))
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let name = if "name" in a { if kind == "case" { emph(inl(a.name)) } else { inl(a.name) } }
        listing-row(none, { if name != none [#name, ]; inl(a.cite) }, page-text, toa-page-col, toa-hang, small-gap)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

/// Signature block (L.R. 7.5(c)(1)-(2)): the date line, the preamble lines, the signature line and the
/// signer's name and the lines under it, single-spaced, set in the right half of the page; never split.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, {
    if "date" in meta { line-block(pad(left: para-indent, inl(meta.date))) }
    for (j, l) in sig.at("preamble", default: ()).enumerate() {
      line-block(above: if j == 0 { half-gap } else { 0pt }, pad(left: sig-indent, inl(l)))
    }
    line-block(above: half-gap, pad(left: sig-indent)[/s/ #sig.signer])
    for l in sig.at("lines", default: ()) { line-block(pad(left: sig-indent, inl(l))) }
  })
}

/// Certificate of service, when the sample has one (the exemplar does not; see README.md): its own page.
#let certificate(meta) = if "certificate" in meta {
  let c = meta.certificate
  pagebreak(weak: true)
  line-block(align(center, strong[CERTIFICATE OF SERVICE]))
  block(width: 100%, above: half-gap, below: 0pt, par(inl(c.text)))
  block(width: 100%, above: pitch-double * 2, below: 0pt, breakable: false, pad(left: sig-indent,
    block(width: 100%, above: 0pt, below: 0pt, stroke: (top: 0.5pt), line-block(inl(c.signer)))))
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let akd-motion-brief(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "case_number", "case_name", "footer_title", "caption", "counsel", "title", "signature") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  // L.R. 7.5(a)(2)(A): letter size; 1-inch margins (L.R. 7.5(a)(1)(B)), the footer on every page (L.R.
  // 7.5(a)(1)(C)) in the bottom margin, its top footer-gap below the text area (Word: the footer 21 pt above the page
  // foot). The cover and the tables are numbered in lower-case roman; the memorandum starts again at 1.
  set page(paper: "us-letter", margin: margin, numbering: "i", footer-descent: footer-gap,
    footer: running-footer(meta))
  set document(
    title: need(meta, "title") + ", Case No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // A doubled sign stays with its number ("§§ 1331"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set heading(numbering: heading-num)
  // Footnotes at the text size, single lines, under a 30 % rule, 7 pt between notes; the mark and a space before the
  // text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  // L.R. 7.5(a)(1)(A): quotations single-spaced and indented, half an inch on both sides.
  show quote.where(block: true): it => block(width: 100%, above: half-gap, below: half-gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: para-indent, it.body)
  })
  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on (the mark before it).
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#metadata(it.dest.slice(4))<toa-hit>#it.body]
    } else {
      it
    }
  }
  // Headings single-spaced and bold, a double line above and half of one below: level 1 centered in capitals,
  // deeper levels with their label in a box at the level's indent and the title hanging after it. Sticky: a heading
  // never ends a page.
  show heading: it => context {
    set text(size: type-size, ..edges(pitch-single))
    let b = if it.level == 1 {
      align(center, par(first-line-indent: 0pt, strong(upper(it.body))))
    } else {
      let nums = counter(heading).at(it.location()).slice(0, it.level)
      let ind = label-indent(it.level)
      par(first-line-indent: 0pt, hanging-indent: ind + heading-tab,
        strong({ h(ind); box(width: heading-tab, heading-num(..nums)); it.body }))
    }
    block(sticky: true, width: 100%, above: pitch-double, below: half-gap, b)
  }

  // Cover (page i), contents and authorities (from ii), each on its own page.
  cover(meta)
  pagebreak()
  toc-section()
  pagebreak()
  toa-section(authorities)

  set page(numbering: "1")   // a new page, numbered from 1
  counter(page).update(1)
  // The last paragraph is kept with the signature block (and its heading with it), so the signature never stands
  // on a page alone; it is rendered on its own when it is a plain paragraph without a footnote.
  let chunks = body.trim().split(regex("\\r?\\n[ \\t]*\\r?\\n"))
  let last = chunks.last().trim()
  if chunks.len() > 1 and not last.starts-with(regex("[#>|\\[\\-*+]|\\d+\\.")) and not last.contains("[^") {
    cmarker.render(chunks.slice(0, -1).join("\n\n"), raw-typst: false, smart-punctuation: true, h1-level: 1)
    block(sticky: true, breakable: false, width: 100%, above: 0pt, below: 0pt, par(inl(last)))
  } else {
    cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
  signature-block(meta)
  certificate(meta)
}
