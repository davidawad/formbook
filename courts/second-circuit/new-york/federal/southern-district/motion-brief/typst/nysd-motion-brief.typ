// U.S. District Court, Southern District of New York: memorandum of law in support of a motion (Fed. R.
// Civ. P. 12(b)). Cover, table of contents, table of authorities, body, signature block, certificate of
// compliance.
//
// Rule-driven and content-agnostic. Requirement IDs (NYSD-...) refer to ../README.md, which quotes the
// rules: S.D.N.Y. Joint Local Civil Rules (Jan. 2, 2026) 7.1(a)(2) (memorandum, headings), 7.1(b)
// (typeface, margins, spacing for all papers), 7.1(c) (length and word-count certificate). No case-specific
// text, no coordinates measured off the exemplar, no forced line breaks. The body is markdown rendered by
// cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // NYSD-FORM-002: the joint rules name no typeface; Times New Roman, the house standard (and the exemplar judge's practice). Vendored in /fonts.
#let type-size = 12pt                    // NYSD-FORM-002: 12-point type or larger, footnotes included (Local Civ. R. 7.1(b)(1) allows 10 pt footnotes; this uses 12).
#let margin = 1in                        // NYSD-FORM-004: at least one-inch margins on all sides (Local Civ. R. 7.1(b)(2)).
#let para-indent = 0.5in
#let heading-tab = 0.5in                 // a heading's label box; each deeper level half an inch further in
#let quote-inset = 0.5in                 // block quotations stand in this far on both sides (Word: Block Text)
#let caption-inset = 0.2in               // the caption's text stands off the rule between its columns,
#let caption-pad = 12pt                  // and the party column's last line this far above its bottom rule.
#let designation-indent = 1.8in          // a party's designation under its names
#let text-width = 8.5in - 2 * margin
#let sig-column = 3.2in                  // the signature column, at the right
#let page-col = 0.5in                    // contents and authorities: the page column the rows wrap before
#let toa-hang = 0.35in                   // an authority's second line hangs this far in
#let row-above = 6pt                     // contents and authorities: the space above each row
#let note-gap = 7pt                      // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt              // from the text to the footnote rule: with note-gap, the space LibreOffice keeps above its separator
#let passim-threshold = 7                // an authority on this many pages or more is listed as "passim"

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/motion-brief.lua sets the same twips).
#let pitch-double = 24pt                 // NYSD-FORM-003: double-spaced (Local Civ. R. 7.1(b)(3)).
#let pitch-single = 13.8pt               // single spacing, 1.15 x the size: counsel block, caption, headings, block
                                         // quotations, footnotes, table rows, signature block, page number.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nysd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nysd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above it. An empty line keeps its
/// height.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, if type(body) == str { inl(body) } else { body })
})

/// A centred bold title on the body pitch.
#let title-line(s, above: 0pt, below: 0pt) = block(width: 100%, above: above, below: below, sticky: true,
  align(center, par(first-line-indent: 0pt, strong(s))))

// ---------------------------------------------------------------------------
// Headings: numbering and styles (the memorandum's headings, NYSD-CONT-001)
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
// Tables of contents and authorities (Local Civ. R. 7.1(c): the tables are excluded from the word limit)
// ---------------------------------------------------------------------------

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// A table's title (a page of its own), a double line below it the column label at the right.
#let table-head(title, col) = {
  title-line(upper(title), below: pitch-double)
  line-block(align(right, strong(col)))
}

#let toc-section() = {
  table-head[Table of Contents][Page]
  context {
    set text(..edges(pitch-single))
    for hd in query(heading.where(outlined: true)) {
      if hd.level > 4 { continue }
      let nums = counter(heading).at(hd.location()).slice(0, hd.level)
      let lab = heading-num(..nums)
      let ind = label-indent(hd.level)
      let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
      listing-row(hd.location(), [#h(ind)#if lab != "" { box(width: heading-tab, lab) }#title],
        page-label(hd.location()), page-col, if lab != "" { ind + heading-tab } else { 0pt }, row-above)
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
  table-head[Table of Authorities][Page(s)]
  context {
    set text(..edges(pitch-single))
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("nysd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(width: 100%, above: pitch-single, below: 0pt, sticky: true, par(first-line-indent: 0pt, strong(title)))
      for (key, a) in members {
        // Distinct printed page labels, in document order (the page a citation starts on).
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let name = if "name" in a { [#if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }, ] }
        listing-row(none, [#name#inl(a.cite)], page-text, page-col, toa-hang, row-above)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover: counsel block, court title, caption, title of the paper (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

/// The caption: the parties on the left (closed by a rule on the right and bottom), the legends, file number, judge
/// and the title of the paper on the right. Never split.
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    for (i, side) in sides.enumerate() {
      if i > 0 {
        line-block("")
        line-block(align(center)[v.])
        line-block("")
      }
      for n in side.names { line-block(n) }
      line-block(indent: designation-indent, side.designation)
    }
  }
  let right = {
    for l in meta.at("legends", default: ()) { line-block(l) }
    line-block("")
    line-block[#meta.at("file-label", default: "No.") #need(meta, "case_number")]
    if "judge" in meta { line-block(meta.judge) }
    line-block("")
    line-block(strong(upper(inl(need(meta, "title")))))
  }
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (1fr, 1fr),
    block(width: 100%, inset: (right: caption-inset, bottom: caption-pad), stroke: (right: 0.75pt, bottom: 0.75pt),
      left),
    pad(left: caption-inset, right),
  ))
}

/// The counsel block at the upper left, a double line below it the court title, a double line below that the caption.
#let cover(meta) = {
  for l in need(meta, "counsel") { line-block(l) }
  for (i, l) in need(meta, "court").enumerate() {
    line-block(above: if i == 0 { pitch-double } else { 0pt }, align(center, strong(upper(inl(l)))))
  }
  caption-table(meta)
}

// ---------------------------------------------------------------------------
// Signature block and certificate of compliance (Local Civ. R. 7.1(c))
// ---------------------------------------------------------------------------

/// The place and date at the left; in the signature column "Respectfully submitted,", a double line below it the
/// firm, a single line below that the signer's s/ and name and lines. Never split.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (text-width - sig-column, sig-column),
    {
      line-block[Dated: #inl(meta.at("place", default: "New York, New York"))]
      line-block(need(meta, "date"))
    },
    {
      line-block[Respectfully submitted,]
      let firm = sig.at("firm", default: ())
      for (i, l) in firm.enumerate() { line-block(above: if i == 0 { pitch-double } else { 0pt }, strong(inl(l))) }
      line-block(above: if firm.len() > 0 { pitch-single } else { pitch-double })[s/ #inl(sig.signer)]
      line-block(sig.signer)
      for l in sig.at("lines", default: ()) { line-block(l) }
    },
  ))
}

/// Certificate of compliance: the word count is the one in the frontmatter, the typeface and margins come from this
/// template's own parameters (not typed in by hand). Its own page.
#let certificate(meta) = {
  let count = need(meta, "word_count")
  title-line[CERTIFICATE OF COMPLIANCE]
  let para(body) = block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), body))
  para[1\. This memorandum complies with the word-count limit of Local Civil Rule 7.1(c) because it contains #count words, excluding the caption, table of contents, table of authorities, signature block and this certificate, as counted by the word-processing program used to prepare it.]
  para[2\. This memorandum complies with the formatting requirements of Local Civil Rule 7.1(b) because it is printed in #font-family.first(), #(type-size / 1pt)-point type, with one-inch margins on all sides, and is double-spaced except for headings, footnotes and block quotations.]
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (text-width - sig-column, sig-column),
    {
      line-block[Dated: #inl(meta.at("place", default: "New York, New York"))]
      line-block(need(meta, "date"))
    },
    {
      line-block[Respectfully submitted,]
      line-block(above: pitch-double)[s/ #inl(need(meta, "signature").signer)]
    },
  ))
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let running-footer = context {
  let n = here().page-numbering()
  if n != none { align(center, text(..edges(pitch-single), numbering(n, ..counter(page).get()))) }
}

#let nysd-motion-brief(meta, md) = {
  for k in ("court", "case_number", "caption", "title", "counsel", "signature", "date", "word_count") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // The page number centered at the foot, in a single line box, where Word's footer sets it.
  set page(paper: "us-letter", margin: margin, footer-descent: 30%, footer: running-footer)
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number; bullets in a half-inch box.
  show: xengine.with(pitch: pitch-double)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  // Footnotes at the text size (NYSD-FORM-002), single lines, under a 30 % rule, 7 pt between notes; the mark and a
  // space before the text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Authority links: a link whose target is `toa:KEY` is recorded on the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#metadata(it.dest.slice(4))<toa-hit>#it.body]
    } else {
      it
    }
  }

  // Headings single-spaced at the type size (Local Civ. R. 7.1(b)(3) allows it), bold, a single line above and below,
  // kept with the block after them: level 1 centred capitals; deeper levels the label in a box half an inch wide
  // (each level half an inch further in), the title hanging after it.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))
    let body = if it.level == 1 { align(center, par(first-line-indent: 0pt, strong(upper(it.body)))) } else {
      let ind = label-indent(it.level)
      let lab = context numbering(it.numbering, ..counter(heading).at(it.location()).slice(0, it.level))
      pad(left: ind, par(first-line-indent: 0pt, hanging-indent: heading-tab,
        strong[#box(width: heading-tab, lab)#it.body]))
    }
    block(width: 100%, above: pitch-single, below: pitch-single, sticky: true, body)
  }

  // Block quotations: single-spaced, half an inch in on both sides, a single line above and below (NYSD-FORM-003).
  show quote.where(block: true): it => block(width: 100%, above: pitch-single, below: pitch-single, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: quote-inset, it.body)
  })

  // ---- cover (no page number) ----
  page(numbering: none, cover(meta))

  // ---- contents and authorities, numbered i, ii, ... ----
  set page(numbering: "i")
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)

  // ---- body, numbered from 1 ----
  set page(numbering: "1")
  counter(page).update(1)
  // The last paragraph (and the headings right before it) stays whole with the signature block. Footnote definitions
  // are read with both parts, so a mark in either finds its note.
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = chunks.filter(c => c.starts-with("[^"))
  let cs = chunks.filter(c => not c.starts-with("[^"))
  let k = cs.len() - 1
  while k > 0 and cs.at(k - 1).starts-with("#") { k -= 1 }
  let render(xs) = cmarker.render((xs + defs).join("\n\n"), raw-typst: false, smart-punctuation: true)
  render(cs.slice(0, k))
  // (a heading that opens the block keeps its single line above: the first child of a block has none of its own)
  block(width: 100%, above: if k < cs.len() - 1 { pitch-single } else { 0pt }, below: 0pt, sticky: true,
    breakable: false, [#render(cs.slice(k))#parbreak()])
  signature-block(meta)

  // ---- certificate of compliance (its own page, no number) ----
  set page(numbering: none)
  certificate(meta)
}
