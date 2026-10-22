// Adversary complaint for the United States Bankruptcy Court, E.D. Missouri (moeb).
// Governing text: E.D. Mo. Local Rules of Bankruptcy Procedure, "as revised effective December 1, 2025"
// (PDF fetched 2026-10-14 from the court's site through WebFetch; see ../README.md), and the Federal Rules of
// Bankruptcy Procedure as published by LII (fetched 2026-10-14):
//   Fed. R. Bankr. P. 7010 (caption substantially conforms to the appropriate version of Official Form 416); 7008(a) (jurisdiction, and whether the pleader
//   consents to final orders); Fed. R. Civ. P. 10(a) and 10(b) (caption; numbered paragraphs).
//   L.R. 7003(A): Adversary Proceeding Cover Sheet (Local Form 18) must accompany the complaint. It is a separate
//   clerk form, not produced here.
//   L.R. 9004(A): caption; top left the debtor and the parties; top right the case number with judge, chapter,
//   adversary number and any hearing.
//   L.R. 9004(C): letter paper, margins no less than 1 inch, one side, standard 12-point font, numbered paragraphs.
//   L.R. 9004(D): every filing has a certificate of service (optional block here; see README.md).
// Content-agnostic: every case word comes from the sample's frontmatter and body, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")       // Vendored in fonts/. L.R. 9004(C) names no typeface; see README.md.
#let type-size = 12pt                  // L.R. 9004(C): standard 12-point font, headings and footer included.
#let margin = 1in                      // L.R. 9004(C): margins no less than 1 inch.
#let para-indent = 0.5in               // First-line indent; the paragraph number's box after it.
#let caption-left = 3.6in              // Width of the left (debtor and parties) column of the caption.
#let caption-gutter = 0.25in           // Between the left column and the case block.
#let caption-inset = 10pt              // The left column's text stands off its right rule.
#let caption-pad = 8pt                 // The left column's bottom rule stands off its last line.
#let right-inset = 0.15in              // The case block stands off the gutter.
#let sig-left = 3in                    // Signature grid: the "Date" column, a gutter, the signature column.
#let sig-gutter = 0.2in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt             // A single line: 1.15 x the type size (Word's single line in this face).
#let pitch-double = 2 * pitch-single   // Double spacing (27.6 pt, as in the filed exemplar).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("moeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Non-breaking spaces keep "11 U.S.C. § 548" together and "§ 548" on one line (the docx filter binds the same).
#let joins(s) = s.replace(" U.S.C.", "\u{00A0}U.S.C.").replace("U.S.C. §", "U.S.C.\u{00A0}§").replace("§ ", "§\u{00A0}")

/// Inline markdown (for names with *et al.*, bold placeholders, section signs, and so on).
#let inl(s) = cmarker.render(joins(s), raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// The FRBP 7008(a) consent sentence, which the sample places inline as {{consent}} in the jurisdiction
/// paragraph. A sample without a `consent` value renders a bold placeholder, so an unfinished statement is
/// visible in the render and cannot pass for a finished one.
#let consent-md(meta) = {
  let c = meta.at("consent", default: none)
  if c == none {
    "**[COUNSEL TO STATE WHETHER PLAINTIFF CONSENTS OR DOES NOT CONSENT TO THE ENTRY OF FINAL ORDERS OR JUDGMENT BY THE BANKRUPTCY JUDGE, FED. R. BANKR. P. 7008(a)]**"
  } else {
    assert(c == "consents" or c == "does not consent", message: "moeb-adversary-complaint: consent must be \"consents\" or \"does not consent\"")
    "Pursuant to Fed. R. Bankr. P. 7008(a), Plaintiff " + c + " to the entry of final orders or judgment by the bankruptcy judge."
  }
}

// ---------------------------------------------------------------------------
// Caption and first page (L.R. 9004(A); Fed. R. Bankr. P. 7010)
// ---------------------------------------------------------------------------

/// The court's name (fixed, not case-specific): three single-spaced lines, centered and bold.
#let court-title() = for l in ("UNITED STATES BANKRUPTCY COURT", "FOR THE EASTERN DISTRICT OF MISSOURI", "EASTERN DIVISION") {
  line-block(align(center, text(weight: "bold", l)))
}

#let caption(meta) = block(above: pitch-double, below: pitch-double, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Debtor block, then the parties: each with its names and designation, "v." between them; a single line
    // between the debtor and the parties.
    for l in meta.caption.debtor { line-block(inl(l)) }
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for (j, n) in p.names.enumerate() { line-block(above: if k == 0 and j == 0 { pitch-single } else { 0pt }, inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  pad(left: right-inset, {
    // Top right of the first page (L.R. 9004(A)): case number with judge, chapter, adversary number, and hearing
    // data once they exist. A complaint is filed before any adversary number or hearing is assigned, so those
    // lines appear only when the sample supplies them.
    line-block(inl("Case No. " + meta.case_number))
    if "judge" in meta { line-block(inl(meta.judge)) }
    if "chapter" in meta { line-block(inl(meta.chapter)) }
    if meta.at("adversary_number", default: "") != "" { line-block(inl("Adv. Proc. No. " + meta.adversary_number)) }
    if "hearing" in meta and meta.hearing != none { for h in meta.hearing { line-block(inl(h)) } }
  }),
))

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lists, unnumbered paragraphs
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: unnumbered (first-line indent), centered, or numbered (Fed. R. Civ. P.
/// 10(b); L.R. 9004(C)): the number in a box of the paragraph indent after the first-line indent, the text after it.
#let body-par(num, content, centered: false) = block(width: 100%, above: 0pt, below: 0pt, if centered {
  align(center, par(first-line-indent: 0pt, content))
} else if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: para-indent, [#num.])#content])
})

/// Each blank-line-separated chunk is one of:
///   `# ...`, `## ...`   heading (level 1 centered caps; level 2 centered bold; level 3 bold italic)
///   `1. ...` or `- ...` list
///   `%%...`             centered, unnumbered
///   `%...`              unnumbered paragraph (for WHEREFORE clauses)
///   anything else       numbered paragraph
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content
/// recurses without end in typst 0.15. The last chunk is kept in one unbreakable block with the signature
/// (`tail`), so a signature never stands alone.
#let allegations(body, meta, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for (i, c) in chunks.enumerate() {
    let t = joins(c.trim().replace("{{consent}}", consent-md(meta)))
    let piece = if t.starts-with("#") or t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      md(t)
    } else if t.starts-with("%%") {
      body-par(none, md(t.slice(2).trim()), centered: true)
    } else if t.starts-with("%") {
      body-par(none, md(t.slice(1).trim()))
    } else {
      n += 1
      body-par(n, md(t))
    }
    if i == chunks.len() - 1 { block(breakable: false, width: 100%, { piece; tail }) } else { piece }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

/// "Date" at the left, level with "Respectfully submitted,"; the firm a single line below, "By:" a single line
/// below that, then the attorneys and the address lines.
#let signature-block(meta) = {
  let s = meta.signature
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (sig-left, 1fr),
    column-gutter: sig-gutter,
    line-block(inl("Date: " + s.date)),
    {
      line-block[Respectfully submitted,]
      line-block(above: pitch-single, inl(s.firm))
      line-block(above: pitch-single, inl("By: " + s.by))
      for l in s.attorneys + s.lines { line-block(inl(l)) }
    },
  ))
}

/// Optional: a certificate of service (L.R. 9004(D)). Rendered only when the sample gives one. The sample for
/// this court's exemplar has none; the rule allows it to be filed separately within 24 hours (L.R. 9004(D)(3)).
#let certificate-block(meta) = if "certificate" in meta {
  block(width: 100%, above: pitch-double, below: 0pt, {
    body-par(none, text(weight: "bold", "CERTIFICATE OF SERVICE"), centered: true)
    for p in meta.certificate { body-par(none, inl(p)) }
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let moeb-adversary-complaint(meta, body) = {
  assert(body.contains("{{consent}}"), message: "moeb-adversary-complaint: the jurisdiction paragraph must carry {{consent}} (Fed. R. Bankr. P. 7008(a))")

  // Page numbers centered, arabic, on every page; the number in a single-spaced line box, so it sits at the same
  // place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)

  // Headings at the body size and pitch: level 1 centered bold capitals; level 2 centered bold; level 3 bold
  // italic at the margin. No space of their own (the double pitch sets them off); sticky, so a heading never
  // ends a page.
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
  body-par(none, text(weight: "bold", upper(inl(meta.title))), centered: true)
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  allegations(body, meta, { signature-block(meta); certificate-block(meta) })
}
