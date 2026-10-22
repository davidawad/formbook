// U.S. District Court, District of Puerto Rico: complaint (Fed. R. Civ. P. 8 and 10; the form rules of
// D.P.R. Local Civil Rule 7 as quoted in ../README.md). Rule-driven and content-agnostic: every
// case-specific word comes from the sample's frontmatter, never from this file. The markdown body is
// rendered by cmarker; the metadata comes from the YAML frontmatter of the same sample file.
// Requirement IDs (PRD-...) in ../README.md say what each parameter below traces to.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")       // PRD-FORM-002: proportional font; Times New Roman substitute per docs/FONTS.md, vendored in /fonts (see ../README.md)
#let type-size = 12pt                  // PRD-FORM-002: 12 point or larger for a proportional font (L.Civ.R. 7)
#let page-margin = 1in                 // PRD-FORM-004: margins are not stated in the rule text read; 1 inch as in the exemplar (README)
#let para-indent = 0.5in               // first-line indent of the lead-in and of every paragraph; a paragraph number stands here
#let number-box = 0.5in                // the paragraph number's box: the text starts an inch in, as in the exemplar
#let item-indent = 0.5in               // prayer items: the letter half an inch in, the text a box after it
#let court-title = ("UNITED STATES DISTRICT COURT", "DISTRICT OF PUERTO RICO")  // PRD-CAP-001: the court's name, the same for every case
#let caption-left = 3.4in              // width of the party column of the caption
#let caption-inset = 10pt              // the party text stands off the caption's right rule
#let caption-gutter = 0.35in           // the case number column starts this far right of the rule
#let designation-indent = 1.4in        // a party's designation ("Plaintiffs,") set in from its names
#let sig-column = 3.2in                // the signature column, at the right margin; the date stands left of it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt               // PRD-FORM-003: double spacing (L.Civ.R. 7), the exemplar's 24 pt pitch
#let pitch-single = 13.8pt             // caption, signature block, footer: single-spaced (L.Civ.R. 7), 1.15 x the type size
#let half-gap = 12pt                   // the space between caption items and between the counsel groups
#let caption-pad = 12pt                // the caption's bottom rule stands this far below the last party line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("prd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, § signs and the like).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

#let need(meta, key) = {
  if key not in meta { panic("prd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Headings (PRD-CONT-001): centred capitals for sections, bold for sub-headings, bold italic below; at the body size
// and pitch, with no space of their own (the double pitch sets them off). Sticky: a heading never ends a page.
// ---------------------------------------------------------------------------

#let heading-rule(it) = {
  set text(size: type-size)
  set par(first-line-indent: 0pt)
  let b = if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 {
    strong(it.body)
  } else { strong(emph(it.body)) }
  block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
}

// ---------------------------------------------------------------------------
// Caption (PRD-CAP-002): parties on the left with a rule on their right and bottom, the case number and the
// title of the paper on the right. No line numbers and no pleading rules: D.P.R. papers are not pleading paper.
// ---------------------------------------------------------------------------

#let caption(meta) = block(above: pitch-double, below: 0pt, grid(
  columns: (caption-left, 1fr),
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation set in from the names a line below; "v." between the parties.
    let sides = need(meta, "caption")
    for (i, side) in sides.enumerate() {
      if i > 0 { line-block(above: half-gap, [v.]) }
      for (j, n) in side.names.enumerate() { line-block(above: if i > 0 and j == 0 { half-gap } else { 0pt }, inl(n)) }
      line-block(above: pitch-single, pad(left: designation-indent, inl(side.designation)))
    }
  }),
  pad(left: caption-gutter, {
    line-block[No. #need(meta, "case_number")]
    line-block(above: half-gap, strong(upper(inl(need(meta, "brief_title")))))
    if "jury_demand" in meta and meta.jury_demand { line-block(above: half-gap, strong[JURY TRIAL DEMANDED]) }
  }),
))

#let cover(meta) = {
  for l in court-title { line-block(align(center, strong(l))) }
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one numbered
// allegation (Fed. R. Civ. P. 10(b)). Headings and lists are not numbered; the prayer's lead-in ("WHEREFORE")
// is an indented paragraph without a number.
// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content
// recurses without end in typst 0.15.
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number in a box after the
/// first-line indent, the text after it.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: number-box, [#num.])#content])
})

#let allegations(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with("WHEREFORE") {
      body-par(none, md(t))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list is not an allegation: the prayer's items, lettered A., B., ...
      pad(left: item-indent, md(t))
    } else {
      n += 1
      body-par(n, md(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (PRD-SIG-001): the date, then each signing counsel group. A group with a `signer` gets
// the "By: s/" line; a group without one is counsel of record listed under the signature. The block never
// breaks across a page.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (1fr, sig-column),
    line-block[Dated: #need(meta, "date")],
    {
      line-block[Respectfully submitted,]
      for g in sig.groups {
        let lines = g.at("lines", default: ()).map(inl)
        if "signer" in g { lines = ([By: s/ #g.signer], [#g.signer]) + lines }
        for (j, l) in lines.enumerate() { line-block(above: if j == 0 { half-gap } else { 0pt }, l) }
      }
    },
  ))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let prd-complaint(meta, body) = {
  for k in ("case_number", "caption", "brief_title", "date", "signature") {
    let _ = need(meta, k)
  }

  // PRD-FORM-005: the page number at bottom centre, "-N-", at the type size, in a single-spaced line box (Word's
  // footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display("-1-"))),
  )
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"), author: "")
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch; prayer items as a label box (item-indent) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-indent)
  // A doubled sign stays with its number ("§§ 1983"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  show heading: heading-rule
  // Prayer items are lettered (A., B., ...); the markdown list numbers 1., 2., ... and the enum shows letters.
  set enum(numbering: "A.")

  cover(meta)
  if "lead_in" in meta {
    block(above: pitch-double, below: 0pt, body-par(none, inl(meta.lead_in)))
  }
  allegations(body)
  signature-block(meta)
}
