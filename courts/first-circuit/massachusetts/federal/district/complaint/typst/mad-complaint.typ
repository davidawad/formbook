// U.S. District Court, District of Massachusetts: complaint (Fed. R. Civ. P. 8 and 10; D. Mass. L.R. 3.1, 5.1).
// Requirement IDs (MAD-...) and the rule text are in ../README.md and ../../rules.md. Content-agnostic: every
// case-specific word comes from the sample's frontmatter or markdown body, never from this file. The markdown body is
// rendered by cmarker. No forced line breaks, no coordinates measured off the exemplar.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // MAD-FORM-002: L.R. 5.1 sets no typeface; Times New Roman substitute per docs/FONTS.md, vendored in fonts/
#let type-size = 12pt                // MAD-FORM-004: L.R. 5.1 sets no size; 12 pt, the size of the filed exemplars
#let page-margin = 1in               // MAD-FORM-004: no rule (L.R. 5.1(a)(2) sets paper size only); 1 inch as filed
#let para-indent = 0.5in             // first-line indent of numbered paragraphs; the number's box after it (exemplar: "1." at 0.5 in, text at 1 in)
#let item-indent = 0.5in             // the prayer's lettered items: the label stands half an inch in
#let item-label = 0.4in              // the label's box; the item text hangs after it
#let quote-indent = 0.5in            // quotations, indented on both sides
#let caption-left = 3.25in           // width of the party column of the caption (its rule included)
#let caption-gutter = 0.25in         // between the party column and the case number
#let caption-inset = 10pt            // the party column's text stops this far from its rules
#let caption-right-inset = 0.1in     // the case number column starts this far after the gutter
#let caption-rule = 0.75pt           // the rule on the right and below the party column
#let designation-indent = 1.25in     // "Plaintiff," / "Defendant." in the party column
#let vs-indent = 0.5in               // "v." in the party column
#let sig-indent = 3.0in              // left edge of the signature block

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt             // MAD-FORM-001: double-spaced text (L.R. 5.1(a)(2)), twice the type size
#let pitch-single = 13.8pt           // caption, quotations, counsel: single-spaced (exempt under L.R. 5.1(a)(2)), 1.15 x the type size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mad-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, *et seq*, smart quotes) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

// ---------------------------------------------------------------------------
// Caption (MAD-CAP-001..003: court name, title, civil action number)
// ---------------------------------------------------------------------------

#let court-title() = {
  for l in ("UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF MASSACHUSETTS") {
    line-block(align(center, text(weight: "bold", l)))
  }
}

/// The party column, closed by a rule on its right and below (each party's names, its designation a single line
/// lower and indented, "v." between the parties, a single line off each side); the civil action number and the
/// title of the paper in bold to its right.
#let caption(meta) = {
  let left = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { left.push(line-block(above: pitch-single, indent: vs-indent, inl("v."))) }
    for (j, n) in p.names.enumerate() {
      left.push(line-block(above: if j == 0 and k > 0 { pitch-single } else { 0pt }, inl(n)))
    }
    left.push(line-block(above: pitch-single, indent: designation-indent, inl(p.designation)))
  }
  block(above: pitch-double, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: caption-left, stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-inset, bottom: caption-inset), left.join()),
    pad(left: caption-right-inset, {
      line-block[Civil Action No. #meta.case_number]
      line-block(above: pitch-double, text(weight: "bold", inl(meta.title)))
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs (Fed. R. Civ. P. 10(b)), quotations, prayer
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: numbered (the number in a box after the first-line indent), or not.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: para-indent, [#num.])#content])
})

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is a paragraph is one numbered paragraph.
/// Headings, quotations (a `>` chunk), lists (the prayer, lettered A., B., ...) and any chunk beginning WHEREFORE
/// are not numbered. Numbering is applied per chunk, not with a `show par` rule (which recurses without end).
#let allegations(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // The prayer, lettered A., B., ...: the label half an inch in, the text hanging after it; double-spaced.
      pad(left: item-indent, md(t))
    } else if t.starts-with(">") {
      // A quotation: unnumbered, single-spaced (L.R. 5.1(a)(2) exempts quotations), indented on both sides, a
      // single line off the text above and below.
      let q = t.split("\n").map(l => l.trim().trim(">", at: start).trim()).join("\n")
      block(width: 100%, above: pitch-single, below: pitch-single, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        pad(left: quote-indent, right: quote-indent, md(q))
      })
    } else if t.starts-with("WHEREFORE") {
      // The prayer lead-in: an unnumbered paragraph, indented like a numbered one.
      body-par(none, md(t))
    } else {
      n += 1
      body-par(n, md(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Jury demand, signature
// ---------------------------------------------------------------------------

/// The signature block (MAD-SIG-001: the board of bar overseers number under each attorney's name, L.R.
/// 5.1(a)(1)): the party lines, the /s/ line, each attorney, the firm, a single line apart, at the signature indent;
/// then the date at the margin. It never breaks across a page.
#let signature(meta) = {
  let sig = meta.signature
  let group(lines, above) = for (i, l) in lines.enumerate() {
    line-block(above: if i == 0 { above } else { 0pt }, indent: sig-indent, inl(l))
  }
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
    group(sig.party, 0pt)
    group(("/s/ " + sig.signer,), pitch-single)
    for a in sig.attorneys { group((a.name + " (BBO# " + a.bbo + ")", a.email), pitch-single) }
    group(sig.firm, pitch-single)
    line-block(above: pitch-double)[Dated: #meta.date]
  })
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let mad-complaint(meta, body) = {
  // Page numbers centered (MAD-FORM-005), at the type size, in a single-spaced line box.
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (MAD-FORM-001: double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: item-label)
  // A doubled sign stays with its number ("§§ 1331"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set enum(numbering: "A.")

  // Headings at the type size and the body pitch, no space of their own: level 1 centered bold capitals, level 2
  // centered bold, level 3 bold at the left, hanging. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { par(first-line-indent: 0pt, hanging-indent: para-indent, text(weight: "bold", it.body)) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, { set par(first-line-indent: 0pt); b })
  }

  court-title()
  caption(meta)
  if "lead_in" in meta {
    block(above: pitch-double, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), inl(meta.lead_in)))
  }
  allegations(body)
  if "jury_demand" in meta {
    block(above: pitch-single, below: 0pt,
      par(first-line-indent: (amount: para-indent, all: true), text(weight: "bold", inl(meta.jury_demand))))
  }
  signature(meta)
}
