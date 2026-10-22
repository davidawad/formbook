// U.S. Bankruptcy Court, Southern District of California (casb): motion with points and authorities
// (one filed document; the memorandum is combined with the motion, as the exemplar does).
//
// Rule-driven and content-agnostic. Requirement IDs (CASB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. Every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // CASB-FORM-002: vendored in fonts/; see README.md
#let type-size = 12pt                   // CASB-FORM-002: 12 point; the rule text is not verified, see README.md
#let lines-per-page = 27                // CASB-FORM-003: pleading paper, 28 numbered lines (exemplars)
#let page-w = 8.5in                     // CASB-FORM-001: 8 1/2 x 11 paper
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let number-width = 1in                 // the line numbers stand right-aligned in the first inch of the page
#let para-indent = 0.5in                // first-line indent of the motion's paragraphs
#let quote-indent = 0.5in               // a block quotation is set in this far on both sides (Admin. Proc. 2.5)
#let heading-tab = 0.5in                // the label column of a numbered heading
#let passim-threshold = 7               // an authority cited on this many pages or more is "passim"
#let counsel-lines = 7                  // the court title starts after at least this many numbered lines
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column's rule and the case column
#let caption-inset = 10pt               // the party text stands off the column's rule
#let right-inset = 0.1in                // the case column's text stands this far in
#let sig-left = 2.6in                   // the date column of the signature block
#let page-size = 10pt                   // the footer's page number
#let footer-size = 9pt                  // the footer's title and case number
#let footer-top = 4pt                   // the footer starts this far below the last numbered line
#let footer-gap = 2pt                   // between the footer's lines

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // CASB-FORM-003: double spacing; the numbered lines are this pitch
#let pitch-single = 12pt                // counsel, caption, headings, quotations, signature: single-spaced, exactly
                                        // half a numbered line
#let pitch-page = 11.5pt                // the footer's page number line, 1.15 x its size
#let pitch-footer = 10.4pt              // the footer's title and case number lines
#let half-gap = 12pt                    // between the caption's parts and the signature's groups
#let drop = 9.6pt                       // a single-spaced block starts this far into its numbered line, so that its first
                                        // line (and every second after it) stands on the line number's baseline
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer

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
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("casb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Whole numbered lines: a block of single lines starting `drop` into its first numbered line, rounded up to a
/// multiple of `pitch` (at least `min` lines), so whatever follows it stays on the grid of numbered lines. The Word
/// filter counts the same lines (docx/lib/lines.lua).
#let on-grid(min: 0, c) = context {
  let h = measure(width: text-width, c).height + drop
  block(width: 100%, height: calc.max(min, calc.ceil(h / pitch)) * pitch, inset: (top: drop), above: 0pt,
    below: 0pt, c)
}

// ---------------------------------------------------------------------------
// Page furniture (pleading paper, as in the exemplars)
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, on the baseline of its line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: number-width, height: pitch,
        align(right, text(size: type-size, ..edges(pitch), str(i)))))
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
  dy: top-margin + lines-per-page * pitch + footer-top,
  block(width: text-width, {
    set par(first-line-indent: 0pt)
    block(width: 100%, below: 0pt, align(center, text(size: page-size, ..edges(pitch-page), context {
      let pn = here().page-numbering()
      if pn != none { numbering(pn, ..counter(page).get()) }
    })))
    set text(size: footer-size, ..edges(pitch-footer))
    block(width: 100%, above: footer-gap, below: 0pt, align(center, upper(inl(need(meta, "footer_title")))))
    block(width: 100%, above: footer-gap, below: 0pt, align(center, [CASE NO. #need(meta, "case_number")]))
  }),
)

// ---------------------------------------------------------------------------
// Tables of contents and authorities (LBR 9013-7(d)(3); see README.md). The typst engine builds them; the Word
// filter does not (it stops on `toc: true`).
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

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(hanging-indent: indent, first-line-indent: 0pt, body)

/// One table-of-contents row from a heading element; wrapped lines hang under the title.
#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = heading-num(..nums)
  let ind = if hd.level == 1 { 0pt } else { (hd.level - 2) * heading-tab }
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  // The page number sits in its own column so a wrapped title can never push it onto a new line.
  link(hd.location(), block(width: 100%, above: half-gap, below: 0pt, grid(
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
  set text(..edges(pitch-single))
  align(right, block(above: half-gap, below: 0pt, strong[Page]))
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
  set text(..edges(pitch-single))
  align(right, block(above: half-gap, below: 0pt, strong[Page(s)]))
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("casb-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: pitch, below: 0pt, sticky: true, strong(title))
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        block(breakable: false, above: half-gap, below: 0pt, width: 100%, hang(0.35in, {
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

/// Counsel identification, upper left, from line 1. More counsel lines push the court title down.
#let counsel-block(meta) = on-grid(min: counsel-lines, for l in need(meta, "counsel") { line-block(inl(l)) })

#let court-title(meta) = {
  let lines = ("UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF CALIFORNIA")
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { block(width: 100%, above: 0pt, below: 0pt, align(center, strong(l))) }
}

/// A list of parties: each side's names, then its designation; "vs." between the sides.
#let party-lines(sides) = {
  let rows = ()
  for (k, p) in sides.enumerate() {
    if k > 0 { rows.push("vs.") }
    rows += p.names + (p.designation,)
  }
  rows
}

/// The caption, a numbered line below the court title, on whole numbered lines: the debtor ("In re"), then the
/// adversary parties, in a column ruled on the right and bottom; the case numbers, the title of the paper, a hearing
/// and the judge beside it.
#let caption(meta) = block(width: 100%, above: pitch, below: 0pt, on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: half-gap), {
    for l in ("In re",) + party-lines(need(meta, "in_re")) { line-block(inl(l)) }
    for (j, l) in party-lines(need(meta, "caption")).enumerate() {
      line-block(above: if j == 0 { half-gap } else { 0pt }, inl(l))
    }
  }),
  pad(left: right-inset, {
    line-block[Case No. #need(meta, "case_number")]
    line-block[Chapter #need(meta, "chapter")]
    if "adv_number" in meta { line-block(above: half-gap)[Adv. Proc. No. #meta.adv_number] }
    line-block(above: half-gap, strong(inl(need(meta, "brief_title"))))
    // A hearing, when one is set, follows the title (AP 2.3(a); see README.md).
    if "hearing" in meta {
      for (j, l) in meta.hearing.enumerate() { line-block(above: if j == 0 { half-gap } else { 0pt }, inl(l)) }
    }
    if "judge" in meta { line-block(above: half-gap, inl(meta.judge)) }
  }),
)))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

// The signature block, a numbered line below the text, is kept whole: it never splits across a page break. The
// space above it is an inset, kept at the top of a page as Word keeps the space above a table's first line.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: 0pt, below: 0pt, inset: (top: pitch + drop), grid(
    columns: (sig-left, 1fr),
    column-gutter: caption-gutter,
    line-block[Dated: #need(meta, "date")],
    {
      line-block[Respectfully submitted,]
      for (j, l) in sig.firm.enumerate() { line-block(above: if j == 0 { half-gap } else { 0pt }, inl(l)) }
      line-block(above: half-gap, [/s/ #sig.signer])
      for l in sig.at("lines", default: ()) { line-block(inl(l)) }
    },
  ))
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

/// Headings: level 1 a centered section in capitals, one numbered line; level 2 and below single-spaced and bold,
/// the label ("I.", "A.") in a box and the title hanging after it, rounded to whole numbered lines. Sticky: a heading
/// never ends a page.
#let heading-rule(it) = context {
  set text(size: type-size)
  set par(first-line-indent: 0pt)
  if it.level == 1 {
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, align(center, strong(upper(it.body))))
  } else {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    let ind = (it.level - 2) * heading-tab
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, on-grid({
      set text(..edges(pitch-single))
      par(hanging-indent: ind + heading-tab, [#h(ind)#box(width: heading-tab, lab)#strong(it.body)])
    }))
  }
}

/// The markdown body, one blank-line-separated chunk at a time: a heading; a quotation (single-spaced and indented,
/// Admin. Proc. 2.5), rounded to whole numbered lines; or a double-spaced paragraph with a first-line indent.
#let motion-body(src) = {
  let chunks = src.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      on-grid(pad(left: quote-indent, right: quote-indent, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        md(t.split(regex("\\r?\\n")).map(l => l.trim(">", at: start).trim()).join("\n"))
      }))
    } else {
      block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), md(t)))
    }
  }
}

#let casb-motion-brief(meta, src) = {
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
    footer: none,
  )
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the numbered-line pitch.
  show: xengine.with(pitch: pitch)
  // A doubled sign stays with its number ("§§ 523(a)(2)(A)"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set heading(numbering: heading-num)
  set footnote.entry(indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size, ..edges(pitch-single))
  show footnote.entry: set par(first-line-indent: 0pt, leading: 0pt)

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      [#it.body#metadata(key)<toa-hit>]
    } else {
      it
    }
  }
  show heading: heading-rule

  // The "TO:" line follows the caption; the body follows it. With a table of contents, the tables
  // come first (roman pages), then the body restarts at page 1.
  let body = {
    if "lead_in" in meta { block(width: 100%, above: 0pt, below: 0pt, inl(meta.lead_in)) }
    motion-body(src)
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
