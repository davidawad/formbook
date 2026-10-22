// U.S. District Court, Central District of California: notice of motion and motion, with the memorandum of
// points and authorities, on pleading paper.
//
// Rules: L.R. 11-3.1 to 11-3.8 (14-point font, 28 numbered lines, double spacing, title page); L.R. 7-3 (conference
// of counsel, stated in the notice); L.R. 7-4 (hearing date, time and judicial officer on the first page and on every
// document); L.R. 7-5 (memorandum served with the notice); L.R. 11-6.1 and 11-6.2 (length; certificate of compliance);
// L.R. 11-8 (tables for a memorandum over ten pages). See ../README.md for the rule text and its sources.
// Content-agnostic: every case word comes from the sample's frontmatter or markdown body, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/pleading-paper.typ": line-numbers as shared-line-numbers, pleading-rules as shared-pleading-rules
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // L.R. 11-3.1.1: proportionally spaced font (the exemplar's face)
#let type-size = 14pt                   // L.R. 11-3.1.1: standard (non-condensed) 14-point or larger
#let lines-per-page = 27                // L.R. 11-3.2: not more than 28 lines per page
#let page-w = 8.5in                     // L.R. 11-3.2: 8 1/2 x 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // L.R. 11-3.2: line 1 begins at least one inch below the top edge
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let para-indent = 0.5in
#let heading-tab = 0.5in                // a heading's label in a box of this width; each level a further step in
#let list-label = 0.4in                 // list items: the label half an inch in, in a box of this width
#let caption-left = 2.7in               // width of the party column of the caption (the title column takes the rest)
#let caption-inset = 10pt               // the party column's text stands off its right rule
#let caption-foot = 8pt                 // and its last line off its bottom rule
#let caption-right = 0.3in              // the case column stands off the party column's rule
#let signature-left = 2.6in             // the date column of the signature block
#let signature-gutter = 0.2in
#let counsel-lines = 7                  // L.R. 11-3.8(a)-(c): counsel from line 1; the court title on or below line 8
#let footer-size = 10pt                 // footer: page number, paper title and case number; not body text
#let footer-case = 2.5in                // the footer's case-number column (the title takes the rest)
#let toc-col = 0.5in                    // the page column of the table of contents
#let toa-col = 1in                      // the page column of the table of authorities
#let toa-hang = 0.35in                  // an authority's lines after the first
#let passim-threshold = 7               // an authority cited on this many pages or more: "passim" (convention)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is set here (Word's exact
// line spacing; docx/cacd-motion-brief.lua sets the same twips).
#let pitch = 24pt                       // L.R. 11-3.2 and 11-3.6: double spaced; the numbered lines (body, headings, tables)
#let pitch-single = 16pt                // single spacing (counsel, caption, signature): Word's single line at 14 pt
#let gap = pitch-single                 // a single line between the groups of the caption and signature
// A group of single lines starts this far below a numbered line's top, so every third single line stands level
// with a line number and the others 8 pt off it: the PDF text reads the same lines in every engine.
#let single-drop = 0.8 * (pitch - pitch-single)
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer
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

/// Single-spaced lines, one paragraph per item, with `above` before the first.
#let line-stack(items, above: 0pt, weight: "regular") = block(above: above, below: 0pt, {
  set text(..edges(pitch-single), weight: weight)
  for i in items { block(if type(i) == str { inl(i) } else { i }) }
})

/// A body paragraph: the first line indented half an inch.
#let body-par(content) = block(par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Pleading paper (L.R. 11-3.2): numbers 1 to 27, two rules at the left edge, one at the right
// ---------------------------------------------------------------------------

#let line-numbers() = shared-line-numbers(left-margin, top-margin, pitch, lines-per-page, type-size, ..edges(pitch))

#let pleading-rules() = shared-pleading-rules(page-w, page-h, left-margin, right-margin)

/// Footer in the bottom margin: page number (in the numbering of the page it sits on), paper title, case number.
#let footer-block(meta) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: page-w - left-margin - right-margin, {
    set text(size: footer-size, ..edges(12pt))   // 12 pt line boxes (docx: exact 240 twips)
    context {
      let loc = here()
      align(center, numbering(loc.page-numbering(), ..counter(page).get()))
    }
    v(4pt)
    grid(
      columns: (1fr, footer-case),
      upper(need(meta, "footer_title")),
      align(right)[CASE NO. #need(meta, "case_number")],
    )
  }),
)

/// One part on the pleading grid. `numbering` is none for the cover, which has no footer.
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

/// A heading of the tables and the certificate: centered, bold, capitals (in a block: a heading's own space below
/// is dropped at the end of it).
#let title-heading(t) = block(sticky: true, heading(level: 1, numbering: none, outlined: false, t))

/// One table-of-contents row: the label in its box, the title hanging after it, a leader to the page column.
#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = heading-num(..nums)
  let ind = if hd.level == 1 { 0pt } else { label-indent(hd.level) }
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  listing-row(hd.location(), {
    h(ind)
    if lab != "" { box(width: heading-tab, lab) }
    if hd.level == 1 { upper(hd.body) } else { hd.body }
  }, pg, toc-col, ind + heading-tab, 0pt)
}

#let toc-section() = {
  title-heading[Table of Contents]
  block(sticky: true, align(right, strong[Page]))
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
/// Each group a numbered line below the one before, its title kept with its first row.
#let toa-section(authorities) = {
  title-heading[Table of Authorities]
  block(sticky: true, align(right, strong[Page(s)]))
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
      block(above: if first { 0pt } else { pitch }, sticky: true, strong(title))
      first = false
      for (key, a) in members {
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        listing-row(none, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
        }, page-text, toa-col, toa-hang, 0pt)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (L.R. 11-3.8; hearing details per L.R. 7-4)
// ---------------------------------------------------------------------------

/// Lines 1-7 at least; more counsel lines push the court title down to the next numbered line (L.R. 11-3.8(c)).
#let counsel-block(meta) = {
  let counsel = need(meta, "counsel")
  let n = calc.max(counsel-lines, calc.ceil((single-drop + counsel.len() * pitch-single) / pitch))
  block(height: n * pitch, inset: (top: single-drop), line-stack(counsel))
}

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "CENTRAL DISTRICT OF CALIFORNIA")
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { block(align(center, text(weight: "bold", l))) }
}

/// The caption, a numbered line below the court title: the party column ruled at its right and foot (the rules run
/// to the foot of the row), the case column beside it with the title and the hearing details (L.R. 7-4, 11-3.8(e)).
#let caption(meta) = block(above: pitch, grid(
  columns: (caption-left, 1fr),
  grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (top: single-drop, right: caption-inset, bottom: caption-foot), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in need(meta, "caption").enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  grid.cell(inset: (top: single-drop, left: caption-right), {
    line-stack(("Case No. " + need(meta, "case_number"),))
    line-stack((need(meta, "brief_title"),), above: gap, weight: "bold")
    let hearing = need(meta, "hearing")
    let rows = ()
    for (k, lab) in (("date", "Date:"), ("time", "Time:"), ("place", "Courtroom:"), ("judge", "Judge:")) {
      if k in hearing { rows.push(lab + " " + hearing.at(k)) }
    }
    line-stack(rows, above: gap)
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Signature block: a numbered line below the text; never split across pages
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, inset: (top: single-drop), grid(
    columns: (signature-left, 1fr),
    column-gutter: signature-gutter,
    line-stack(("Dated: " + need(meta, "date"),)),
    {
      line-stack(("Respectfully submitted,",))
      line-stack(sig.at("firm", default: ()), above: gap)
      line-stack(("By: /s/ " + sig.signer, sig.signer) + sig.at("lines", default: ()), above: gap)
    },
  ))
}

/// Blocks whose last one stays whole with the signature block after it.
#let with-signature(pieces, sig) = {
  for p in pieces.slice(0, -1) { p }
  block(breakable: false, { pieces.last(); sig })
}

// ---------------------------------------------------------------------------
// The body: markdown chunks. A heading stays with the chunk after it (sticky).
// ---------------------------------------------------------------------------

/// A list: each label half an inch in, in a box of `list-label`, the text hanging after it.
#let list-items(t) = {
  let m = t.match(regex("^(\\d+)\\."))
  let n = if m == none { 1 } else { int(m.captures.at(0)) }
  let items = t.split(regex("\\r?\\n(?:\\d+\\.|[-*+])[ \\t]+"))
  items.at(0) = items.at(0).replace(regex("^(?:\\d+\\.|[-*+])[ \\t]+"), "")
  for (k, it) in items.enumerate() {
    let lab = if m == none { [•] } else { str(n + k) + "." }
    block(pad(left: para-indent, par(hanging-indent: list-label, first-line-indent: 0pt,
      box(width: list-label, lab) + inl(it.replace(regex("\\s*\\r?\\n\\s*"), " ")))))
  }
}

#let memo-pieces(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  chunks.map(t => {
    if t.starts-with("#") {
      block(sticky: true, cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-items(t)
    } else {
      body-par(inl(t))
    }
  })
}

/// The notice of motion: the frontmatter gives its address line and its paragraphs (hearing, grounds, conference).
#let notice-page(meta) = {
  let pieces = ()
  if "notice_to" in meta { pieces.push(block(inl(meta.notice_to))) }
  pieces += need(meta, "notice").map(p => body-par(inl(p)))
  with-signature(pieces, signature-block(meta))
}

#let certificate(meta) = {
  title-heading[Certificate of Compliance]
  with-signature((body-par[The undersigned, counsel of record for #inl(need(meta, "certificate_party")), certifies that this brief contains #need(meta, "word_count") words, which complies with the word limit of L.R. 11-6.1.],), signature-block(meta))
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
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  show: xengine.with(pitch: pitch, list-indent: none)
  set block(above: 0pt, below: 0pt, width: 100%)
  set heading(numbering: heading-num)

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      [#it.body#metadata(key)<toa-hit>]
    } else {
      it
    }
  }

  // Headings at the body pitch, bold: level 1 centered capitals; the others with the label in a box, the lines
  // after the first hanging after it, each level half an inch further in.
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    if it.level == 1 {
      block(sticky: true, align(center, text(size: type-size, weight: "bold", upper(it.body))))
    } else {
      let ind = label-indent(it.level)
      block(sticky: true, text(size: type-size, weight: "bold",
        par(hanging-indent: ind + heading-tab, first-line-indent: 0pt, { h(ind); box(width: heading-tab, lab); it.body })))
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
    with-signature(memo-pieces(md), signature-block(meta))
    pagebreak()
    certificate(meta)
  })
}
