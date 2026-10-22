// U.S. District Court, Northern District of Oklahoma: motion with brief in support (one filed document).
//
// Rule-driven and content-agnostic. Requirement IDs (OKND-...) refer to ../../rules.md and ../README.md, which
// quote the rule text: LGnR2-4(a) (format of papers; Local Rules, 2026-07-31), LCvR7-1(b) (motion and brief as one
// document), LCvR7-1(d) (25-page limit; indexed TOC and TOA above 15 pages), Fed. R. Civ. P. 12(b). No case-specific
// text, no coordinates measured off the exemplar, no forced line breaks. Every case-specific word comes from the
// sample's frontmatter and body (schema: ../README.md).
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // OKND-FONT-002: LGnR2-4(a) names no face; Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // OKND-FONT-003: print style, footnotes included, not smaller than 12 point
#let note-size = 12pt                   // footnotes: the same 12 pt floor (LGnR2-4(a): "including footnotes")
#let footer-size = 12pt                 // the page number, at the 12 pt floor
#let page-w = 8.5in                     // OKND-FORM-002: 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // OKND-FONT-003: margins at least one inch
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of every body paragraph (after a heading too, as filed)
#let heading-tab = 0.5in                // a heading's label in a box this wide; each deeper level starts this far further in
#let quote-inset = 0.5in                // block quotations: indented on both sides
#let caption-rule = 0.75pt              // the rule down the right and across the foot of the party column
#let caption-pad = 14.4pt               // the party column's text stands this far from its right rule
#let caption-foot = 12pt                // ... and its last line this far above its foot rule
#let caption-right-pad = 14.4pt         // the case number stands this far right of the rule
#let designation-indent = 1.8in         // a side's designation ("Plaintiff,") is set in this far
#let sig-col = 3.2in                    // the signature column at the right; "Dated:" at the left margin
#let service-indent = 0.5in             // the certificate's service list
#let passim-threshold = 7               // an authority cited on this many pages or more: "passim"
#let toc-col = 36pt                     // tables: the page column the text wraps before (docs/EVAL-LOOP.md, design differences)
#let toa-col = 56pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (docx/oknd-motion-brief.lua and docx/reference.xml set the same twips: 20 x pt).
// OKND-FORM-002 / OKND-FONT-001: "double-spaced", and "The use of 'Exactly 24 pt' spacing is not permitted"
// (LGnR2-4(a)): the body pitch is the face's own double spacing, twice Times New Roman's single line (1.15 em),
// as a word processor's "Double" sets it, not a fixed 24 pt.
#let pitch-body = 27.6pt                // double spacing: 2 x 13.8 pt
#let pitch-single = 13.8pt              // single spacing of the face: court name, caption, title, headings, quotations, signature
#let pitch-note = 13.8pt                // footnote lines: single spacing at 12 pt
#let note-gap = 6pt                     // between two footnotes
#let note-clearance = 13.8pt            // the body text to the footnote rule (Word's separator line)
#let court-gap = 27.6pt                 // court name to caption (a blank double line)
#let versus-gap = 13.8pt                // above and below "v." in the caption
#let title-above = 27.6pt               // caption to title
#let title-below = 13.8pt               // title to the body
#let heading-gap = 13.8pt               // above and below a heading (a blank single line)
#let quote-gap = 13.8pt                 // above and below a block quotation
#let sig-above = 27.6pt                 // the last paragraph to the signature block
#let signer-above = 27.6pt              // "Respectfully submitted," to "/s/"
#let toc-row-gap = 6pt                  // between two rows of a table
#let toa-group-gap = 13.8pt             // above a group heading of the table of authorities

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let need(meta, key) = {
  if key not in meta { panic("oknd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("oknd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Markdown to inline content.
#let md(s) = unloose(render(s))

/// One single-pitch paragraph, with explicit spaces above and below it.
#let sline(above: 0pt, below: 0pt, left: 0pt, right: 0pt, centered: false, c) = block(width: 100%, above: above,
  below: below, {
    set text(..edges(pitch-single))
    set align(center) if centered
    pad(left: left, right: right, par(first-line-indent: 0pt, if type(c) == str { md(c) } else { c }))
  })

// ---------------------------------------------------------------------------
// Headings: level 1 is unnumbered (SUMMARY OF ARGUMENT, ARGUMENT AND AUTHORITY); levels 2-5 are numbered by the
// template: I., A., 1., a.
// ---------------------------------------------------------------------------

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
// Tables of contents and authorities (LCvR7-1(d); built only when `toc_toa: true` in the frontmatter)
// ---------------------------------------------------------------------------

#let table-heading(s, right-label) = {
  block(width: 100%, above: 0pt, below: heading-gap, sticky: true, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    align(center, strong(upper(s)))
  })
  block(width: 100%, above: 0pt, below: toc-row-gap, { set text(..edges(pitch-single)); align(right, strong(right-label)) })
}

#let toc-section() = {
  table-heading("Table of Contents", "Page")
  context {
    set text(..edges(pitch-single))
    for hd in query(heading.where(outlined: true)) {
      if hd.level > 4 { continue }
      let nums = counter(heading).at(hd.location()).slice(0, hd.level)
      let lab = if hd.level == 1 { "" } else { heading-num(..nums) }
      let ind = if hd.level == 1 { 0pt } else { label-indent(hd.level) }
      let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
      listing-row(hd.location(),
        [#h(ind)#if lab != "" { box(width: heading-tab, lab) }#if hd.level == 1 { upper(hd.body) } else { hd.body }],
        pg, toc-col, ind + if lab != "" { heading-tab } else { 0pt }, toc-row-gap)
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

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  table-heading("Table of Authorities", "Page(s)")
  context {
    set text(..edges(pitch-single))
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("oknd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      sline(above: toa-group-gap, strong(title))
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        listing-row(none, {
          if "name" in a {
            if kind == "case" { emph(md(a.name)) } else { md(a.name) }
            [, ]
          }
          md(a.cite)
        }, page-text, toa-col, 0.35in, toc-row-gap)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover: court name, caption, title of the paper (FRCP 10(a) form, as the court files it)
// ---------------------------------------------------------------------------

/// Parties on the left (each side: its names, then its designation; "v." between sides), the file number on the
/// right, centred on the party column's height; the party column ruled at its right and foot.
#let caption(meta) = {
  let sides = need(meta, "caption")
  let left = for (i, side) in sides.enumerate() {
    for n in side.names { sline(n) }
    sline(left: designation-indent, side.designation)
    if i < sides.len() - 1 { sline(above: versus-gap, below: versus-gap, centered: true, "v.") }
  }
  block(width: 100%, above: court-gap, below: 0pt, breakable: false, grid(
    columns: (1fr, 1fr),
    stroke: (x, y) => if x == 0 { (right: caption-rule, bottom: caption-rule) },
    inset: (x, y) => if x == 0 { (right: caption-pad, bottom: caption-foot) } else { (left: caption-right-pad, bottom: caption-foot) },
    align: (x, y) => if x == 1 { horizon } else { top },
    left,
    sline([Case No. #need(meta, "case_number")]),
  ))
}

#let cover(meta) = {
  // The court's own name, on two centred lines.
  sline(centered: true, strong[IN THE UNITED STATES DISTRICT COURT FOR THE])
  sline(centered: true, strong[NORTHERN DISTRICT OF OKLAHOMA])
  caption(meta)
  // OKND-CONT-005 / LCvR7-1(b): the title says what the paper is (and that motion and brief are one document).
  sline(above: title-above, below: title-below, centered: true, strong(md(need(meta, "title"))))
}

// ---------------------------------------------------------------------------
// Body: paragraphs, headings, block quotations, footnotes
// ---------------------------------------------------------------------------

/// A body paragraph on the body pitch, its first line indented. One that anchors a footnote (`note`) may leave a
/// single line on a page (no widow or orphan rule), so that the line with the mark moves on with its note rather than
/// the note alone (docx: Body Text Note, Word's widow control off).
#let body-par(sticky: false, note: false, c) = {
  let p = {
    set text(costs: (widow: 0%, orphan: 0%)) if note
    par(first-line-indent: (amount: para-indent, all: true), unloose(c))
  }
  if sticky { block(width: 100%, above: 0pt, below: 0pt, sticky: true, p) } else { p }
}

/// Brief body: each blank-line-separated chunk is one paragraph (not numbered: a brief is argument, not
/// allegations). Headings are rendered by the show rule below; a "> " chunk is a block quotation, each of its
/// paragraphs a single-spaced paragraph. Footnote definitions are kept apart from the chunks: each chunk is rendered
/// alone, so a chunk gets the definitions of the notes it refers to, and a definition is not printed as a paragraph.
#let brief-body(body) = {
  let notes = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) {
    notes.insert(m.captures.at(0), m.captures.at(1))
  }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
    .filter(c => not c.starts-with(regex("^\\[\\^[^\\]]+\\]:")))
  for (i, t) in chunks.enumerate() {
    let defs = ""
    for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
      let id = r.captures.at(0)
      defs += "\n\n[^" + id + "]: " + notes.at(id, default: "")
    }
    // The last paragraph is kept on the page with the signature block that follows it.
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      render(t + defs)
    } else if t.starts-with(">") {
      // Block quotation: single-spaced, 0.5 in in on both sides, a blank single line above and below.
      let q = t.replace(regex("(?m)^>[ \\t]?"), "")
      let ps = q.split(regex("\\n[ \\t]*\\n")).map(s => s.trim()).filter(s => s != "")
      for (k, s) in ps.enumerate() {
        sline(above: if k == 0 { quote-gap } else { 0pt }, below: if k == ps.len() - 1 { quote-gap } else { 0pt },
          left: quote-inset, right: quote-inset, md(s + defs))
      }
    } else {
      body-par(sticky: last, note: defs != "", render(t + defs))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (FRCP 11(a); LGnR2-6; OKND-CERT-003) and certificate of service
// ---------------------------------------------------------------------------

/// Single-spaced, kept on one page: "Dated:" (when given) at the left margin, beside it at `sig-col` from the right
/// "Respectfully submitted,", then "/s/" and the signer's lines.
#let sig-rows(above: 0pt, rows) = block(width: 100%, above: above, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  let col = page-w - 2 * margin - sig-col
  for (lead, c, gap) in rows {
    block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: col,
      [#box(width: col, lead)#if type(c) == str { md(c) } else { c }]))
  }
})

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let rows = ((if "date" in meta [Dated: #meta.date], [Respectfully submitted,], 0pt),
    (none, "/s/ " + sig.signer, signer-above))
  for l in sig.at("lines", default: ()) { rows.push((none, l, 0pt)) }
  sig-rows(above: sig-above, rows)
}

/// Certificate of service (Fed. R. Civ. P. 5(d)(1)(B): required only when a paper is not served through the
/// court's electronic-filing system). Starts on its own page.
#let certificate-block(meta) = {
  let c = meta.certificate
  pagebreak()
  block(width: 100%, above: 0pt, below: heading-gap, sticky: true, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    align(center, strong(upper[Certificate of Service]))
  })
  body-par(md(need(c, "text")))
  block(width: 100%, above: heading-gap, below: 0pt, breakable: false,
    for l in c.at("service", default: ()) { sline(left: service-indent, l) })
  sig-rows(above: signer-above, ((none, "/s/ " + need(c, "signer"), 0pt), (none, c.signer, 0pt)))
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let oknd-motion-brief(meta, body) = {
  for k in ("case_number", "caption", "title", "signature") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))
  let toc-toa = meta.at("toc_toa", default: false)

  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // One continuous Arabic sequence from the caption page (as in the exemplar), centred at the foot of every page
    // in a single-pitch line box that ends footer-distance above the page edge.
    numbering: "1",
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display("1"))),
  )
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // A web address breaks only after a slash before a letter (where the docx filter lets Word break it), each piece
  // between those breaks kept whole: typst would otherwise break inside it where Word does not.
  show regex("https?://\\S+"): it => {
    let s = it.text
    let (pieces, start) = ((), 0)
    for m in s.matches(regex("/[^/\\d\\s]")) {
      pieces.push(s.slice(start, m.start + 1))
      start = m.start + 1
    }
    pieces.push(s.slice(start))
    pieces.map(p => box(p)).join()
  }

  // Footnotes at 12 pt (LGnR2-4(a)) in single lines, the mark, a space, the text (docx: Footnote Text).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt) // the entry does not inherit the body's leading 0
    [#super(num) #note.body]
  }

  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  // Headings at the type size on the single pitch, a blank single line above and below, kept with the text: level
  // 1 centred bold capitals, unnumbered; deeper levels bold, the label in a box at the level's indent, the lines
  // after the first hanging after the label.
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    block(width: 100%, above: heading-gap, below: heading-gap, sticky: true, {
      set text(size: type-size, weight: "bold", ..edges(pitch-single))
      if it.level == 1 {
        set par(first-line-indent: 0pt)
        align(center, upper(it.body))
      } else {
        let ind = label-indent(it.level)
        par(first-line-indent: 0pt, hanging-indent: ind + heading-tab,
          [#h(ind)#box(width: heading-tab, heading-num(..nums))#it.body])
      }
    })
  }

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#it.body#metadata(it.dest.slice(4))<toa-hit>]
    } else {
      it
    }
  }

  cover(meta)
  if toc-toa {
    pagebreak()
    toc-section()
    pagebreak()
    toa-section(authorities)
    pagebreak()
  }
  brief-body(body)
  signature-block(meta)
  if "certificate" in meta { certificate-block(meta) }
}
