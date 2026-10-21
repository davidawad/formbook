// U.S. District Court, District of Puerto Rico: motion to dismiss with the memorandum of law in support
// (Fed. R. Civ. P. 7(b), 10(a), 12(b); the form rules of D.P.R. Local Civil Rule 7 as quoted in ../README.md).
// Rule-driven and content-agnostic: every case-specific word comes from the sample's frontmatter, never from
// this file. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same sample file. Requirement IDs (PRD-...) in ../README.md say what each parameter traces to.

#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/tables.typ": leader-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // PRD-FORM-002: proportional font; Times New Roman substitute per docs/FONTS.md, vendored in /fonts (see ../README.md)
#let type-size = 12pt                   // PRD-FORM-002: 12 point or larger for a proportional font (L.Civ.R. 7)
#let line-pitch = 24pt                  // PRD-FORM-003: double spacing (L.Civ.R. 7); the baseline pitch of body text
#let body-leading = 1.345em             // gap between body lines at 12 pt in Liberation Serif: gives the 24 pt pitch (measured; see README)
#let single-leading = 0.5em             // headings' inner lines, counsel block, caption, footnotes, TOC and TOA: single-spaced
#let margin = 1in                       // PRD-FORM-004: margins are not stated in the rule text read; 1 inch as in the exemplar (README)
#let margins = (top: margin, bottom: margin, x: margin)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading-tab = 0.5in                // the label of a numbered heading hangs in this space
#let footer-size = 12pt                 // PRD-FORM-005: page numbers at bottom centre, same size as the text
#let passim-threshold = 7               // an authority cited on this many pages or more: "passim"
#let court-title = ("UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF PUERTO RICO")  // PRD-CAP-001: the court's name, the same for every case
#let caption-left = 3.4in               // width of the party column of the caption

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

/// Lines that each take one line of single-spaced text, with no paragraph space between them.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  for i in items {
    inl(i)
    linebreak()
  }
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

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

#let label-indent(level) = (level - 2) * heading-tab

// ---------------------------------------------------------------------------
// Table of contents and table of authorities (D.P.R. L.Civ.R. 7 as quoted in README: a memorandum of 10 pages
// or more has a table of contents; the table of authorities follows the exemplar's convention).
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.25em)])

/// One table-of-contents row from a heading element; wrapped lines hang under the title.
#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = heading-num(..nums)
  let ind = if hd.level == 1 { 0pt } else { label-indent(hd.level) }
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  link(hd.location(), block(width: 100%, above: 0.45em, below: 0pt, grid(
    columns: (1fr, auto), column-gutter: 0.4em,
    hang(ind + heading-tab, {
      h(ind)
      if lab != "" { box(width: heading-tab, lab) }
      if hd.level == 1 { upper(hd.body) } else { hd.body }
      h(0.2em)
      dot-leader
    }),
    align(right + bottom, box(width: 2em, align(right, pg))),
  )))
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong[Page]))
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
  ("regulation", "Regulations"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  align(right, block(above: 0.3em, below: 0pt, strong[Page(s)]))
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("prd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 1em } else { 1.4em }, below: 0.2em, sticky: true, {
        set par(first-line-indent: 0pt, leading: single-leading)
        strong(title)
      })
      first = false
      for (key, a) in members {
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        block(breakable: false, above: 0.6em, below: 0pt, width: 100%, leader-row({
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
        }, page-text, hang: 0.35in, leading: single-leading, lead-gap: 0.8em, dot-gap: 0.25em))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption (parties left, case number, judge and the title of the paper right),
// and the counsel block under the caption (two columns, single-spaced).
// ---------------------------------------------------------------------------

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 12pt), {
      set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
      for (i, side) in sides.enumerate() {
        for n in side.names {
          inl(n)
          linebreak()
        }
        pad(left: 1.4in, inl(side.designation))
        if i < sides.len() - 1 {
          v(line-pitch * 0.5)
          align(center, [v.])
          v(line-pitch * 0.5)
        }
      }
    }),
    block(inset: (left: 0.1in), {
      set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
      [Case No. #need(meta, "case_number")]
      if "judge" in meta {
        linebreak()
        [#meta.judge]
      }
      v(line-pitch * 0.5)
      strong(upper(need(meta, "brief_title")))
    }),
  )
}

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  align(center, {
    for l in court-title { strong(l); linebreak() }
  })
  v(line-pitch)
  caption-table(meta)
  if "counsel" in meta {
    v(line-pitch)
    grid(
      columns: (1fr, 1fr),
      column-gutter: 0.3in,
      row-gutter: line-pitch * 0.5,
      ..need(meta, "counsel").map(g => block(width: 100%, line-stack(g))),
    )
  }
}

// ---------------------------------------------------------------------------
// Signature block (PRD-SIG-001): the date, then each signing counsel group, two to a row.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    h(1fr)
    [Dated: #need(meta, "date")]
    v(line-pitch * 0.5)
    grid(
      columns: (1fr, 1fr),
      column-gutter: 0.3in,
      row-gutter: line-pitch * 0.5,
      ..sig.groups.map(g => {
        let lines = g.at("lines", default: ())
        if "signer" in g {
          lines = ("By: s/ " + g.signer, g.signer) + lines
        }
        block(width: 100%, breakable: false, line-stack(lines))
      }),
    )
  })
}

// ---------------------------------------------------------------------------
// Certificate of service (PRD-SIG-002): the form sentence is the court's CM/ECF wording; the place, date and
// signer come from the sample.
// ---------------------------------------------------------------------------

#let certificate(meta) = if "certificate" in meta {
  let c = meta.certificate
  block(breakable: false, above: line-pitch, {
    heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
    set par(first-line-indent: para-indent, leading: body-leading, spacing: body-leading, justify: false)
    [I HEREBY CERTIFY that on this same date I electronically filed the foregoing with the Clerk of the Court using the CM/ECF system, which will send notification of such filing to all counsel of record.]
    parbreak()
    [In #c.place, this #c.date.]
    v(line-pitch * 0.5)
    block(width: 3.4in, align(left, line-stack(("s/ " + c.signer, c.signer) + c.lines)))
  })
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let running-footer = context {
  let loc = here()
  set text(size: footer-size)
  align(center, numbering(loc.page-numbering(), ..counter(page).get()))
}

#let prd-motion-brief(meta, md) = {
  for k in ("case_number", "caption", "brief_title", "date", "signature") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter")
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"), author: "")
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: heading-num)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      [#it.body#metadata(key)<toa-hit>]
    } else {
      it
    }
  }

  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    if it.level == 1 {
      block(width: 100%, above: line-pitch, below: line-pitch * 0.5, sticky: true, {
        set text(size: type-size)
        align(center, strong(upper(it.body)))
      })
    } else {
      let ind = label-indent(it.level)
      block(width: 100%, above: line-pitch, below: line-pitch * 0.5, sticky: true, {
        set text(size: type-size)
        hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          strong(it.body)
        })
      })
    }
  }

  // The cover has no page number; the front matter is numbered i, ii, ...; the memorandum from 1.
  page(numbering: none, footer: none, margin: margins, cover(meta))
  page(numbering: "i", footer: running-footer, margin: margins, {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  page(numbering: "1", footer: running-footer, margin: margins, {
    counter(page).update(1)
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
    certificate(meta)
  })
}
