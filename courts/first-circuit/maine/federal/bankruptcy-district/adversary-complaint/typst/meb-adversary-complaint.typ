// Adversary complaint for the U.S. Bankruptcy Court, District of Maine (meb).
// Rules: Fed. R. Bankr. P. 7001 (adversary proceeding), 7008 (jurisdiction, consent to final orders),
// 7010 (caption substantially conforms to Form 416; Fed. R. Civ. P. 10 applies, numbered paragraphs),
// 9004(a) (legible); D. Me. LBR 7003-1(a) (main case caption, party names, title, adversary number).
// See ../README.md for the rule text, dates verified and the open questions.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no D. Me. rule on typeface; Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (README.md, gap 2)
#let type-size = 12pt                   // legible, 12 point is the convention in the filed exemplar
#let margin = 1in                       // no D. Me. margin rule; the exemplar uses one inch on all sides
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let number-width = 0.5in               // the paragraph number's box after the indent: the text starts 1 in in
#let item-indent = 0.5in                // lettered items: the label half an inch in, the text hanging a box after it
#let item-label = 0.5in
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-inset = (top: 6pt, bottom: 10pt) // space inside each caption box above and below its lines
#let caption-gap-left = 10pt            // the party column's lines stop this far before its rule
#let caption-gap-right = 0.2in          // the case-number column's lines start this far after the rule
#let rule = 0.75pt                      // the caption's rules
#let sig-col = 3in                      // "/s/" and the signer's lines start this far in, "Dated:" at the margin
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF MAINE")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // the body, double-spaced (a 24 pt pitch at 12 pt, as the exemplar)
#let pitch-single = 13.8pt              // court name, caption, title, signature: 1.15 x the type size
#let heading-gap = 12pt                 // half a double line above and below a heading

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("meb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// A body paragraph at the double pitch, first line indented; numbered: the number in a box after the indent.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else [#box(width: number-width)[#num.]#content]))

// ---------------------------------------------------------------------------
// Cover: court name, caption, title of the paper (FRBP 7010; LBR 7003-1(a))
// ---------------------------------------------------------------------------

/// The caption: the main case (debtor, chapter, case number) and, below it, the adversary proceeding
/// (plaintiff(s), "v.", defendant(s), adversary number), each a pair of boxes closed by rules (the party column
/// on its right and below, the number column below). The adversary row is absent when the sample has no
/// `parties`, so a main-case paper uses the same template.
#let caption(meta) = {
  let debtor = meta.debtor
  let rows = ((("In re:",) + debtor.names + (debtor.designation,),
    ("Chapter " + meta.chapter, "Case No. " + meta.case_number)),)
  if "parties" in meta and meta.parties != none {
    let left = ()
    for (k, p) in meta.parties.enumerate() {
      if k > 0 { left.push("v.") }
      left += p.names + (p.designation,)
    }
    rows.push((left, ("Adv. Proc. No. " + meta.adv_number,)))
  }
  let cells = ()
  for (left, right) in rows {
    cells.push(grid.cell(stroke: (right: rule, bottom: rule),
      block(inset: (right: caption-gap-left, ..caption-inset), for l in left { line-block(inl(l)) })))
    cells.push(grid.cell(stroke: (bottom: rule),
      block(inset: (left: caption-gap-right, ..caption-inset), for l in right { line-block(inl(l)) })))
  }
  block(above: pitch-double, below: 0pt, grid(columns: (caption-left, 1fr), ..cells))
}

#let cover(meta) = {
  if "without_hearing" in meta and meta.without_hearing {
    // D. Me. LBR 9013-3: the legend goes in the upper right corner of the first page.
    line-block(align(right, text(weight: "bold", "RELIEF REQUESTED WITHOUT A HEARING")))
  }
  for (i, n) in court-name.enumerate() {
    line-block(above: if i == 0 and "without_hearing" in meta and meta.without_hearing { heading-gap } else { 0pt },
      align(center, text(weight: "bold", n)))
  }
  caption(meta)
  block(width: 100%, above: pitch-double, below: heading-gap, {
    set text(..edges(pitch-single))
    align(center, text(weight: "bold", upper(inl(meta.title))))
  })
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lists, relief, signature
// ---------------------------------------------------------------------------

/// A heading in a double line box, half a double line above and below; never at the foot of a page.
#let heading-block(level, title) = block(width: 100%, above: heading-gap, below: heading-gap, sticky: true, {
  set par(first-line-indent: 0pt)
  if level == 1 {
    align(center, text(weight: "bold", upper(inl(title))))
  } else if level == 2 {
    text(weight: "bold", inl(title))
  } else {
    text(weight: "bold", style: "italic", inl(title))
  }
})

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (Fed. R. Civ. P. 10(b), via Fed. R. Bankr. P. 7010). Headings and
/// lists are not numbered.
#let numbered-body(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      // Headings are set here, not by cmarker: cmarker's own heading output ignores the show rules.
      let h = t.match(regex("^(#{1,3})\\s+([\\s\\S]*)$"))
      heading-block(h.captures.at(0).len(), h.captures.at(1).trim())
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists: items lettered (a), (b), ..., the label half an inch in; a list may break across pages.
      pad(left: item-indent, md(t))
    } else {
      n += 1
      body-par(n, md(t))
    }
  }
}

/// Date and signature block, single-spaced: "Dated:" at the margin, "/s/" and the signer's lines at `sig-col`.
#let signature-lines(meta) = {
  let lines = ("/s/ " + meta.signature.signer,) + meta.signature.lines
  for (i, l) in lines.enumerate() {
    line-block(above: if i == 0 { pitch-double } else { 0pt }, grid(columns: (sig-col, 1fr),
      if i == 0 [Dated: #meta.date] else [], inl(l)))
  }
}

#let meb-adversary-complaint(meta, body) = {
  // "- n -" centered at the foot, in a single-spaced line box.
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), [#"- "#counter(page).display()#" -"])),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: item-label)
  // A doubled sign stays with its number ("§§ 157"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set enum(numbering: "(a)")

  cover(meta)

  // The unnumbered opening paragraphs ("NOW COMES ..."), one per blank-line-separated chunk.
  if "lead_in" in meta and meta.lead_in != none {
    for chunk in meta.lead_in.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
      body-par(none, inl(chunk.trim()))
    }
  }

  numbered-body(body)

  // The closing paragraph ("WHEREFORE ...") stays on the page with the signature block it leads into.
  block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
    if "wherefore" in meta and meta.wherefore != none { body-par(none, inl(meta.wherefore)) }
    signature-lines(meta)
  })
}
