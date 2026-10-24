// U.S. District Court, Northern District of California: motion (notice of motion and memorandum
// of points and authorities).
//
// Rule-driven and content-agnostic. Requirement IDs (CAND-...) refer to ../README.md, which quotes
// the rule text (Civil L.R. 3-4, 7-2, 7-4; effective Oct. 2, 2026). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by
// cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // CAND-FORM-002: standard, proportionally spaced font; the rule's example is Times New Roman (vendored, docs/FONTS.md).
#let type-size = 12pt                    // CAND-FORM-002: 12 point or larger, footnotes and quotations too.
#let margins = (top: 60pt, bottom: 60pt, left: 1.5in, right: 1in)   // pleading paper (Civil L.R. 3-4(c)(1)-(2)): 28 numbered lines of 24 pt; 792 - 28*24 = 120 pt split top/bottom
#let para-indent = 0.5in
#let heading-tab = 0.5in                 // the label of a numbered heading hangs in this space; each deeper level steps in by it
#let footer-size = 10pt                  // footer: page number, paper title and case number (CAND-FORM-003); not body text
#let footer-foot = 8pt                   // the footer's last line ends this far above the page's foot
#let passim-threshold = 7                // authority cited on this many pages or more: "passim"
#let caption-pad = 14.4pt                // the caption's text stands this far off its rule (left column) and the rule (right column)
#let caption-below = 12pt                // the caption's bottom rule stands this far below the last party line
#let caption-top = 3.6pt                 // the right column starts this far down
#let designation-indent = 1.8in          // a party's designation, set in from its names
#let signature-width = 3.2in             // the signing column at the right (the date at the margin)
#let toc-page-col = 36pt                 // contents: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 72pt                 // authorities: the page lists keep the last inch
#let toa-hang = 0.35in                   // authorities: the wrapped lines of an entry

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                 // CAND-FORM-001: double spacing; 27 lines fit the page (limit 28)
#let pitch-single = 12pt   // counsel, caption, headings, footnotes, tables, signature: single spaced, two lines to a numbered line (as cand-complaint)
#let pitch-footer = 11.5pt               // the footer's lines, 1.15 x its size; four fit the 52 pt under the last numbered line (page, a two-line title, case number)
#let half-gap = 12pt                     // around a heading and the caption's items; above a table's groups and its column label
#let row-gap = 6pt                       // between the rows of the contents and the authorities
#let note-gap = 7pt                      // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 12.6pt             // from the last body line to the footnote separator (Word's footnote area)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("cand-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cand-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// The printed page label of a location.
#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

// ---------------------------------------------------------------------------
// Headings: numbering and styles (CAND-CONT-001)
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
#let label-indent(level) = calc.max(level - 2, 0) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities (Civil L.R. 7-4(a)(2))
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
    page-label(hd.location()), toc-page-col, ind + heading-tab, row-gap)
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
  ("statute", "Federal Statutes"),
  ("rule", "Federal Rules"),
  ("regulation", "Federal Regulations"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links found in the body (CAND-CONT-003).
#let toa-section(authorities) = {
  table-head("Table of Authorities", "Page(s)")
  context {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("cand-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
        listing-row(none, { if name != none [#name, ]; inl(a.cite) }, page-text, toa-page-col, toa-hang, row-gap)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (Civil L.R. 3-4(a), 7-2(b)(1), 7-4(a)(1))
// ---------------------------------------------------------------------------

/// Counsel block, upper left (3-4(a)(1)), one single-spaced line each, the role in italics.
#let counsel-block(meta) = {
  for l in need(meta, "counsel") { line-block(inl(l)) }
  line-block(emph(inl(need(meta, "counsel_role"))))
}

/// The caption: the parties at the left, ruled at the right and below; the case number, the title of the paper and
/// the noticed hearing at the right (7-2(b)(1), 7-4(a)(1)).
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let hearing = need(meta, "hearing")
  let left = {
    for (i, side) in sides.enumerate() {
      if i > 0 { line-block(above: half-gap, align(center)[v.]) }
      for (j, n) in side.names.enumerate() { line-block(above: if i > 0 and j == 0 { half-gap } else { 0pt }, inl(n)) }
      line-block(pad(left: designation-indent, inl(side.designation)))
    }
  }
  let right = {
    line-block[Case No. #need(meta, "case_number")]
    line-block(above: half-gap, strong(upper(inl(need(meta, "brief_title")))))
    for (j, (k, lab)) in (("date", "Date: "), ("time", "Time: "), ("place", "Place: "), ("judge", "")).enumerate() {
      if k in hearing { line-block(above: if j == 0 { half-gap } else { 0pt }, [#lab#inl(hearing.at(k))]) }
    }
  }
  block(above: pitch-double, below: 0pt, table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(right: caption-pad, bottom: caption-below, left),
    pad(left: caption-pad, top: caption-top, right),
  ))
}

#let cover(meta) = {
  counsel-block(meta)
  for (i, l) in need(meta, "court").enumerate() {
    line-block(above: if i == 0 { pitch-double } else { 0pt }, align(center, strong(upper(l))))
  }
  caption-table(meta)
}

// ---------------------------------------------------------------------------
// Signature block (convention: no local rule cited for the form; see ../README.md): the date at the margin;
// "Respectfully submitted,", the preamble, the signature, the signer and the signer's lines at the right. It never
// breaks across a page.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (1fr, signature-width),
    line-block[Dated: #need(meta, "date")],
    {
      line-block[Respectfully submitted,]
      for (i, l) in sig.at("preamble", default: ()).enumerate() {
        line-block(above: if i == 0 { pitch-double } else { 0pt }, inl(l))
      }
      line-block(above: pitch-double)[#emph[/s/ #sig.signer]]
      line-block(inl(sig.signer))
      for l in sig.at("lines", default: ()) { line-block(inl(l)) }
    },
  ))
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

/// The footer (CAND-FORM-003): the page number, the paper's title in capitals and the case number, centered, its
/// last line footer-foot above the page's foot (Word's footer grows upward from there).
#let running-footer(meta) = block(width: 100%, height: margins.bottom - footer-foot, align(bottom, {
  set text(size: footer-size, ..edges(pitch-footer))
  set par(first-line-indent: 0pt)
  let line(body) = block(width: 100%, above: 0pt, below: 0pt, align(center, body))
  line(context counter(page).display())
  line(upper(need(meta, "footer_title")))
  line[No. #need(meta, "case_number")]
}))

// Pleading-paper furniture (line numbers 1-28 and the rules), as courts/.../northern-district/complaint/typst/cand-complaint.typ.
#let lines-per-page = 28
#let number-col = 1in
#let line-numbers() = {
  set text(font: font-family, size: type-size, ..edges(pitch-double))
  place(top + left, dy: margins.top, block(width: number-col, {
    set par(leading: 0pt, spacing: 0pt)
    for i in range(1, lines-per-page + 1) { block(width: 100%, above: 0pt, below: 0pt, align(right, str(i))) }
  }))
}
#let pleading-rules() = {
  place(top + left, dx: margins.left - 0.2in, line(start: (0pt, 0pt), end: (0pt, 11in), stroke: 0.75pt))
  place(top + left, dx: margins.left - 0.16in, line(start: (0pt, 0pt), end: (0pt, 11in), stroke: 0.75pt))
  place(top + left, dx: 8.5in - margins.right + 0.1in, line(start: (0pt, 0pt), end: (0pt, 11in), stroke: 0.75pt))
}

#let cand-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "counsel", "counsel_role", "brief_title", "footer_title", "hearing", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, numbering: none, footer: none, background: { line-numbers(); pleading-rules() })   // Civil L.R. 3-4(c)(1): 8 1/2 x 11 inch
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-double)
  // A doubled sign stays with its number ("§§ 1391"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // A web address breaks only after "?", "=", "&", a hyphen or a slash that no digit (nor a second slash) follows:
  // each part is a box, so the PDF text keeps the author's characters. Without this typst breaks an address at any
  // character, which Word does not.
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
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  // Footnotes at the type size, single-spaced, the mark and a space before the note (Word's Footnote Text).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)   // an entry does not inherit the body's leading
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on (the mark before it).
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#metadata(it.dest.slice(4))<toa-hit>#it.body]
    } else {
      it
    }
  }

  // Headings single-spaced, half a double line above and below; kept with the text after them. Level 1 centered in
  // bold capitals; deeper levels with their label in a box at the level's indent and the bold title hanging after it.
  show heading: it => context {
    set text(size: type-size, ..edges(pitch-single))
    let b = if it.level == 1 {
      align(center, par(first-line-indent: 0pt, strong(upper(it.body))))
    } else {
      let nums = counter(heading).at(it.location()).slice(0, it.level)
      let ind = label-indent(it.level)
      par(first-line-indent: 0pt, hanging-indent: ind + heading-tab,
        { h(ind); box(width: heading-tab, heading-num(..nums)); strong(it.body) })
    }
    block(sticky: true, width: 100%, above: half-gap, below: half-gap, b)
  }

  // The cover has no page number.
  cover(meta)

  // The tables are numbered in lower-case roman; the motion starts again at 1.
  set page(numbering: "i", footer-descent: 0pt, footer: running-footer(meta))
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)

  set page(numbering: "1")   // a new page, numbered from 1
  counter(page).update(1)
  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
}
