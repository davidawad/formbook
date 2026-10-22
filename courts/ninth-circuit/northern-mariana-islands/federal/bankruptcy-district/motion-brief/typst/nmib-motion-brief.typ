// Bankruptcy Court, District of the Northern Mariana Islands (Bankruptcy Division): motion with a
// memorandum of law. Rule-driven and content-agnostic. Requirement IDs (NMIB-...) refer to ../rules.md and
// ../README.md, which quote or cite the rule text (LBR 5005-1, 9004-1, 9013-1; LR 5.2, 7.1; FRBP 9013).
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The markdown
// body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // NMIB-FORM-004: a serif font, no face named; Times New Roman, the house standard (docs/FONTS.md) and the exemplar's face
#let type-size = 12pt                    // NMIB-FORM-004: 12 point or larger
#let pitch = 24pt                        // NMIB-FORM-003: double spacing on 24 numbered lines
#let pitch-single = 12pt                 // NMIB-FORM-003: counsel block, caption, tables, signature: two single lines per numbered line
#let single-drop = 0.8 * (pitch - pitch-single)  // a single line this far below a numbered line's top stands on that line's number
#let lines-per-page = 24                 // NMIB-FORM-003: numbered lines per page (as in the filed exemplar)
#let page-w = 8.5in
#let page-h = 11in
#let top-margin = 1.5in                  // NMIB-FORM-005: top margin 1.5 in
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 1.5 in (at least the 1 in of NMIB-FORM-005): 24 lines, the page number below them
#let left-margin = 1.3in                 // NMIB-FORM-005: left margin at least 1 in; room for the line numbers
#let right-margin = 1in                  // NMIB-FORM-005: right margin at least 0.5 in
#let margins = (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin)
#let text-width = page-w - left-margin - right-margin
#let number-col = left-margin - 0.45in   // the line numbers end 0.45 in left of the text
#let para-indent = 0.5in
#let heading-tab = 0.5in                 // a heading's label box; each deeper level steps in by as much
#let designation-indent = 1in            // the designation under a party's names
#let caption-pad = 12pt                  // the caption's text stands this far from the party column's rules
#let sig-col = 3.2in                     // the signature column at the right
#let sig-line = 2.6in                    // the signature line
#let toc-col = 36pt                      // contents: the page numbers keep the last 36 pt of the line
#let toa-col = 72pt                      // authorities: the page lists keep the last inch of the line
#let footer-size = 11pt
#let footer-gap = 6pt                    // the page number's line stands this far below the last numbered line
#let passim-threshold = 7                // authority cited on this many pages or more: "passim"

// ---------------------------------------------------------------------------
// Pleading form: numbered lines and rules (NMIB-FORM-003)
// ---------------------------------------------------------------------------

/// Numbers 1 to 24 down the left margin, each in the line box of its numbered line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: number-col, height: pitch,
        align(right, text(size: type-size, ..edges(pitch), str(i)))))
  }
}

/// A double rule at the text's left edge and a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

#let pleading-background() = {
  line-numbers()
  pleading-rules()
}

/// The page number, centered under the last numbered line (none on the cover).
#let page-footer = context {
  let n = here().page-numbering()
  if n != none {
    place(top + left, dx: left-margin, dy: top-margin + lines-per-page * pitch + footer-gap,
      block(width: text-width, {
        set text(size: footer-size, ..edges(pitch-single))
        align(center, numbering(n, ..counter(page).get()))
      }))
  }
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nmib-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmib-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph (its own block); an empty string is a blank single line.
#let single(body, indent: 0pt, above: 0pt, al: left) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if body == "" { block(width: 100%, height: pitch-single, above: 0pt, below: 0pt) } else {
    pad(left: indent, align(al, if type(body) == str { inl(body) } else { body }))
  }
})

// ---------------------------------------------------------------------------
// Headings: numbering and styles (NMIB-CONT-001)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "A.", 3 "1.", 4 "a.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("A.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else { "" }
}

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = calc.max(level - 2, 0) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities: single lines, a blank single line between entries, the text wrapping
// before a page column and a dot leader to the page (listing-row)
// ---------------------------------------------------------------------------

/// A table's title (a numbered line) and the label of its page column (a single line on the next number).
#let table-head(title, col-label) = {
  block(width: 100%, above: 0pt, below: 0pt, align(center, strong(upper(title))))
  single(strong(col-label), above: single-drop, al: right)
}

#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = heading-num(..nums)
  let ind = label-indent(hd.level)
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  let body = {
    h(ind)
    if hd.level > 1 { box(width: heading-tab, lab) }
    if hd.level == 1 { upper(hd.body) } else { hd.body }
  }
  block(width: 100%, above: pitch-single, below: 0pt, {
    set text(..edges(pitch-single))
    listing-row(hd.location(), body, pg, toc-col, ind + heading-tab, 0pt)
  })
}

#let toc-section() = {
  table-head("Table of Contents", "Page")
  context {
    for hd in query(heading.where(outlined: true)) {
      if hd.level <= 4 { toc-entry(hd) }
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Statutes"),
  ("rule", "Rules"),
  ("local", "Local Bankruptcy Rules"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  table-head("Table of Authorities", "Page(s)")
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("nmib-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(width: 100%, above: pitch, below: 0pt, sticky: true, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        strong(title)
      })
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let body = {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
        }
        block(width: 100%, above: pitch-single, below: 0pt, {
          set text(..edges(pitch-single))
          listing-row(none, body, page-text, toa-col, heading-tab, 0pt)
        })
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (LBR 5005-1(b); LR 5.2): counsel, court, caption; single lines whose odd lines stand on the numbers
// ---------------------------------------------------------------------------

/// Counsel block, upper left: names, firm, address, telephone, email and bar number as given; the role after a
/// blank line, in italics.
#let counsel-block(meta) = {
  let ls = need(meta, "counsel")
  // the drop is an inset, not spacing: spacing at the top of a page is dropped, Word keeps it where a section starts
  block(width: 100%, above: 0pt, below: 0pt, inset: (top: single-drop), {
    for l in ls { single(l) }
    single("")
    single(emph(inl(need(meta, "counsel_role"))))
  })
}

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let hearing = meta.at("hearing", default: (:))
  let left = {
    for (i, side) in sides.enumerate() {
      if i > 0 { single(""); single("v.", al: center); single("") }
      for n in side.names { single(n) }
      single("")
      single(side.designation, indent: designation-indent)
    }
  }
  let right = {
    single("Case No. " + need(meta, "case_number"))
    single("Chapter " + need(meta, "chapter"))
    single("")
    single(strong(upper(inl(need(meta, "brief_title")))))
    // LBR 5005-1(b)(2): the hearing date and time and the presiding judge, when the document is the subject of a hearing.
    let rows = (("date", "Hearing Date:"), ("time", "Hearing Time:"), ("judge", "Judge:")).filter(r => r.at(0) in hearing)
    if rows.len() > 0 { single("") }
    for (k, lab) in rows { single([#lab #inl(hearing.at(k))]) }
  }
  block(width: 100%, above: pitch, below: 0pt, grid(
    columns: (1fr, 1fr),
    grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-pad, bottom: pitch-single), left),
    grid.cell(inset: (left: caption-pad), right),
  ))
}

#let cover(meta) = {
  counsel-block(meta)
  block(width: 100%, above: pitch, below: 0pt, for l in need(meta, "court") { single(strong(upper(l)), al: center) })
  caption-table(meta)
}

// ---------------------------------------------------------------------------
// Signature block (convention; the court's rules do not prescribe the form; see ../README.md)
// ---------------------------------------------------------------------------

/// "Dated:" at the left; at the right "Respectfully submitted," and for each signer a signature line, the name and
/// the role. A numbered line above it, inside the block, so the block is laid out alike wherever it falls.
#let signature-block(meta) = {
  let sigs = need(meta, "signature")
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, grid(
    columns: (1fr, sig-col),
    inset: (top: pitch + single-drop),
    single("Dated: " + need(meta, "date")),
    {
      single("Respectfully submitted,")
      for s in sigs {
        single("")
        single("")
        single(box(width: sig-line, stroke: (bottom: 0.5pt), [/s/]))
        single(s.signer)
        for l in s.at("lines", default: ()) { single(l) }
      }
    },
  ))
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let nmib-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "chapter", "court", "caption", "counsel", "counsel_role", "brief_title", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, background: pleading-background(), foreground: page-footer, footer: none)
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").first().signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the numbered-line pitch (double spaced); the docx engine sets the same twips.
  show: xengine.with(pitch: pitch, list-indent: para-indent)
  // A doubled sign stays with its number too ("§§ 1334(b)"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  set footnote.entry(gap: 0pt, clearance: pitch-single, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size, ..edges(pitch-single))
  show footnote.entry: set par(first-line-indent: 0pt)

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      [#it.body#metadata(key)<toa-hit>]
    } else {
      it
    }
  }

  // Headings: numbered lines (the body pitch), a numbered line above, kept with the text after them. Level 1
  // centered bold capitals; levels 2 to 4 bold, the label in a half-inch box at its level's indent, the lines after
  // the first hanging after the label.
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    block(width: 100%, above: pitch, below: 0pt, sticky: true, {
      set text(size: type-size)
      if it.level == 1 {
        set par(first-line-indent: 0pt)
        align(center, strong(upper(it.body)))
      } else {
        let ind = label-indent(it.level)
        par(first-line-indent: 0pt, hanging-indent: ind + heading-tab,
          [#h(ind)#box(width: heading-tab, strong(lab))#strong(it.body)])
      }
    })
  }

  page(numbering: none, cover(meta))
  page(numbering: "i", {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  page(numbering: "1", {
    counter(page).update(1)
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  })
}
