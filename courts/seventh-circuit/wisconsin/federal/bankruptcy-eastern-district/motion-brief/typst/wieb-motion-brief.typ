// U.S. Bankruptcy Court, E.D. Wis.: motion with brief in support (FRBP 9013; LR 9013-1, 9014-1).
//
// Rule-driven and content-agnostic. Requirement IDs refer to ../README.md.
// No case-specific text, no coordinates measured off the filed exemplar, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").
// The body is split at the line "<!-- BRIEF -->": above it is the motion, below it the brief.
// The notice, the motion, the brief and the certificate each start a page (four papers filed together).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // LR 9004-1(a) allows any proportional font; Times New Roman, the house standard (docs/FONTS.md). Vendored in /fonts.
#let type-size = 12pt                      // WIEB-FORM-001: proportional font not smaller than 12-point.
#let page-margin = 1in                     // WIEB-FORM-003: one-inch margin on all sides.
#let footer-distance = 0.5in               // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                   // first-line indent of every body paragraph; a list number starts here
#let number-box = 0.5in                    // a numbered paragraph's number in a box after the indent: its text starts 1 in from the margin
#let quote-inset = 0.5in                   // block quotations: indented on both sides
#let caption-col = 3.05in                  // the caption's two columns, 0.4 in apart
#let caption-gutter = 0.4in
#let caption-indent = 0.5in                // the debtor's name and designation
#let designation-indent = 2.2in            // a party's designation
#let versus-indent = 0.9in                 // "v."
#let caption-rule = 0.6pt                  // the rules above and below the parties
#let caption-pad = 7.2pt                   // the parties stand this far from the rules
#let sig-indent = 3.25in                   // the signer's lines
#let service-indent = 0.5in                // the parties served
#let brief-marker = "<!-- BRIEF -->"

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/wieb.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                     // WIEB-FORM-002: double-spaced body (24 pt pitch; see README)
#let pitch-single = 13.8pt                 // caption, titles, headings, block quotations, signature, service list: single-spaced
#let court-gap = 14.4pt                    // court title to the caption, the caption to the title
#let title-gap = 9.6pt                     // a title to the text under it
#let h1-above = 14.4pt
#let h1-below = 7.2pt
#let h2-above = 12pt
#let h2-below = 7.2pt
#let h3-above = 9.6pt
#let h3-below = 6pt
#let quote-gap = 12pt                      // above and below a block quotation
#let sig-above = 14.4pt                    // the text to "Dated:", and "Dated:" to the signer
#let sig-gap = 9.6pt                       // "Respectfully submitted," to "/s/"
#let signer-gap = 2.4pt                    // "/s/" to the signer's lines
#let service-gap = 12pt                    // between the non-ECF parties served

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = unloose(md(s))

#let need(meta, key) = {
  if key not in meta { panic("wieb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wieb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-pitch line (a paragraph of its own); "" is a blank line.
#let sline(above: 0pt, below: 0pt, left: 0pt, centered: false, sticky: false, c) = if c == "" {
  block(width: 100%, height: pitch-single, above: above, below: below, sticky: sticky)
} else {
  block(width: 100%, above: above, below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set align(center) if centered
    pad(left: left, par(first-line-indent: 0pt, if type(c) == str { inl(c) } else { c }))
  })
}

#let slines(items, left: 0pt) = for i in items { sline(left: left, i) }

/// A body paragraph on the body pitch, its first line indented.
#let body-par(above: 0pt, sticky: false, c) = block(width: 100%, above: above, below: 0pt, sticky: sticky, par(c))

// ---------------------------------------------------------------------------
// Caption (FRBP 7010 applies to adversary matters; LR 9013-1(a): the title describes the relief)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let d = need(meta, "debtor")
  let p = need(meta, "plaintiff")
  let df = need(meta, "defendant")
  for l in ([UNITED STATES BANKRUPTCY COURT], [EASTERN DISTRICT OF WISCONSIN]) { sline(centered: true, strong(l)) }
  let parties-left = {
    slines(p.names)
    sline(left: designation-indent, p.designation)
    sline("")
    sline(left: versus-indent, "v.")
    sline("")
    slines(df.names)
    sline(left: designation-indent, df.designation)
  }
  // the adversary number beside "v."
  let parties-right = { for _ in range(p.names.len() + 2) { sline("") }; sline(need(meta, "adversary_number")) }
  block(width: 100%, above: court-gap, below: 0pt, grid(
    columns: (caption-col, caption-gutter, 1fr),
    stroke: (x, y) => if y == 1 { (top: caption-rule, bottom: caption-rule) },
    inset: (x, y) => if y == 1 { (top: caption-pad, bottom: caption-pad) } else { (bottom: caption-pad) },
    { sline("In re:"); sline(""); sline(left: caption-indent, d.name); sline(left: caption-indent, d.designation) },
    [],
    { sline(""); sline(""); sline(d.case_number); sline(d.chapter) },
    parties-left, [], parties-right,
  ))
}

#let title-block(above: 0pt, s) = sline(above: above, below: title-gap, centered: true, sticky: true, strong(inl(s)))

// ---------------------------------------------------------------------------
// Signature block (LR 5005-2(a)(1)(A): "/s/" followed by the printed name)
// ---------------------------------------------------------------------------

/// Single-spaced, kept on one page: "Dated:", then each signer at `sig-indent`.
#let signature(meta, respectfully: true) = {
  let dated = need(meta, "dated")
  let signers = need(meta, "signers")
  block(breakable: false, width: 100%, above: sig-above, below: 0pt, {
    sline([Dated: #dated])
    for s in signers {
      if respectfully {
        sline(above: sig-above, left: sig-indent, "Respectfully submitted,")
        sline(above: sig-gap, left: sig-indent, [/s/ #s.signer])
      } else {
        sline(above: sig-above, left: sig-indent, [/s/ #s.signer])
      }
      for (i, l) in s.lines.enumerate() { sline(above: if i == 0 { signer-gap } else { 0pt }, left: sig-indent, l) }
    }
  })
}

// ---------------------------------------------------------------------------
// Notice of motion (LR 9014-1(a)(1)(A) and (a)(2)): the objection period is stated, and the
// notice says the court may act without a hearing if no timely objection is filed.
// ---------------------------------------------------------------------------

#let notice(meta) = {
  let days = need(meta, "objection_days")
  if type(days) != int or days < 14 {
    panic("wieb-motion-brief: `objection_days` must be an integer of at least 14 (LR 9014-1(a)(2)(A))")
  }
  title-block("Notice of Motion")
  body-par[PLEASE TAKE NOTICE that #need(meta, "movants") #need(meta, "notice_verb") the attached #inl(need(meta, "title")) and #inl(need(meta, "brief_title")) (together, the "Motion").]
  body-par[If you want the court to consider your views on the Motion, or want a hearing, you must file and serve a written objection no later than #days days after the date of service of this notice (LR 9014-1(a)(2)(A)). An objection must be filed with the Clerk of the Bankruptcy Court and served on the movant.]
  body-par[Absent a timely filed objection, the court may grant the relief requested without a hearing (LR 9014-1(a)(2)(B)). If no objection is timely filed, the movant will file a proposed order as required by LR 9014-2. If a timely objection is filed, the court may schedule a hearing, and the Clerk will give notice of the hearing (LR 9014-1(a)(3)).]
}

// ---------------------------------------------------------------------------
// Certificate of service (LR 9013-2(a): method, date, and person served; LR 7005-1)
// ---------------------------------------------------------------------------

#let certificate(meta) = {
  let c = need(meta, "certificate")
  let dated = need(meta, "dated")
  title-block("Certificate of Service")
  body-par[I hereby certify that on #dated the #inl(need(meta, "title")) and the #inl(need(meta, "brief_title")) were electronically filed in this case and served upon the following parties using the CM/ECF system:]
  slines(c.ecf, left: service-indent)
  body-par[I further certify that on the same date I mailed the same document(s) by United States Mail to the following non-ECF participants:]
  for (i, n) in c.non_ecf.enumerate() {
    block(width: 100%, breakable: false, above: if i == 0 { 0pt } else { service-gap }, below: 0pt,
      slines((n.name,) + n.lines, left: service-indent))
  }
  signature(meta, respectfully: false)
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let wieb-motion-brief(meta, md-body) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter", margin: page-margin,
    // The page number centered at the foot of every page, in a single-pitch line box that ends footer-distance
    // above the page edge.
    footer-descent: page-margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  show regex("[§¶]+ \\S+"): it => box(it)

  // Numbered paragraphs (a markdown list): the number at the indent in a box, the text from 1 in, its other lines
  // at the margin (docx: a tab).
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      if item.has("number") and item.number != none { n = item.number }
      block(width: 100%, above: 0pt, below: 0pt, par[#box(width: number-box, [#n.])#unloose(item.body)])
      n += 1
    }
  }
  // Block quotations: single-spaced, indented on both sides.
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap, pad(x: quote-inset, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    it.body
  }))
  // Headings at the type size on the single pitch, kept with the text after them: level 1 centered bold, level 2
  // bold, level 3 italic (docx: the same paragraphs).
  show heading: it => {
    let (above, below) = if it.level == 1 { (h1-above, h1-below) } else if it.level == 2 { (h2-above, h2-below) } else { (h3-above, h3-below) }
    block(width: 100%, above: above, below: below, sticky: true, {
      set text(size: type-size, ..edges(pitch-single))
      set par(first-line-indent: 0pt)
      if it.level == 1 { align(center, text(weight: "bold", it.body)) }
      else if it.level == 2 { text(weight: "bold", it.body) }
      else { text(style: "italic", it.body) }
    })
  }

  let parts = md-body.split(brief-marker)
  if parts.len() != 2 {
    panic("wieb-motion-brief: the body must contain exactly one `" + brief-marker + "` line between the motion and the brief")
  }
  let (motion, brief) = (parts.at(0), parts.at(1))

  // 1. Notice of motion (first page).
  notice(meta)
  signature(meta)
  pagebreak()

  // 2. Motion.
  caption(meta)
  title-block(above: court-gap, need(meta, "title"))
  md(motion)
  signature(meta)
  pagebreak()

  // 3. Brief in support: its own caption and title.
  caption(meta)
  title-block(above: court-gap, need(meta, "brief_title"))
  md(brief)
  signature(meta)
  pagebreak()

  // 4. Certificate of service.
  certificate(meta)
}
