// U.S. District Court, Central District of California: notice of motion and motion, with the memorandum of
// points and authorities, on pleading paper.
//
// Rules: L.R. 11-3.1 to 11-3.8 (14-point font, 28 numbered lines, double spacing, title page); L.R. 7-3 (conference
// of counsel, stated in the notice); L.R. 7-4 (hearing date, time and judicial officer on the first page and on every
// document); L.R. 7-5 (memorandum served with the notice); L.R. 11-6.1 and 11-6.2 (length; certificate of compliance);
// L.R. 11-8 (tables for a memorandum over ten pages). See ../README.md for the rule text and its sources.
// Content-agnostic: every case word comes from the sample's frontmatter or markdown body, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // L.R. 11-3.1.1: proportionally spaced font, vendored in fonts/ (README.md, Known gaps)
#let type-size = 14pt                   // L.R. 11-3.1.1: standard (non-condensed) 14-point or larger
#let pitch = 24pt                       // L.R. 11-3.2 and 11-3.6: double spaced; the numbered lines are this pitch
#let lines-per-page = 27                // L.R. 11-3.2: not more than 28 lines per page
#let page-w = 8.5in                     // L.R. 11-3.2: 8 1/2 x 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // L.R. 11-3.2: line 1 begins at least one inch below the top edge
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
// Line pitch = line box (0.65 em for EB Garamond) + leading. 24 pt pitch at 14 pt: 24 - 0.65 * 14 = 14.9 pt of leading.
#let body-leading = 1.064em
#let single-leading = 0.1em             // counsel block, caption, headings, tables of contents and authorities: about 16 pt a line at 14 pt (README.md, Known gaps)
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let caption-left = 2.7in               // width of the party column of the caption (the title column takes the rest)
#let counsel-lines = 7                  // L.R. 11-3.8(a)-(c): counsel from line 1; the court title on or below line 8
#let footer-size = 10pt                 // footer: page number, paper title and case number; not body text
#let passim-threshold = 7               // an authority cited on this many pages or more: "passim" (convention)
#let margins = (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics, links) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("cacd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cacd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so what follows stays on the grid.
#let on-grid(c, sticky: false) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: sticky, c)
}

/// Single-spaced paragraph whose continuation lines hang by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Pleading paper (L.R. 11-3.2): numbers 1 to 28, two rules at the left edge, one at the right
// ---------------------------------------------------------------------------

#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.5in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Footer in the bottom margin: page number (in the numbering of the page it sits on), paper title, case number.
#let footer-block(meta) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: footer-size)
    context {
      let loc = here()
      align(center, numbering(loc.page-numbering(), ..counter(page).get()))
    }
    v(4pt)
    grid(
      columns: (1fr, auto),
      upper(need(meta, "footer_title")),
      [CASE NO. #need(meta, "case_number")],
    )
  }),
)

/// One page on the pleading grid. `numbering` is none for the cover; the footer is drawn by `footer-block`.
#let pleading-page(meta, numbering: "1", footer: true, body) = page(
  paper: "us-letter",
  numbering: numbering,
  footer: none,
  margin: margins,
  background: {
    line-numbers()
    pleading-rules()
  },
  foreground: if footer { footer-block(meta) } else { none },
  body,
)

// ---------------------------------------------------------------------------
// Headings: numbering and styles (L.R. 11-3.6 double spacing; 11-8 tables)
// ---------------------------------------------------------------------------

/// Printed label: level 2 "I.", 3 "A.", 4 "1.", 5 "a."; level 1 is unnumbered.
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

#let dot-leader = box(width: 1fr, repeat[.#h(0.25em)])

/// One table-of-contents row; wrapped lines hang under the title; the page number is in its own column.
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
  ("statute", "Federal Statutes"),
  ("rule", "Federal Rules"),
  ("regulation", "Federal Regulations"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:KEY` links in the body; a key with no registry entry stops the build.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  align(right, block(above: 0.3em, below: 0pt, strong[Page(s)]))
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("cacd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover (L.R. 11-3.8; hearing details per L.R. 7-4)
// ---------------------------------------------------------------------------

#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let counsel-block(meta) = context {
  // Lines 1-7 at least; more counsel lines push the court title down (L.R. 11-3.8(c)).
  let h = measure(width: text-width, line-stack(need(meta, "counsel"))).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch,
    line-stack(need(meta, "counsel")))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  on-grid(align(center, text(weight: "bold", "CENTRAL DISTRICT OF CALIFORNIA")))
  if "division" in meta {
    on-grid(align(center, text(weight: "bold", upper(meta.division))))
  }
}

#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in need(meta, "caption").enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("Case No. " + need(meta, "case_number"),))
    v(pitch * 0.5)
    [#text(weight: "bold", inl(need(meta, "brief_title")))]
    // Hearing details, opposite the caption (L.R. 7-4 and 11-3.8(e)): date, time, courtroom, judicial officer.
    let hearing = need(meta, "hearing")
    v(pitch * 0.5)
    for (k, lab) in (("date", "Date:"), ("time", "Time:"), ("place", "Courtroom:"), ("judge", "Judge:")) {
      if k in hearing {
        [#lab #inl(hearing.at(k))]
        linebreak()
      }
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
// Signature block (kept together)
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, on-grid(grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  [Dated: #need(meta, "date")],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(pitch * 0.5)
    line-stack(need(meta, "signature").at("firm", default: ()))
    v(pitch * 0.5)
    line-stack(("By: /s/ " + need(meta, "signature").signer, need(meta, "signature").signer) + need(meta, "signature").at("lines", default: ()))
  },
)))

// ---------------------------------------------------------------------------
// The body: markdown chunks on the grid. A heading stays with the chunk after it.
// ---------------------------------------------------------------------------

#let memo-body(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; each item fills whole lines (body-leading), so the grid holds.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      let piece = on-grid({
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        inl(t)
      })
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

/// The notice of motion: the frontmatter gives its paragraphs (hearing, grounds, conference statement).
#let notice-page(meta) = {
  on-grid({ set par(leading: body-leading); [TO PLAINTIFF AND ITS ATTORNEYS OF RECORD:] })
  for p in need(meta, "notice") {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(p)
    })
  }
  signature-block(meta)
}

#let certificate(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance]
  on-grid({
    set par(leading: body-leading)
    h(para-indent)
    [The undersigned, counsel of record for #inl(need(meta, "certificate_party")), certifies that this brief contains #need(meta, "word_count") words, which complies with the word limit of L.R. 11-6.1.]
  })
  signature-block(meta)
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let cacd-motion-brief(meta, md) = {
  // Loud failure beats silent omission.
  for k in ("case_number", "counsel", "caption", "brief_title", "footer_title", "hearing", "notice", "signature", "date", "certificate_party", "word_count") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: 0pt, justify: false,
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
      on-grid(align(center, strong(upper(it.body))), sticky: true)
    } else {
      let ind = label-indent(it.level)
      on-grid(hang(ind + heading-tab, {
        h(ind)
        box(width: heading-tab, lab)
        strong(it.body)
      }), sticky: true)
    }
  }

  // Cover: no number, no footer.
  pleading-page(meta, numbering: none, footer: false, cover(meta))
  // Notice of motion: arabic numbers from 1.
  pleading-page(meta, numbering: "1", {
    counter(page).update(1)
    notice-page(meta)
  })
  // Tables: roman numbers from i (L.R. 11-8).
  pleading-page(meta, numbering: "i", {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  // Memorandum, certificate: arabic numbers from 1.
  pleading-page(meta, numbering: "1", {
    counter(page).update(1)
    memo-body(md)
    signature-block(meta)
    pagebreak()
    certificate(meta)
  })
}
