// Adversary complaint for the United States Bankruptcy Court for the District of Puerto Rico (prb).
// Rules (see ../README.md): FRBP 7010 (FRCP 10 applies; the caption substantially conforms to Form 416A),
// FRCP 10(a) (caption; the title names all parties) and 10(b) (numbered paragraphs), FRBP 9004(b) (caption),
// LBR 1005-1(a) (bankruptcy case name, number, judge's initials and chapter on every paper), 1005-1(b)
// (8 1/2 x 11 inch pdf), 1005-1(c) (signature block); L.Cv.R. 7(e) through LBR 1001-1(b) (12 point, double
// spacing, page numbers at the bottom center; ../rules.md, Finding 2). Not generated: the B1040 cover sheet
// (LBR 7003-1) and the summons (LBR 7004-2), which are separate filings.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no typeface rule (../rules.md, Finding 3); Times New Roman, the house standard (David 2026-10-17; data/exemplar-fonts.json template_face, fb-595.68.38), not the Organic Power filer's Courier New (one filer's style, tier 3); Liberation Serif its metric twin. A proportionally spaced face at 12 pt meets L.Cv.R. 7(e)
#let type-size = 12pt                   // L.Cv.R. 7(e) via LBR 1001-1(b): no less than 12 points
#let margin = 1in                       // convention (both exemplars have one-inch margins)
#let para-indent = 0.5in                // first-line indent; the paragraph number's box; the prayer letters' box
#let caption-left = 3.4in               // width of the left (parties) column of the caption
#let caption-gutter = 0.2in             // between the parties column and the case-number column
#let caption-pad = 10pt                 // the parties' text stands off the column's right and bottom rules
#let right-pad = 0.15in                 // the case-number column's text stands in from its left
#let sig-indent = 3in                   // the signer's lines stand this far in
#let rule = 0.75pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // double spacing (L.Cv.R. 7(e)): two 12 pt lines
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size
#let half-gap = pitch-single / 2        // around the rule between the debtor and the parties

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("prb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names, *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it; `ruled`: a rule below it.
#let line-block(above: 0pt, indent: 0pt, ruled: false, body) = block(width: 100%, above: above, below: 0pt,
  stroke: if ruled { (bottom: rule) } else { none }, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(left: indent, body)
  })

/// A body paragraph at the double pitch, the first line half an inch in.
#let body-par(c) = block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), c))

// ---------------------------------------------------------------------------
// Caption: court, debtor, parties, case number, chapter, adversary number, title
// ---------------------------------------------------------------------------

#let court-title(meta) = for l in meta.court { line-block(align(center, strong(upper(inl(l))))) }

#let caption(meta) = {
  assert("bankruptcy_case" in meta, message: "prb-adversary-complaint: LBR 1005-1(a) requires the bankruptcy case number and judge's initials in the frontmatter (bankruptcy_case)")
  assert("chapter" in meta, message: "prb-adversary-complaint: LBR 1005-1(a) requires the chapter in the frontmatter (chapter)")
  // An adversary number that is not yet assigned prints as a blank to fill in (the exemplar leaves it blank).
  let adv = meta.at("adversary", default: "")
  block(above: pitch-double, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    // "In re:" and the debtor, a rule, then the parties with "v." between them; ruled at the right and below.
    block(width: 100%, stroke: (right: rule, bottom: rule), inset: (right: caption-pad, bottom: caption-pad), {
      line-block[In re:]
      for n in meta.debtor.names { line-block(inl(n)) }
      line-block(ruled: true, inl(meta.debtor.designation))
      for (k, p) in meta.parties.enumerate() {
        if k > 0 { line-block[v.] }
        for (i, n) in p.names.enumerate() { line-block(above: if k == 0 and i == 0 { half-gap } else { 0pt }, inl(n)) }
        line-block(inl(p.designation))
      }
    }),
    pad(left: right-pad, {
      line-block[Bankr. Case No. #inl(meta.bankruptcy_case)]
      line-block(inl(meta.chapter))
      line-block[Adv. Proceeding No. #if adv == "" { "__________" } else { inl(adv) }]
    }),
  ))
}

// ---------------------------------------------------------------------------
// Signature block (LBR 1005-1(c); LBR 5005-4(b)(2)(C)(ii): /s/ name)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  assert("signature" in meta, message: "prb-adversary-complaint: the frontmatter needs a signature block (LBR 1005-1(c))")
  assert("signer" in meta.signature, message: "prb-adversary-complaint: the signature block needs the signer's name (LBR 5005-4(b)(2)(C)(ii): /s/ name)")
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
    line-block[Respectfully submitted,]
    line-block(above: pitch-single, inl(meta.signature.date))
    line-block(above: pitch-single, indent: sig-indent)[/s/ #inl(meta.signature.signer)]
    for l in meta.signature.lines { line-block(indent: sig-indent, inl(l)) }
  })
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered prayer items
// ---------------------------------------------------------------------------

/// Numbered paragraphs (FRCP 10(b)). Each blank-line-separated chunk of markdown that is neither a heading
/// nor a list is one numbered paragraph: the number in a half-inch box after the first-line indent. Headings and
/// lists are not numbered, nor the prayer's lead-in ("**WHEREFORE**, ...") or a paragraph marked "(unnumbered) ".
#let body-chunks(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Prayer items, lettered A., B., ...: the letter half an inch in, in a half-inch box, the text hanging after it.
      pad(left: para-indent, cmarker.render(t, raw-typst: false, smart-punctuation: true))
    } else {
      let marked = t.starts-with("(unnumbered) ")
      let numbered = not (marked or t.starts-with("**WHEREFORE**"))
      let md = if marked { t.slice(13) } else { t }
      if numbered {
        n += 1
        body-par[#box(width: para-indent)[#n.]#inl(md)]
      } else {
        body-par(inl(md))
      }
    }
  }
}

#let prb-adversary-complaint(meta, body) = {
  // Page numbers centered at the foot of every page (L.Cv.R. 7(e): preferably at the bottom center), in a single
  // line box, so the number sits at the same place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch; lettered items as a label box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  set enum(numbering: "A.")
  // A doubled section sign stays with its number ("§§ 1391"; the docx filter binds it with a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // Headings at the body size and pitch, at the margin: level 1 bold capitals ("I. INTRODUCTION"), level 2 bold,
  // level 3 bold italic. No space of their own; sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { upper(it.body) } else if it.level == 3 { emph(it.body) } else { it.body }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, strong(b))
  }

  court-title(meta)
  caption(meta)
  block(sticky: true, width: 100%, above: pitch-double, below: pitch-single, line-block(align(center, strong(inl(meta.title)))))
  block(sticky: true, width: 100%, above: 0pt, below: 0pt, strong[TO THE HONORABLE COURT:])
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }

  body-chunks(body)

  signature-block(meta)
}
