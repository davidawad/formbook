// U.S. Bankruptcy Court, Southern District of California (casb): motion with points and authorities
// (one filed document; the memorandum is combined with the motion, as the exemplar does).
//
// Rule-driven and content-agnostic. Requirement IDs (CASB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. Every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // CASB-FORM-002: vendored in fonts/; see README.md
#let type-size = 12pt                   // CASB-FORM-002: 12 point; the rule text is not verified, see README.md
#let pitch = 24pt                       // CASB-FORM-003: double spacing; the numbered lines are this pitch
#let lines-per-page = 27                // CASB-FORM-003: pleading paper, 28 numbered lines (exemplars)
#let page-w = 8.5in                     // CASB-FORM-001: 8 1/2 x 11 paper
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let body-leading = 1.35em              // double spacing: 1.35em leading gives a 24 pt baseline pitch at 12 pt (measured, README.md)
#let single-leading = 0.5em             // single spacing for counsel, caption, signature, tables of contents and authorities
#let para-indent = 0.5in
#let heading-tab = 0.5in                // the label column of a numbered heading
#let passim-threshold = 7               // an authority cited on this many pages or more is "passim"
#let counsel-lines = 7                  // the court title starts after at least this many numbered lines

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("casb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, citations).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("casb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A heading: whole numbered lines, kept with the text after it.
#let heading-block(c) = block(width: text-width, sticky: true, above: 0pt, below: 0pt, on-grid(c))

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Page furniture (pleading paper, as in the exemplars)
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.5in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Footer: page number, then the short title and the case number, each centered on its own line.
#let footer-block(meta) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 4pt,
  block(width: text-width, stack(
    dir: ttb,
    spacing: 2pt,
    align(center, text(size: 10pt, context {
      let pn = here().page-numbering()
      if pn != none { numbering(pn, ..counter(page).get()) }
    })),
    align(center, text(size: 9pt, upper(need(meta, "footer_title")))),
    align(center, text(size: 9pt, [CASE NO. #need(meta, "case_number")])),
  )),
)

// ---------------------------------------------------------------------------
// Tables of contents and authorities (LBR 9013-7(d)(3); see README.md)
// ---------------------------------------------------------------------------

// Headings: numbering (level 2 "I.", 3 "A.", 4 "1.", 5 "a."); level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) }
  else if lv == 3 { numbering("A.", k) }
  else if lv == 4 { numbering("1.", k) }
  else if lv == 5 { numbering("a.", k) }
  else { "" }
}

#let dot-leader = box(width: 1fr, repeat[.#h(0.25em)])

/// One table-of-contents row from a heading element; wrapped lines hang under the title.
#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = heading-num(..nums)
  let ind = if hd.level == 1 { 0pt } else { (hd.level - 2) * heading-tab }
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  // The page number sits in its own column so a wrapped title can never push it onto a new line.
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
  ("statute", "Federal Statutes"),
  ("rule", "Federal Rules"),
  ("regulation", "Federal Regulations"),
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
        panic("casb-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
        block(breakable: false, above: 0.6em, below: 0pt, width: 100%, hang(0.35in, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
          h(0.8em)
          dot-leader
          h(0.3em)
          page-text
        }))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover: counsel, court title, caption
// ---------------------------------------------------------------------------

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Counsel identification, upper left, from line 1. More counsel lines push the court title down.
#let counsel-block(meta) = context {
  let h = measure(width: text-width, line-stack(need(meta, "counsel"))).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch,
    line-stack(need(meta, "counsel")))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")))
  on-grid(align(center, text(weight: "bold", "SOUTHERN DISTRICT OF CALIFORNIA")))
  if "division" in meta {
    on-grid(align(center, text(weight: "bold", upper(meta.division))))
  }
}

/// A list of parties: each side's names, then its designation; "vs." between the sides.
#let party-rows(sides) = {
  let rows = ()
  for (k, p) in sides.enumerate() {
    if k > 0 { rows.push("vs.") }
    rows += p.names + (p.designation,)
  }
  rows
}

#let caption(meta) = on-grid(grid(
  columns: (3.2in, 1fr),
  column-gutter: 0.2in,
  block(width: 3.2in, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("In re",) + party-rows(need(meta, "in_re")))
    v(pitch * 0.5)
    line-stack(party-rows(need(meta, "caption")))
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("Case No. " + need(meta, "case_number"), "Chapter " + need(meta, "chapter")))
    if "adv_number" in meta {
      v(pitch * 0.5)
      line-stack(("Adv. Proc. No. " + meta.adv_number,))
    }
    v(pitch * 0.5)
    [#text(weight: "bold", inl(need(meta, "brief_title")))]
    // A hearing, when one is set, goes two lines below the case number (AP 2.3(a); see README.md).
    if "hearing" in meta {
      v(pitch * 0.5)
      line-stack(meta.hearing)
    }
    if "judge" in meta {
      v(pitch * 0.5)
      inl(meta.judge)
    }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  v(pitch)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  on-grid(grid(columns: (2.6in, 1fr), column-gutter: 0.2in,
    [Dated: #need(meta, "date")],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(pitch * 0.5)
      line-stack(sig.firm)
      v(pitch * 0.5)
      line-stack(("/s/ " + sig.signer,) + sig.at("lines", default: ()))
    }))
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

/// The markdown body, one blank-line-separated chunk at a time, each chunk on whole numbered lines
/// (as in the complaint template): a heading, a quotation (single-spaced and indented, Admin. Proc. 2.5),
/// or a paragraph. Paragraph gaps come from the grid, not from `par.spacing`, which is 0 here.
#let motion-body(md) = {
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true)
    } else if t.starts-with(">") {
      on-grid(pad(left: 0.5in, right: 0.5in, {
        set par(leading: single-leading, first-line-indent: 0pt)
        cmarker.render(t, raw-typst: false, smart-punctuation: true)
      }))
    } else {
      on-grid({
        set par(leading: body-leading, first-line-indent: para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true)
      })
    }
  }
}

#let casb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "chapter", "caption", "in_re", "counsel", "brief_title", "footer_title", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))
  let with-toc = meta.at("toc", default: false)

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    numbering: "1",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta),
  )
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
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

  // Headings: level 1 a centered section; level 2 a numbered section ("I."), hanging; level 3 "A.", bold.
  show heading: it => context {
    if it.level == 1 {
      heading-block(align(center, text(weight: "bold", upper(it.body))))
    } else {
      let nums = counter(heading).at(it.location()).slice(0, it.level)
      let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
      let ind = (it.level - 2) * heading-tab
      heading-block(hang(ind + heading-tab, {
        h(ind)
        box(width: heading-tab, lab)
        strong(it.body)
      }))
    }
  }

  // The "TO:" line follows the caption; the body follows it. With a table of contents, the tables
  // come first (roman pages), then the body restarts at page 1.
  let body = {
    set par(first-line-indent: para-indent)
    if "lead_in" in meta {
      on-grid({
        set par(leading: body-leading)
        inl(meta.lead_in)
      })
    }
    motion-body(md)
    signature-block(meta)
  }

  if with-toc {
    cover(meta)
    page(numbering: "i", {
      counter(page).update(1)
      toc-section()
      pagebreak()
      toa-section(authorities)
    })
    page(numbering: "1", {
      counter(page).update(1)
      body
    })
  } else {
    cover(meta)
    body
  }
}
