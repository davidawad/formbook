// Adversary complaint for the U.S. Bankruptcy Court, District of Minnesota (mnb).
// Rules: Fed. R. Bankr. P. 7001 (adversary proceeding), 7008 (core or non-core statement), 7010 (caption,
// Form 416A), 9004(a) (legibility), 9011 (signature block); D. Minn. LBR 9004-1(a) (letter-size paper),
// 9004-1(b)(2) (print to PDF). Fed. R. Civ. P. 10(b) applies through 7010 (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no font rule in the local rules; Times New Roman as in the exemplars
#let type-size = 12pt                   // no size rule in the local rules; 12 pt is the convention in both exemplars
#let page-w = 8.5in                     // LBR 9004-1(a): letter-size paper
#let page-h = 11in
#let margin = 1in                       // convention in both exemplars; no local rule sets margins
#let para-indent = 0.5in                // first-line indent; the paragraph number's box after it
#let item-indent = 0.5in                // lettered items: the letter half an inch in, the text a box after it
#let list-left = 0.9in                  // a list that carries its own letters ("A. ...") stands this far in
#let caption-left = 3.5in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the caption's columns
#let caption-inset = 0.1in              // each caption column stands off the gutter
#let caption-pad = 8pt                  // the caption's rules stand off the text
#let designation-indent = 1.8in         // a caption line written "> Debtors." (the party designations)
#let sig-left = 2.6in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // double spacing: 27.6 pt, the pitch of all three exemplars

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// Caption and signature lines, one single-spaced line each. An empty string is a blank line; a line starting
/// with ">" is indented (the party designations "Plaintiff," and "Debtors.").
#let line-stack(items) = for i in items {
  if i == "" { line-block("\u{00A0}") } else if i.starts-with(">") {
    line-block(indent: designation-indent, inl(i.slice(1).trim()))
  } else { line-block(inl(i)) }
}

// ---------------------------------------------------------------------------
// Caption: court, debtor box, adversary box (Fed. R. Bankr. P. 7010; Official Form 416A)
// ---------------------------------------------------------------------------

#let court-title() = {
  line-block(align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")))
  line-block(align(center, text(weight: "bold", "DISTRICT OF MINNESOTA")))
}

/// One box of the caption: two columns between the rules `stroke` names, the text `caption-pad` off them.
#let caption-box(stroke, left, right) = block(width: 100%, above: 0pt, below: 0pt, stroke: stroke,
  inset: (top: caption-pad, bottom: caption-pad), grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    pad(right: caption-inset, left),
    pad(left: caption-inset, right),
  ))

#let caption(meta) = block(width: 100%, above: pitch-double, below: pitch-double, {
  // Debtor box: "In re:" and the debtor names on the left; the case numbers on the right.
  caption-box((top: 0.75pt, bottom: 0.75pt), line-stack(meta.caption.debtor), line-stack(meta.caption.debtor_case))
  // Adversary box: the plaintiff and defendant on the left; the adversary number and the title on the right.
  caption-box((bottom: 0.75pt), line-stack(meta.caption.parties), {
    line-stack(meta.caption.adversary)
    line-block(above: pitch-single, text(weight: "bold", inl(meta.title)))
    if "jury_demand" in meta and meta.jury_demand {
      line-block(above: pitch-single, text(weight: "bold", "DEMAND FOR JURY TRIAL"))
    }
  })
})

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block: "Dated" at the left, the signer's lines at the right; it never breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  line-block[Dated: #meta.date],
  line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines),
))

/// A body paragraph at the double pitch: unnumbered (first-line indent) or numbered (Fed. R. Civ. P. 10(b): the
/// number in a box of the paragraph indent after the first-line indent, the text after it).
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), if num == none { content } else {
    [#box(width: para-indent, [#num.])#content]
  }))
/// A lettered item (the prayer): the letter half an inch in, the text hanging a box after it.
#let lettered-item(letter, content) = block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent,
  par(hanging-indent: item-indent, first-line-indent: 0pt, [#box(width: item-indent, letter)#content])))
/// An item of a list that carries its own letters ("- A. ..."): the whole item `list-left` in.
#let list-item(content) = block(width: 100%, above: 0pt, below: 0pt, pad(left: list-left,
  par(first-line-indent: 0pt, content)))

/// Numbered paragraphs (Fed. R. Civ. P. 10(b), through Fed. R. Bankr. P. 7010). Each blank-line-separated chunk
/// of markdown that is neither a heading nor a list is one numbered paragraph; a WHEREFORE paragraph is not
/// numbered. A "1." item is lettered (A., B., ...); a "-" item carries its own letter. The last paragraph is kept
/// with the signature block, so the block never stands alone on a page.
#let allegations(body, tail) = {
  let n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let piece = if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^[-*+][ \\t]")) {
      for l in t.split(regex("\\r?\\n")) { list-item(md(l.trim().slice(1).trim())) }
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      let m = t.match(regex("^(\\d+)\\.[ \\t]+([\\s\\S]*)$"))
      lettered-item(str.from-unicode(64 + int(m.captures.at(0))) + ".", md(m.captures.at(1)))
    } else if t.starts-with("WHEREFORE") {
      body-par(none, md(t))
    } else {
      n += 1
      body-par(n, md(t))
    }
    if i == chunks.len() - 1 { block(width: 100%, breakable: false, above: 0pt, below: 0pt, { piece; tail }) } else { piece }
  }
}

#let mnb-adversary-complaint(meta, body) = {
  // Page numbers centred in the bottom margin, arabic, on every page; the number in a single-spaced line box just
  // below the text (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 0pt,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: item-indent)

  // Headings at the body size and pitch, no space of their own (the double pitch sets them off): level 1 a centred
  // caps section, level 2 a centred bold sub-heading, level 3 bold italic. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", style: "italic", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  court-title()
  caption(meta)
  // The unnumbered lead-in (the paragraph that says who files and on what basis) comes before paragraph 1.
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  allegations(body, signature-block(meta))
}
