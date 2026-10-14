// Opening brief in support of a motion to dismiss (memorandum of points and authorities) for the United
// States District Court for the District of Delaware (ded). Rules: D. Del. LR 7.1.3(a)(1) (cover: court,
// caption, civil action number, nature of the paper, date, party, counsel's name, Delaware bar number,
// address and telephone), 7.1.3(a)(2) and 5.1.1(a) (at least 12 point type for all printed matter, double
// spacing "typical word processing" (not exactly 24 point), at least 1 inch margins, consecutive page
// numbers, date and descriptive title, Delaware counsel under the signature line), 7.1.3(a)(4) (20 pages,
// exclusive of the contents and the citations) and 7.1.3(b)(1) (table of contents, table of citations,
// nature and stage, summary of argument, statement of facts, argument, conclusion, in that order).
// See ../README.md for the rule text, the verification date and the open choices.
// Content-agnostic: every case-specific word comes from the sample's frontmatter or markdown, never from
// this file. Authorities are linked in the markdown as [text](toa:KEY); the table of citations and its
// page numbers are built from those links.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"          // Vendored in fonts/ (the only serif vendored). Not a rule requirement: the rule is about size.
#let type-size = 13pt                     // LR 5.1.1(a): at least 12 point for all printed matter. 13 pt is a style choice (Garamond sets smaller than Times at the same size; see README.md).
#let footer-size = 13pt                   // LR 5.1.1(a) "all printed matter": the page number is printed matter too.
#let line-pitch = 27pt                    // Double spacing, measured against the exemplar's pitch (README.md).
#let body-leading = 1.43em                // Gap between body lines. EB Garamond's line box is about 0.65em, so 1.43em gives about 2.08em (27 pt at 13 pt).
#let single-leading = 0.45em              // Cover, counsel, caption, signature, headings that wrap, footnotes, contents and citations.
#let margins = (top: 1in, bottom: 1in, x: 1in)   // LR 5.1.1(a): margins not less than 1 inch.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let passim-threshold = 7                 // An authority on this many pages or more is printed as "passim".

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics, citations) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ded-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ded-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A stack of single-spaced lines. One item per line; "" is an empty line.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Dot leader for the contents and the citations.
#let dot-leader = box(width: 1fr, repeat[.])

/// Printed label of a numbered heading: level 2 "I.", 3 "A.", 4 "1.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) }
  else if lv == 3 { numbering("A.", k) }
  else if lv == 4 { numbering("1.", k) }
  else { "" }
}

// ---------------------------------------------------------------------------
// Cover: court, caption, title, counsel, date
// ---------------------------------------------------------------------------

/// The caption: the parties on the left, closed by a rule on the right and bottom; the civil action number
/// on the right. Each party's names are followed by its designation; "v." sits between the parties.
#let caption-table(meta) = grid(
  columns: (3.4in, 1fr),
  column-gutter: 0.3in,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.12in, bottom: 0.12in), {
    let items = ()
    for (k, p) in need(meta, "caption").enumerate() {
      if k > 0 { items.push("v.") }
      for n in p.names { items.push(n) }
      items.push(p.designation)
    }
    line-stack(items)
  }),
  block(inset: (left: 0.15in), {
    v(line-pitch * 0.5)
    line-stack(("C.A. No. " + str(need(meta, "case_number")),))
  }),
)

#let cover(meta) = page(numbering: none, footer: none, margin: margins, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  align(center, strong(stack(dir: ttb, spacing: single-leading,
    [IN THE UNITED STATES DISTRICT COURT],
    [FOR THE DISTRICT OF DELAWARE],
  )))
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
  align(center, strong(upper(inl(need(meta, "brief_title")))))
  v(line-pitch)
  // LR 7.1.3(a)(1): the counsel block for the filing party sits on the cover.
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.3in,
    {
      if "of_counsel" in meta {
        [OF COUNSEL:]
        v(single-leading)
        line-stack(meta.of_counsel)
      }
    },
    line-stack(need(meta, "counsel")),
  )
  v(line-pitch)
  [Dated: #need(meta, "date")]
})

// ---------------------------------------------------------------------------
// Signature block (Delaware counsel under the signature line: LR 5.1.1(a))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    grid(
      columns: (1fr, 3.3in),
      column-gutter: 0.2in,
      [Dated: #need(meta, "date")],
      {
        line-stack(sig.firm)
        v(line-pitch * 0.5)
        line-stack(("/s/ " + sig.signer,) + sig.lines)
      },
    )
  })
}

// ---------------------------------------------------------------------------
// Contents and table of citations (LR 7.1.3(b)(1)(A)-(B))
// ---------------------------------------------------------------------------

/// One contents line: label at its level's indent, title, dot leader, page.
#let toc-entry(hd) = {
  let ind = if hd.level <= 1 { 0pt } else { (hd.level - 2) * heading-tab }
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = if hd.numbering == none { "" } else { numbering(hd.numbering, ..nums) }
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  block(width: 100%, above: 0.5em, below: 0pt, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
    grid(
      columns: (if hd.level <= 1 { 0pt } else { ind + heading-tab }, 1fr),
      [#h(ind)#lab],
      [#hd.body#h(0.3em)#dot-leader#h(0.3em)#pg],
    )
  })
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, strong[Page])
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
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of citations, built from the `toa:` links found in the body (LR 7.1.3(b)(1)(B)).
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Citations]
  align(right, strong[Page(s)])
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ded-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        // The page numbers sit in their own right-hand column, so a long entry wraps without stranding them.
        block(breakable: false, above: 0.6em, below: 0pt, width: 100%, {
          set par(first-line-indent: 0pt, leading: single-leading, hanging-indent: 0.35in)
          grid(
            columns: (1fr, auto),
            column-gutter: 0.4em,
            {
              if "name" in a {
                if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
                [ ]
              }
              inl(a.cite)
              h(0.3em)
              dot-leader
            },
            align(bottom, page-text),
          )
        })
      }
    }
  }
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ded-motion-brief(meta, md) = {
  for k in ("case_number", "caption", "brief_title", "counsel", "date", "signature") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  set document(title: need(meta, "brief_title") + ", C.A. No. " + need(meta, "case_number"), author: need(meta, "signature").signer)
  set page(paper: "us-letter")
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false)
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

  // Headings: level 1 unnumbered, centred bold caps; levels 2 and up hang their label at the margin.
  show heading: it => context {
    if it.level == 1 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        text(size: type-size, align(center, strong(upper(it.body)))))
    } else {
      let nums = counter(heading).at(it.location()).slice(0, it.level)
      let lab = numbering(it.numbering, ..nums)
      let ind = (it.level - 2) * heading-tab
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true, {
        set par(first-line-indent: 0pt, leading: single-leading)
        grid(
          columns: (ind + heading-tab, 1fr),
          [#h(ind)#lab], text(size: type-size, strong(it.body)),
        )
      })
    }
  }

  cover(meta)

  page(numbering: "i", footer: context align(center, text(size: footer-size, counter(page).display())), margin: margins, {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })

  page(numbering: "1", footer: context align(center, text(size: footer-size, counter(page).display())), margin: margins, {
    counter(page).update(1)
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  })
}
