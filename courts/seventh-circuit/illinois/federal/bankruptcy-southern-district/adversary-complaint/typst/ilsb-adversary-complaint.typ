// U.S. Bankruptcy Court, Southern District of Illinois: adversary complaint (Fed. R. Bankr. P. 7001 and
// 7010, which apply Fed. R. Civ. P. 10 with a Form 416 caption; S.D. Ill. L.R. 5005-1, 5005-2, 9011).
//
// Rule-driven and content-agnostic. Requirement IDs (ILSB-...) refer to ../README.md, which quotes the
// rule text. No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The body is markdown rendered by cmarker; the caption, counsel and signature data come from the YAML
// frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // No S.D. Ill. rule names a typeface (ILSB-FORM-002 gap); Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                   // Style choice: the exemplar is Times 12 pt. No S.D. Ill. type-size rule.
#let footer-size = 10pt                 // Page number only; not body text.
#let page-margin = 1in                  // ILSB-FORM-001 (L.R. 5005-2): 8 1/2 by 11 inch paper; 1 in margins (style choice).
#let para-indent = 0.5in                // First-line indent of every body paragraph; the paragraph number stands there.
#let number-box = 0.5in                 // The paragraph number's box: the text starts 1 in from the margin (as filed).
#let prayer-box = 0.3in                 // A prayer item's letter box: the text hangs 0.8 in from the margin.
#let quote-indent = 0.5in               // A block quotation, both sides.
#let list-indent = 0.5in                // A bullet's box at the margin; the item's text hangs after it.
#let caption-left = 3.6in               // Width of the party column of the caption.
#let caption-inset = 10pt               // The party text stands off the caption's right rule; the bottom rule stands this far below it.
#let caption-rule = 0.75pt              // The caption's rules; Word adds the bottom rule's width to the caption's height.
#let case-inset = 0.35in                // The case information stands this far right of the party column.
#let sig-column = 3in                   // The signature's right-hand column starts this far in.
#let exhibit-column = 1.4in             // Summary of Exhibits: the label column.

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                  // Double spacing for the body (convention, not a rule; see ../README.md), as filed.
#let pitch-single = 13.8pt              // A single line: Word's single line in this face at 12 pt (1.15 x the type size).
#let pitch-footer = 12pt                // The 10 pt page-number line.
#let gap = pitch-body / 2               // Around headings and block quotations, in the caption and the signature.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilsb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names, *et al.*), as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, hang: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: hang)
  pad(left: left, body)
})

/// Lines of the frontmatter, one single-spaced paragraph each; an empty line is a single line of space before the
/// next one.
#let line-list(items, left: 0pt, above: 0pt) = {
  let skip = above
  for i in items {
    if i == none or i == "" { skip = calc.max(skip, pitch-single) } else {
      line-block(above: skip, left: left, inl(i))
      skip = 0pt
    }
  }
}

/// A body paragraph: the body pitch, the first-line indent, no space of its own (double spacing runs on).
#let body-par(body, sticky: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky, par(body))

// ---------------------------------------------------------------------------
// Caption (Form 416 as S.D. Ill. uses it: court, debtor and chapter, parties, adversary number)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE SOUTHERN DISTRICT OF ILLINOIS")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    line-block(below: if i == lines.len() - 1 { pitch-body } else { 0pt }, align(center, strong(l)))
  }
}

#let caption(meta) = {
  // Left: the debtor (In re), then the parties to the adversary proceeding, "v." between the sides, a single line
  // of space between the groups.
  let left = {
    line-block[In re:]
    for d in meta.debtors { line-block(inl(d)) }
    line-block(inl(meta.debtor_designation))
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block(above: pitch-single)[v.] }
      for (j, n) in p.names.enumerate() { line-block(above: if j == 0 { pitch-single } else { 0pt }, inl(n)) }
      line-block(inl(p.designation))
    }
  }
  // Right: the bankruptcy case number and chapter (L.R. 5005-1(B)(2)), then the adversary number.
  let adv = if meta.adversary_no != none and meta.adversary_no != "" { inl(meta.adversary_no) } else { "_" * 10 }
  let right = {
    line-block[Case No. #inl(meta.bankruptcy_case_no)]
    line-block[Chapter #inl(meta.chapter)]
    line-block(above: gap)[Adversary No. #adv]
  }
  block(above: 0pt, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-inset, bottom: caption-inset + caption-rule), left),
    pad(left: case-inset, right),
  ))
}

// ---------------------------------------------------------------------------
// Signature and attorney block (L.R. 9011(A); FRBP 9011 and Electronic Filing Rules, Rule 5)
// ---------------------------------------------------------------------------

/// "Dated" at the margin and "Respectfully submitted," in the right-hand column on the same line; the party and the
/// signer in that column; the attorney block at the margin under it. Kept together.
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    line-block[#box(width: sig-column)[Dated: #inl(meta.date)]Respectfully submitted,]
    line-list(sig.party, left: sig-column, above: gap)
    line-list(("/s/ " + sig.signer, sig.signer + ",", sig.signer_title), left: sig-column, above: gap)
    line-list(sig.attorney, above: pitch-body)
  })
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, prayers, lists and quotations
// ---------------------------------------------------------------------------

/// The body, one blank-line-separated chunk at a time.
///  - `#` / `##` / `###` headings: centered bold capitals / centered bold / bold. Not numbered.
///  - a chunk beginning WHEREFORE starts the prayer for relief: it is not numbered, and the items after
///    it are written `A. ...`, `B. ...` and rendered lettered with a hanging indent, unnumbered.
///  - a chunk beginning `- ` is a bulleted list (not numbered, not part of the prayer).
///  - a chunk beginning `>` is a block quotation: single-spaced and indented.
///  - every other chunk is a numbered paragraph (Fed. R. Civ. P. 10(b)). The author writes no number:
///    a chunk beginning "1. " is a numbered paragraph's text, not a list, so the number is the template's.
/// Numbering is applied per chunk, not with a show rule (a show rule that re-wraps paragraph content
/// recurses without end in typst 0.15). Headings are `sticky`, so one never ends a page.
#let body-flow(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote definitions are rendered with the paragraph that cites them (see ilsb-motion-brief.typ).
  let defs = (:)
  for c in chunks {
    let key = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:"))
    if key != none { defs.insert(key.captures.at(0), c.trim()) }
  }
  let md(t) = {
    let tail = ""
    for (key, d) in defs {
      if t.contains("[^" + key + "]") { tail += "\n\n" + d }
    }
    cmarker.render(t + tail, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
  chunks = chunks.filter(c => not c.trim().starts-with("[^"))
  let para-counter = counter("ilsb-paragraph")
  let in-prayer = false
  for c in chunks {
    let t = c.trim()
    let prayer-item = t.match(regex("^([A-Z])\\.[ \\t]+([\\s\\S]*)"))
    if t.starts-with("#") {
      in-prayer = false
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if in-prayer and prayer-item != none {
      // The letter at the paragraph indent in a box, the text hanging after it.
      block(width: 100%, above: 0pt, below: 0pt, par(hanging-indent: para-indent + prayer-box,
        [#box(width: prayer-box)[#(prayer-item.captures.at(0)).]#md(prayer-item.captures.at(1))]))
    } else if t.starts-with(regex("^[-*+][ \\t]")) {
      md(t)
    } else if t.starts-with(">") {
      block(width: 100%, above: gap, below: gap, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        show quote.where(block: true): it => it.body
        pad(left: quote-indent, right: quote-indent, md(t))
      })
    } else if t.starts-with("WHEREFORE") {
      in-prayer = true
      body-par(md(t), sticky: true)
    } else {
      para-counter.step()
      body-par[#box(width: number-box, context para-counter.display("1."))#md(t)]
    }
  }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let ilsb-adversary-complaint(meta, body) = {
  // "Page x of y", centered, in a 12 pt line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(size: footer-size, ..edges(pitch-footer),
      [Page #counter(page).get().first() of #counter(page).final().first()])),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch; a bullet in a box at the margin, the text hanging after it.
  show: xengine.with(pitch: pitch-body, list-indent: list-indent)
  // A doubled sign stays with its number ("§§ 1408"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Headings: single-spaced, half a body line from the text on either side, kept with the text after them; level 1
  // centered bold capitals, level 2 centered bold, level 3 bold at the margin.
  show heading: it => block(width: 100%, above: gap, below: gap, sticky: true, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(upper(it.body))) }
    else if it.level == 2 { align(center, strong(it.body)) }
    else { strong(it.body) }
  })

  court-title(meta)
  caption(meta)
  line-block(above: pitch-body, below: pitch-body, align(center, strong(upper(meta.title))))

  if "lead_in" in meta and meta.lead_in != none { body-par(inl(meta.lead_in)) }

  body-flow(body)

  signature-block(meta)

  if "exhibits" in meta and meta.exhibits != none and meta.exhibits.len() > 0 {
    // Summary of Exhibits: the last page of the filing (Admin. Guide, adversary complaint; Electronic
    // Filing Rules, Rule 6). Its certificate of service is required when exhibits are served.
    pagebreak()
    line-block(below: pitch-body, align(center, strong("SUMMARY OF EXHIBITS")))
    for ex in meta.exhibits {
      line-block(above: gap, hang: exhibit-column)[#box(width: exhibit-column, strong(ex.label))#inl(ex.description)]
    }
    if "exhibits_service" in meta and meta.exhibits_service != none {
      line-block(above: pitch-body, below: gap, align(center, strong("CERTIFICATE OF SERVICE")))
      body-par(inl(meta.exhibits_service))
    }
  }
}
