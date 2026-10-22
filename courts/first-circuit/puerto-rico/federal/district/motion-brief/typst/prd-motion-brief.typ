// U.S. District Court, District of Puerto Rico: motion to dismiss with the memorandum of law in support
// (Fed. R. Civ. P. 7(b), 10(a), 12(b); the form rules of D.P.R. Local Civil Rule 7 as quoted in ../README.md).
// Rule-driven and content-agnostic: every case-specific word comes from the sample's frontmatter, never from
// this file. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same sample file. Requirement IDs (PRD-...) in ../README.md say what each parameter traces to.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // PRD-FORM-002: proportional font; Times New Roman substitute per docs/FONTS.md, vendored in /fonts (see ../README.md)
#let type-size = 12pt                   // PRD-FORM-002: 12 point or larger for a proportional font (L.Civ.R. 7), footnotes too
#let margin = 1in                       // PRD-FORM-004: margins are not stated in the rule text read; 1 inch as in the exemplar (README)
#let margins = (top: margin, bottom: margin, x: margin)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading-tab = 0.5in                // the label of a numbered heading hangs in this space; each deeper level steps in by it
#let passim-threshold = 7               // an authority cited on this many pages or more: "passim"
#let court-title = ("UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF PUERTO RICO")  // PRD-CAP-001: the court's name, the same for every case
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-inset = 10pt               // the party text stands off the caption's right rule
#let caption-gutter = 24pt             // the case number column starts this far right of the rule (a third of an inch)
#let designation-indent = 1.4in         // a party's designation ("Plaintiffs,") set in from its names
#let column-gutter = 0.3in              // between the two columns of the counsel and signature blocks
#let cert-sig-width = 3.4in             // the certificate's signature lines
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 72pt                // authorities: the page lists keep the last inch
#let toa-hang = 0.35in                  // authorities: the wrapped lines of an entry

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // PRD-FORM-003: double spacing (L.Civ.R. 7), the exemplar's 24 pt pitch
#let pitch-single = 13.8pt              // headings, caption, counsel, signature, footnotes, tables: single-spaced (L.Civ.R. 7), 1.15 x the type size
#let half-gap = 12pt                    // below a heading, between caption items and counsel groups, above the tables' column labels and groups
#let caption-pad = 12pt                 // the caption's bottom rule stands this far below the last party line
#let row-gap = 6pt                      // between the rows of the contents and the authorities
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 12.6pt            // from the last body line to the footnote separator (Word's footnote area)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italic case names, § signs and the like) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("prd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("prd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Lines that each take one single-spaced paragraph; the first with space above it.
#let line-stack(lines, above: 0pt) = for (j, l) in lines.enumerate() {
  line-block(above: if j == 0 { above } else { 0pt }, l)
}

// ---------------------------------------------------------------------------
// Headings (PRD-CONT-001): centred capitals for sections (level 1, unnumbered); level 2 I., level 3 A.,
// level 4 1., level 5 a. (Argument sub-headings). Sub-headings are numbered by the template, not typed.
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

#let label-indent(level) = calc.max(level - 2, 0) * heading-tab

/// The printed page label of a location.
#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

// ---------------------------------------------------------------------------
// Table of contents and table of authorities (D.P.R. L.Civ.R. 7 as quoted in README: a memorandum of 10 pages
// or more has a table of contents; the table of authorities follows the exemplar's convention).
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
  ("statute", "Statutes"),
  ("rule", "Rules"),
  ("regulation", "Regulations"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  table-head("Table of Authorities", "Page(s)")
  context {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("prd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover: court title, caption (parties left, case number, judge and the title of the paper right),
// and the counsel block under the caption (two columns, single-spaced).
// ---------------------------------------------------------------------------

#let caption-table(meta) = block(above: pitch-double, below: 0pt, grid(
  columns: (caption-left, 1fr),
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation set in from the names; "v." centered between the parties.
    let sides = need(meta, "caption")
    for (i, side) in sides.enumerate() {
      if i > 0 { line-block(above: half-gap, align(center, [v.])) }
      for (j, n) in side.names.enumerate() { line-block(above: if i > 0 and j == 0 { half-gap } else { 0pt }, inl(n)) }
      line-block(pad(left: designation-indent, inl(side.designation)))
    }
  }),
  pad(left: caption-gutter, {
    line-block[Case No. #need(meta, "case_number")]
    if "judge" in meta { line-block(inl(meta.judge)) }
    line-block(above: half-gap, strong(upper(inl(need(meta, "brief_title")))))
  }),
))

/// Groups of lines two to a row, the rows half a line apart (the counsel block and the signatures).
#let two-columns(groups, above) = block(above: above, below: 0pt, grid(
  columns: (1fr, 1fr),
  column-gutter: column-gutter,
  row-gutter: half-gap,
  ..groups.map(g => block(width: 100%, breakable: false, line-stack(g))),
))

#let cover(meta) = {
  for l in court-title { line-block(align(center, strong(l))) }
  caption-table(meta)
  if "counsel" in meta {
    two-columns(need(meta, "counsel").map(g => g.map(inl)), pitch-double)
  }
}

// ---------------------------------------------------------------------------
// Signature block (PRD-SIG-001): "Respectfully submitted," and the date on one line, then each signing counsel
// group, two to a row. The block never breaks across a page.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
    line-block[Respectfully submitted,#h(1fr)Dated: #need(meta, "date")]
    two-columns(sig.groups.map(g => {
      let lines = g.at("lines", default: ()).map(inl)
      if "signer" in g { lines = ([By: s/ #g.signer], [#g.signer]) + lines }
      lines
    }), half-gap)
  })
}

// ---------------------------------------------------------------------------
// Certificate of service (PRD-SIG-002): the form sentence is the court's CM/ECF wording; the place, date and
// signer come from the sample. The certificate never breaks across a page.
// ---------------------------------------------------------------------------

#let certificate(meta) = if "certificate" in meta {
  let c = meta.certificate
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
    heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
    let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(content))
    body-par[I HEREBY CERTIFY that on this same date I electronically filed the foregoing with the Clerk of the Court using the CM/ECF system, which will send notification of such filing to all counsel of record.]
    body-par[In #c.place, this #c.date.]
    block(width: cert-sig-width, above: half-gap, below: 0pt,
      line-stack(([s/ #c.signer], [#c.signer]) + c.at("lines", default: ()).map(inl)))
  })
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let prd-motion-brief(meta, md) = {
  for k in ("case_number", "caption", "brief_title", "date", "signature") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, numbering: none, footer: none)
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"), author: "")
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // A doubled sign stays with its number ("§§ 157"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
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

  // The cover has no page number (PRD-FORM-005 numbers the pages that follow it).
  cover(meta)

  // PRD-FORM-005: the page number centered at the foot, at the type size, in a single-spaced line box (Word's
  // footer). The tables are numbered in lower-case roman; the memorandum starts again at 1.
  set page(numbering: "i", footer-descent: 30%,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())))
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)

  set page(numbering: "1")   // a new page, numbered from 1
  counter(page).update(1)
  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  certificate(meta)
}
