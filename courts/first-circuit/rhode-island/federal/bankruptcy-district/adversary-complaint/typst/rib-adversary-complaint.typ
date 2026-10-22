// Adversary complaint for the United States Bankruptcy Court, District of Rhode Island (rib).
// Rules: FRBP 7001 (adversary proceeding), FRBP 7008 (pleading), FRCP 10(a)-(b) as applied by FRBP 7010
// (caption; numbered paragraphs); LBR 1005-1(a)-(c) (case name, number and chapter on every paper and on the
// signature page; 8 1/2 x 11; text at least 11 point and double spaced; footnotes at least 10 point; signer's
// identification); LBR 7007-1 (papers in adversary proceedings follow LBR 1005-1); LBR 7003-1(b) and 5005-1(b)
// (cover sheet, Official Form B1040, filed separately). See ../README.md for each rule's text and date.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute per docs/FONTS.md, vendored; no system font is used
#let type-size = 12pt                     // LBR 1005-1(b): text at least 11 point
#let footer-size = 11pt                   // the page number
#let para-indent = 0.5in
#let margin = 1in                         // not set by LBR 1005-1; the usual 1 inch on every side
#let caption-left = 3.3in                 // width of the party column of the caption
#let caption-pad = 10pt                   // the party text stands off the column's right rule
#let caption-foot = 8pt                   // ... and off its bottom rule
#let caption-right = 0.35in               // the case-number column stands off the party column
#let label-box = 0.4in                    // the number of an allegation, after the paragraph indent
#let item-box = 0.6in                     // the letter of a list item, after the paragraph indent
#let quote-left = 0.75in                  // quotations: indented on both sides
#let quote-right = 0.5in
#let sig-col = 3in                        // the signature column starts this far in
#let rule = 0.75pt
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF RHODE ISLAND")   // court-level text, not case text

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                  // LBR 1005-1(b): double spaced
#let pitch-single = 13.8pt                // a single line: 1.15 x the type size (caption, quotations, signature; exempt)
#let pitch-footer = 1.15 * footer-size
#let gap = pitch-single                   // a blank single line between groups
#let half-gap = pitch-single / 2

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("rib-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph of its own, with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// A double-spaced paragraph with the first line indented.
#let body-par(body) = block(width: 100%, above: 0pt, below: 0pt, par(body))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// The caption: the bankruptcy case (In re) above, the adversary proceeding (parties) below, in a column ruled on
/// the right and at the foot; the chapter and case numbers on the right. Everything comes from the frontmatter.
#let caption(meta) = {
  let left = {
    line-block[IN RE:]
    for (i, n) in meta.in_re.enumerate() { line-block(above: if i == 0 { half-gap } else { 0pt }, inl(n)) }
    line-block(align(right, inl(meta.debtor_designation)))
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block[v.] }
      for (i, n) in p.names.enumerate() { line-block(above: if k == 0 and i == 0 { gap } else { 0pt }, inl(n)) }
      line-block(inl(p.designation))
    }
  }
  let right = {
    line-block[Chapter #meta.chapter]
    line-block[Bankruptcy Case No. #meta.case_number]
    line-block(above: half-gap)[Adversary Proceeding No. #meta.adversary_number]
  }
  block(above: pitch-double, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: rule, bottom: rule), inset: (right: caption-pad, bottom: caption-foot), left),
    pad(left: caption-right, right),
  ))
}

#let cover(meta) = {
  for l in court-name { line-block(align(center, strong(l))) }
  caption(meta)
  block(above: pitch-double, below: pitch-single, line-block(align(center, strong(upper(meta.title)))))
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

/// The case line (LBR 1005-1(a): the case name, number and chapter on the signature page too), the date at the
/// margin beside "Respectfully submitted,", then the signature column. One block that never breaks across a page.
#let signature-block(meta) = {
  let s = meta.signature
  let col(above: 0pt, body) = line-block(above: above, indent: sig-col, body)
  block(breakable: false, width: 100%, above: pitch-single, below: 0pt, {
    line-block("In re " + meta.in_re.join(", ") + ", Debtor; Chapter " + meta.chapter + "; Bankruptcy Case No. "
      + meta.case_number + "; Adversary Proceeding No. " + meta.adversary_number)
    block(width: 100%, above: gap, below: 0pt, grid(columns: (sig-col, 1fr),
      line-block(if "date" in meta [Dated: #inl(meta.date)]),
      line-block[Respectfully submitted,]))
    col(above: gap, inl(s.client))
    col(inl(s.by))
    col(above: gap)[/s/ #inl(s.signer)]
    col(inl(s.signer))
    for l in s.firm { col(inl(l)) }
    col[RI Bar No. #inl(s.bar_id)]
    for l in s.lines { col(inl(l)) }
  })
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered lists, quotations
// ---------------------------------------------------------------------------

/// Body chunks. A chunk is one blank-line-separated piece of markdown:
/// - a heading (`#` centered bold caps, `##` centered bold, `###` centered bold italic): unnumbered, sticky;
/// - a list (`1.` items): lettered (a), (b), ...;
/// - a block quotation (`>`): single spaced and indented, unnumbered;
/// - a paragraph: numbered (FRCP 10(b)), unless it starts with WHEREFORE (the prayer lead-in is unnumbered).
#let allegations(body) = {
  let n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let lvl = t.match(regex("^#+")).text.len()
      let txt = inl(t.slice(lvl).trim())
      // Headings at the body size and pitch, no space of their own; sticky: a heading never ends a page.
      block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
        set par(first-line-indent: 0pt)
        align(center, if lvl == 1 { strong(upper(txt)) } else if lvl == 2 { strong(txt) } else { strong(emph(txt)) })
      })
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      let items = t.split(regex("(?m)^\\d+\\.[ \\t]+")).map(i => i.trim()).filter(i => i != "")
      for (i, item) in items.enumerate() {
        block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent, par(first-line-indent: 0pt,
          hanging-indent: item-box, [#box(width: item-box)[(#numbering("a", i + 1))]#inl(item.replace(regex("\\s*\\n\\s*"), " "))])))
      }
    } else if t.starts-with(">") {
      // A quotation: single spaced, indented on both sides, half a double line off the text; its paragraphs a
      // blank single line apart.
      let paras = t.split(regex("\\n>[ \\t]*(\\n|$)")).map(p => p.replace(regex("(?m)^>[ \\t]?"), "").trim())
        .filter(p => p != "")
      block(width: 100%, above: pitch-double / 2, below: pitch-double / 2, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        for (i, p) in paras.enumerate() {
          block(width: 100%, above: if i == 0 { 0pt } else { gap }, below: 0pt,
            pad(left: quote-left, right: quote-right, inl(p.replace(regex("\\s*\\n\\s*"), " "))))
        }
      })
    } else if t.starts-with("WHEREFORE") {
      body-par(inl(t))
    } else {
      n += 1
      body-par[#box(width: label-box)[#n.]#inl(t)]
    }
  }
}

#let rib-adversary-complaint(meta, body) = {
  set page(paper: "us-letter", margin: margin, footer-descent: 30%, footer: context {
    set text(size: footer-size, ..edges(pitch-footer))
    align(center, counter(page).display())
  })
  set document(title: meta.title)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled section sign stays with its number ("§§ 1408"), as the docx engine binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    let leads = if type(meta.lead_in) == array { meta.lead_in } else { (meta.lead_in,) }
    for p in leads { body-par(inl(p)) }
  }

  allegations(body)
  signature-block(meta)
}
