// Memorandum in support of a motion for the U.S. District Court for the Northern District of Alabama (alnd):
// the brief that accompanies a Rule 12(b) motion, with a table of contents and a table of authorities.
// Rules: Fed. R. Civ. P. 7(b) (motions state the grounds with particularity), 10(a) (caption), 11(a) (signature);
// Local Rule 5.5 (electronic filing). The local rules of the court (rev. Dec. 4, 2019) set no typeface, margin,
// spacing or length rule for briefs; a judge's standing order may (see ../README.md). Layout follows the filed
// exemplar where the rules leave it open.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a stated layout choice in ../README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // no ALND typeface rule; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // 12 pt, the exemplar's size (no ALND rule sets one)
#let margins = (top: 1in, bottom: 1in, x: 1in)
#let para-indent = 0.5in                // first-line indent of body paragraphs; block quotations indented both sides
#let heading-tab = 0.5in                // a numbered heading's label box; each deeper level steps in by it
#let caption-inset = 14pt               // the caption's text stands off its rule
#let designation-indent = 1.8in         // a party's designation ("PLAINTIFF,") set in from its names
#let title-inset = 35.1pt               // the cover title: centered in the middle 85 % of the line
#let sig-gutter = 0.3in                 // between the firms' signature columns
#let cert-sig-width = 3.2in             // the certificate's signature, at the right margin
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 72pt                // authorities: the page lists keep the last inch
#let toa-hang = 0.35in                  // authorities: the wrapped lines of an entry
#let passim-threshold = 7               // authority cited on this many pages or more: "passim"

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 24pt                // double spacing, the exemplar's 24 pt pitch (no ALND rule states it)
#let caption-pad = pitch-single / 2     // caption: the bottom rule stands half a line below the last party line
#let row-gap = 6pt                      // between the rows of the contents and the authorities
#let group-gap = 12pt                   // above an authorities group heading, and below the tables' titles

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("alnd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above it; an empty one is a blank
/// line of the single pitch.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if body == [] or body == "" { block(height: pitch-single) } else { body }
})

// ---------------------------------------------------------------------------
// Headings: numbering (level 1 is unnumbered)
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

/// The printed page label of a location.
#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

/// A table's title (centered, bold) and the label of its page column at the right.
#let table-head(title, col) = {
  line-block(align(center, strong(title)))
  line-block(above: group-gap, align(right, strong(col)))
}

/// One contents row: the label in its box at the heading's indent, the title hanging after it.
#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = if hd.numbering == none { "" } else { heading-num(..nums) }
  let ind = label-indent(hd.level)
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  listing-row(hd.location(), { h(ind); if lab != "" { box(width: heading-tab, lab) }; title },
    page-label(hd.location()), toc-page-col, ind + heading-tab, row-gap)
}

#let toc-section() = {
  table-head("TABLE OF CONTENTS", "Page")
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

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  table-head("TABLE OF AUTHORITIES", "Page(s)")
  context {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("alnd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(sticky: true, width: 100%, above: group-gap, below: 0pt, strong(title))
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
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = for l in need(meta, "court") { line-block(align(center, strong(inl(l)))) }

#let caption-table(meta) = block(above: pitch-double, below: 0pt, grid(
  columns: (1fr, 1fr),
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation set in from the names; "v." between the parties.
    for (i, side) in need(meta, "caption").enumerate() {
      if i > 0 { line-block(align(center, [v.])) }
      for n in side.names { line-block(inl(n)) }
      line-block(pad(left: designation-indent, inl(side.designation)))
    }
  }),
  pad(left: caption-inset, line-block[#inl(need(meta, "case_label")) #inl(need(meta, "case_number"))]),
))

#let cover(meta) = {
  court-title(meta)
  caption-table(meta)
  block(width: 100%, above: pitch-double, below: 0pt, pad(x: title-inset, {
    set text(..edges(pitch-single))
    align(center, par(first-line-indent: 0pt, strong(upper(inl(need(meta, "brief_title"))))))
  }))
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

#let sig-lines(lines) = for l in lines { line-block(if l == "" { [] } else { inl(l) }) }

/// The date line, the firms side by side, the closing lines; the block never breaks across a page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
    line-block(inl(need(meta, "date_line")))
    block(above: pitch-double, below: 0pt, grid(
      columns: (1fr,) * sig.firms.len(),
      column-gutter: sig-gutter,
      ..sig.firms.map(lines => sig-lines(lines)),
    ))
    block(above: pitch-double, below: 0pt, sig-lines(sig.at("lines", default: ())))
  })
}

#let certificate(meta) = {
  let c = need(meta, "certificate")
  heading(level: 1, numbering: none, c.title)
  block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
    par(first-line-indent: (amount: para-indent, all: true), inl(c.text))
    align(right, block(width: cert-sig-width, above: pitch-double, below: 0pt, {
      set align(left)
      line-block(inl(c.date_line))
      line-block(above: pitch-double, [/s/ #inl(c.signer)])
      line-block(inl(c.signer))
    }))
  })
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let alnd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "case_label", "case_number", "brief_title", "signature", "date_line") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, numbering: none, footer: none)   // 8 1/2 x 11 inch
  set document(title: need(meta, "brief_title"))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (the exemplar's double spacing).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number ("§§ 157"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on (the mark before it).
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#metadata(it.dest.slice(4))<toa-hit>#it.body]
    } else {
      it
    }
  }

  // Headings single-spaced and bold, a single line above and below: level 1 centered in capitals, deeper levels
  // with their label in a box at the level's indent and the title hanging after it. Sticky: never ends a page.
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
    block(sticky: true, width: 100%, above: pitch-single, below: pitch-single, b)
  }
  // Block quotations: indented half an inch from both margins, no first-line indent.
  show quote.where(block: true): it => block(width: 100%, above: 0pt, below: 0pt,
    pad(x: para-indent, { set par(first-line-indent: 0pt); it.body }))

  cover(meta)

  // The page number: centered in a single-spaced line box (Word's footer). The cover is unnumbered; the tables are
  // numbered in lower-case roman; the body starts again at 1.
  set page(numbering: "i", footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)

  set page(numbering: "1")   // a new page, numbered from 1
  counter(page).update(1)
  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  if "certificate" in meta {
    pagebreak()
    certificate(meta)
  }
}
