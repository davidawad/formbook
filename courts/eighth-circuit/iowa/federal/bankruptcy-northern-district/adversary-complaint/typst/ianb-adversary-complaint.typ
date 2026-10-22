// Adversary complaint, United States Bankruptcy Court, N.D. Iowa.
// Governing rules and the reading of each: ../README.md. Entry point: main.typ.
// The markdown body (usage/<id>.md) is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (fields listed in ../README.md).
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // vendored in fonts/. No N.D. Iowa rule names a font (README, gap 1).
#let type-size = 12pt              // no rule sets a size; 12 pt is the convention of the filed exemplars (README, gap 2).
#let para-indent = 0.5in           // first-line indent of every body paragraph
#let num-box = 24pt                // a paragraph number, then the text at 0.5 in + 24 pt (Word: a tab stop at 1200 twips)
#let label-box = 0.5in             // a prayer item's letter; its text hangs at 1 in
#let page-margin = 1in
#let text-width = 8.5in - 2 * page-margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ianb-adversary-complaint.lua sets the same twips).
#let pitch-body = 24pt             // body double spaced (README, gap 3)
#let pitch-single = 13.8pt         // caption and signature block
#let pitch-footer = 12pt           // the 10 pt page footer
#let plain-below = 7.2pt           // an unnumbered paragraph's space below it
#let item-below = 7.2pt            // a prayer item's space below it
#let heading-above = 12pt
#let heading-below = 8.4pt
#let court-below = 18pt            // caption: court name to the party block
#let caption-below = 14.4pt        // caption: party block to the text
#let party-col = 3.3in             // caption: the party block, ruled right and below
#let party-inset = 12pt            // caption: the party block's text stands off the vertical rule
#let party-pad = 10pt              // caption: the bottom rule stands off the last line
#let name-indent = 0.5in           // caption: the names, indented under "In re:"
#let case-inset = 16pt             // caption: the case numbers stand off the vertical rule
#let case-top = 2 * pitch-single   // caption: the case numbers start two lines down (on the party block's lines)
#let sig-above = 21.6pt            // signature block: space above
#let sig-left = 2.6in              // signature block: the column, 3.9 in at the right margin
#let sig-gap = 28.8pt              // signature block: room for the signature under "Respectfully submitted,"
#let role-gap = 12pt               // signature block: space above the role line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("(?s)^---\n(.*?)\n---\n"))
  assert(m != none, message: "sample needs YAML frontmatter")
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  assert(key in meta, message: "frontmatter field missing: " + key)
  meta.at(key)
}

/// One block (a paragraph of its own), with an explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, body)

/// A line block indented by `left` (the block carries the space; pad would swallow it).
#let indented(left, above: 0pt, below: 0pt, body) = line-block(above: above, below: below, pad(left: left, body))

// ---------------------------------------------------------------------------
// Caption: court name, then party block on the left and case numbers and title on the right
// (FRBP 7010 and 9004(b); the form follows the exemplars). Both columns on one line grid.
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set text(..edges(pitch-single))
  line-block(align(center, text(weight: "bold")[IN THE UNITED STATES BANKRUPTCY COURT]))
  line-block(below: court-below, align(center, text(weight: "bold")[FOR THE NORTHERN DISTRICT OF IOWA]))
  let left = {
    line-block[In re:]
    indented(name-indent, above: pitch-single, inl(need(meta, "debtor")))
    line-block(above: pitch-single, align(right)[Debtor.])
    indented(name-indent, above: pitch-single, inl(need(meta, "plaintiff")))
    line-block(above: pitch-single, align(right)[Plaintiff,])
    indented(name-indent, above: pitch-single)[v.]
    indented(name-indent, above: pitch-single, inl(need(meta, "defendant")))
    line-block(above: pitch-single, align(right)[Defendant.])
  }
  let right = {
    line-block(inl(need(meta, "chapter")))
    line-block(inl(need(meta, "case_no")))
    line-block(above: pitch-single, inl(meta.at("adversary_no", default: "Adversary Case No. ____________")))
    line-block(above: pitch-single, text(weight: "bold", inl(need(meta, "title"))))
  }
  block(above: 0pt, below: 0pt, grid(
    columns: (party-col, 1fr),
    block(width: 100%, inset: (right: party-inset, bottom: party-pad), stroke: (right: 0.75pt, bottom: 0.75pt), left),
    block(width: 100%, inset: (left: case-inset, top: case-top), right),
  ))
  // the space under the caption as a block of its own (Word: an empty paragraph of that height)
  block(above: 0pt, below: 0pt, height: caption-below, width: 100%)
}

/// Section heading: centered bold, kept with what follows.
#let heading-block(t) = block(sticky: true, width: 100%, above: heading-above, below: heading-below,
  align(center, text(weight: "bold", inl(t))))

/// Body paragraph with the half-inch first-line indent.
#let body-para(below: 0pt, body) = block(width: 100%, above: 0pt, below: below,
  par(first-line-indent: (amount: para-indent, all: true), body))

/// Numbered allegation (FRCP 10(b)): the template numbers every body paragraph; the sample does not type the number.
#let numbered-para(n, c) = body-para[#box(width: num-box)[#n.]#inl(c)]

#let plain-para(c) = body-para(below: plain-below, inl(c))

/// Items of a markdown ordered list, one string per item (continuation lines are joined).
#let list-items(c) = {
  let out = ()
  for line in c.split("\n") {
    let m = line.match(regex("^\\s*\\d+\\.\\s+(.*)$"))
    if m != none {
      out.push(m.captures.at(0))
    } else if out.len() > 0 {
      let k = out.len() - 1
      out.at(k) = out.at(k) + " " + line.trim()
    }
  }
  out
}

/// Prayer items: lettered (a), (b), ... by the template; the text hangs at para-indent + label-box.
#let lettered-list(c) = {
  for (i, it) in list-items(c).enumerate() {
    block(width: 100%, above: 0pt, below: item-below, par(
      first-line-indent: (amount: para-indent, all: true),
      hanging-indent: para-indent + label-box,
      [#box(width: label-box)[(#numbering("a", i + 1))]#inl(it)],
    ))
  }
}

/// Body chunks are blank-line separated. A `#` or `##` chunk is a centered bold heading.
/// A numbered-list chunk is lettered. Other paragraphs are numbered, except those before
/// the first heading and those starting with COMES NOW or WHEREFORE (unnumbered by rule).
#let render-body(md) = {
  let front = true
  let n = 0
  for c in md.split("\n\n").map(x => x.trim()).filter(x => x != "") {
    if c.starts-with("## ") {
      front = false
      heading-block(c.slice(3))
    } else if c.starts-with("# ") {
      front = false
      heading-block(c.slice(2))
    } else if c.match(regex("^\\d+\\. ")) != none {
      lettered-list(c)
    } else if front or c.starts-with("COMES NOW") or c.starts-with("WHEREFORE") {
      plain-para(c)
    } else {
      n += 1
      numbered-para(n, c)
    }
  }
}

/// Signature block (FRBP 9011; N.D. Iowa L.R. 9010-1(b): business address, telephone,
/// e-mail and FAX below the signature). The date at the margin, the signature in a column at sig-left.
#let signature(meta) = {
  let s = need(meta, "signature")
  set text(..edges(pitch-single))
  block(breakable: false, above: sig-above, below: 0pt, {
    line-block[#box(width: sig-left)[Dated: #s.date]Respectfully submitted,]
    indented(sig-left, above: sig-gap, text(style: "italic")[/s/ #s.signer])
    indented(sig-left)[#s.signer, #s.bar]
    for l in s.address { indented(sig-left)[#l] }
    indented(sig-left)[#s.firm]
    indented(sig-left)[Telephone: #s.phone]
    indented(sig-left)[Fax: #s.fax]
    indented(sig-left)[E-mail: #s.email]
    indented(sig-left, above: role-gap)[#s.role]
  })
}

#let complaint(meta, md) = {
  // FRBP 7008(a): the complaint must say whether the pleader consents to final orders.
  assert(md.contains("consent"), message: "FRBP 7008(a): the complaint must state whether the pleader consents to final orders or judgment by the bankruptcy court")
  assert(not md.contains("[^"), message: "footnotes are not supported in the adversary complaint template")
  set page(
    paper: "us-letter",
    margin: (top: page-margin + 4pt, bottom: page-margin, left: page-margin, right: page-margin),
    footer-descent: 30%,
    footer: context align(center, text(size: 10pt, ..edges(pitch-footer))[
      Page #counter(page).display() of #counter(page).final().first()
    ]),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. The template writes its own numbered and lettered paragraphs (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  caption(meta)
  render-body(md)
  signature(meta)
}
