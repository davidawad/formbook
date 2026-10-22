// U.S. Bankruptcy Court, N.D. Georgia: adversary complaint (Fed. R. Bankr. P. 7001 et seq.).
//
// Rule-driven and content-agnostic. Requirement IDs (GANB-...) refer to ../README.md, which quotes or cites the
// rules (Fed. R. Bankr. P. 7008, 7010, 9004; Fed. R. Civ. P. 10; Bankr. N.D. Ga. BLR 5005-1). No case-specific
// text, no coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by
// cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // GANB-FORM-002: legible proportional serif; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // GANB-FORM-002: no size in FRBP 9004(a); 12 pt, the usual floor (Times New Roman substitute, docs/FONTS.md).
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let num-box = 0.4in                    // the paragraph number's (or prayer letter's) box; the text follows it
#let caption-left = 3.4in               // party column of the caption
#let caption-paren = 0.3in              // the ")" column between parties and case information
#let page1-caption-gap = 0.4in          // GANB-FORM-001: page 1 leaves a 2 in x 2 in clear area at the upper right for the filing stamp
#let sig-indent = 3.25in                // the counsel lines stand in the right half
#let footer-size = 11pt                 // page number only (GANB-FORM-005)
#let letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // single spacing: 1.15 x the type size (Word's single line in this face)
#let pitch-body = 20.7pt                // GANB-FORM-003: one and one-half spacing, 1.5 x the single pitch
#let line-gap = 6pt                     // between the lines of the court title, caption rows, title and counsel lines
#let par-gap = 14.4pt                   // between body paragraphs
#let rule-above = 7.2pt                 // the rule under the caption
#let title-gap = 13.2pt                 // above and below the title of the paper
#let sig-gap = 14.4pt                   // above the signature block and between the date and the counsel lines
#let cert-above = 18pt                  // above the certificate of service
#let cert-gap = 7.2pt                   // between its heading and its text

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render a markdown string (body, footnotes, inline markup) to content.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ganb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

/// A body paragraph at the body pitch, `par-gap` from the blocks around it.
#let body-par(content) = block(width: 100%, above: par-gap, below: par-gap, par(first-line-indent: 0pt, content))

// ---------------------------------------------------------------------------
// Parts of the first page
// ---------------------------------------------------------------------------

/// Court title, centred, from `court_title:` (one list item per line).
#let court-title(meta) = for (i, l) in meta.at("court_title").enumerate() {
  line-block(above: if i > 0 { line-gap } else { 0pt }, align(center, strong(upper(l))))
}

/// Caption: each row of `caption:` is [left, right]; a ")" column separates them (GANB-FIRST-001).
#let caption(meta) = for (i, r) in meta.at("caption").enumerate() {
  block(width: 100%, above: if i == 0 { page1-caption-gap } else { line-gap }, below: 0pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    grid(columns: (caption-left, caption-paren, 1fr), r.at(0), [)], r.at(1))
  })
}

/// Document title, centred and capitalised, from `title:` (one list item per line).
#let doc-title(meta) = {
  let lines = meta.at("title")
  for (i, l) in lines.enumerate() {
    line-block(above: if i == 0 { title-gap } else { line-gap }, below: if i == lines.len() - 1 { title-gap } else { 0pt },
      align(center, strong(upper(l))))
  }
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b), applied by Fed. R. Bankr. P. 7010)
// ---------------------------------------------------------------------------

/// Blank-line-separated chunks of the body become: headings (kept with the chunk after them), numbered
/// paragraphs, lettered prayer items (a), (b), ... from a markdown list, and unnumbered paragraphs
/// beginning with "WHEREFORE" (the prayer lead-in is conventionally not an allegation).
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Markdown list: each item is lettered (a), (b), ... (GANB-PRAY-001).
      let items = t.split(regex("\\r?\\n")).filter(l => l.trim() != "")
      for (k, it) in items.enumerate() {
        let text = it.trim().replace(regex("^(\\d+\\.|[-*+])[ \\t]+"), "")
        body-par[#h(para-indent)#box(width: num-box, "(" + letters.at(k) + ")")#md(text)]
      }
    } else if t.starts-with("WHEREFORE") {
      body-par[#h(para-indent)#md(t)]
    } else {
      n += 1
      body-par[#h(para-indent)#box(width: num-box)[#n.]#md(t)]
    }
  }
}

// ---------------------------------------------------------------------------
// Signature and certificate (GANB-SIG-001, GANB-SIG-002)
// ---------------------------------------------------------------------------

/// Counsel signature block: `signature.dated` (optional), then `signature.lines` (firm, "/s/" line,
/// name, Georgia Bar number, address, telephone, e-mail, "Attorney for ...") indented to the right half.
#let signature-block(sig, dated: true) = block(width: 100%, above: sig-gap, below: 0pt, breakable: false, {
  let first = true
  if dated and "dated" in sig {
    line-block[#sig.at("dated")]
    first = false
  }
  for (i, l) in sig.at("lines").enumerate() {
    line-block(above: if i == 0 { if first { 0pt } else { sig-gap } } else { line-gap }, left: sig-indent, [#l])
  }
})

/// Certificate of service: heading, text from `certificate:` (markdown), and the counsel block.
#let certificate(meta) = if "certificate" in meta {
  block(width: 100%, above: cert-above, below: 0pt, breakable: false, {
    line-block(below: cert-gap, align(center, strong[CERTIFICATE OF SERVICE]))
    block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, md(meta.at("certificate"))))
    signature-block(meta.at("signature"), dated: false)
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let ganb-adversary-complaint(meta, body) = {
  set document(title: meta.at("title").join(" ") + " (" + meta.at("court_title").last() + ")")
  // A centered page number on every page, in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: (top: 1in, bottom: 1in, left: 1in, right: 1in),
    footer-descent: 30%,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, fallback: false, lang: "en")
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1334"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  set heading(numbering: none)

  // Headings: single-spaced, kept with the text after them; level 1 centered capitals, level 2 bold, level 3 bold
  // italic.
  show heading: it => block(width: 100%, above: par-gap, below: par-gap, sticky: true, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(upper(it.body))) }
    else if it.level == 2 { strong(it.body) }
    else { strong(emph(it.body)) }
  })

  // Page 1: court title, then the caption below the 2 in filing-stamp area, then the title of the paper.
  court-title(meta)
  caption(meta)
  block(width: 100%, above: rule-above, below: 0pt, line(length: 100%, stroke: 0.75pt))
  doc-title(meta)

  // Lead-in: the unnumbered opening paragraph, then the numbered allegations and the prayer.
  if "lead_in" in meta { body-par[#h(para-indent)#md(meta.at("lead_in"))] }
  allegations(body)

  signature-block(meta.at("signature"))
  certificate(meta)
}
