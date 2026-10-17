// U.S. Bankruptcy Court, E.D. Wis.: motion with brief in support (FRBP 9013; LR 9013-1, 9014-1).
//
// Rule-driven and content-agnostic. Requirement IDs refer to ../README.md.
// No case-specific text, no coordinates measured off the filed exemplar, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").
// The body is split at the line "%%BRIEF%%": above it is the motion, below it the brief.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // LR 9004-1(a) allows any proportional font; Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                      // WIEB-FORM-001: proportional font not smaller than 12-point.
#let body-leading = 1.345em                // WIEB-FORM-002: double-spaced body (about 24 pt pitch; see README).
#let single-leading = 0.55em               // caption, headings, blocks, notice: single-spaced.
#let page-margin = 1in                     // WIEB-FORM-003: one-inch margin on all sides.
#let para-indent = 0.5in
#let brief-marker = "%%BRIEF%%"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

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

/// A stack of lines, one per list entry, each rendered as inline markdown.
#let lines-of(items, spacing: 0.55em) = stack(
  dir: ttb, spacing: spacing,
  ..items.map(s => inl(s)),
)

// ---------------------------------------------------------------------------
// Caption (FRBP 7010 applies to adversary matters; LR 9013-1(a): the title describes the relief)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set par(leading: single-leading)
  let d = need(meta, "debtor")
  let p = need(meta, "plaintiff")
  let df = need(meta, "defendant")
  align(center)[
    #strong[UNITED STATES BANKRUPTCY COURT] \
    #strong[EASTERN DISTRICT OF WISCONSIN]
  ]
  v(1.2em)
  grid(
    columns: (1fr, 1fr), column-gutter: 0.4in,
    stack(dir: ttb, spacing: 0.3em,
      [In re:],
      v(0.3em),
      pad(left: 0.5in, inl(d.name)),
      pad(left: 0.5in, [#d.designation]),
    ),
    align(left + horizon, stack(dir: ttb, spacing: 0.3em,
      [#d.case_number],
      [#d.chapter],
    )),
  )
  v(0.6em)
  line(length: 100%, stroke: 0.6pt)
  v(0.6em)
  grid(
    columns: (1fr, 1fr), column-gutter: 0.4in,
    stack(dir: ttb, spacing: 0.3em,
      lines-of(p.names),
      pad(left: 2.2in, [#p.designation]),
      v(0.9em),
      pad(left: 0.9in, [v.]),
      v(0.9em),
      lines-of(df.names),
      pad(left: 2.2in, [#df.designation]),
    ),
    align(left + horizon, [#need(meta, "adversary_number")]),
  )
  v(0.6em)
  line(length: 100%, stroke: 0.6pt)
  v(1.2em)
}

#let title-block(s) = {
  set par(leading: single-leading)
  align(center)[#strong[#inl(s)]]
  v(0.8em)
}

// ---------------------------------------------------------------------------
// Signature block (LR 5005-2(a)(1)(A): "/s/" followed by the printed name)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let dated = need(meta, "dated")
  let signers = need(meta, "signers")
  block(breakable: false, width: 100%)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #v(1.2em)
    Dated: #dated
    #v(1.2em)
    #for s in signers {
      pad(left: 3.25in, block(breakable: false)[
        Respectfully submitted,
        #v(0.8em)
        /s/ #s.signer
        #v(0.2em)
        #lines-of(s.lines)
        #v(1.2em)
      ])
    }
  ]
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
  [
    #title-block("Notice of Motion")
    #set par(first-line-indent: para-indent)
    PLEASE TAKE NOTICE that #need(meta, "movants") #need(meta, "notice_verb") the attached #inl(need(meta, "title")) and #inl(need(meta, "brief_title")) (together, the "Motion").

    If you want the court to consider your views on the Motion, or want a hearing, you must file and serve a written objection no later than #days days after the date of service of this notice (LR 9014-1(a)(2)(A)). An objection must be filed with the Clerk of the Bankruptcy Court and served on the movant.

    Absent a timely filed objection, the court may grant the relief requested without a hearing (LR 9014-1(a)(2)(B)). If no objection is timely filed, the movant will file a proposed order as required by LR 9014-2. If a timely objection is filed, the court may schedule a hearing, and the Clerk will give notice of the hearing (LR 9014-1(a)(3)).
  ]
}

// ---------------------------------------------------------------------------
// Certificate of service (LR 9013-2(a): method, date, and person served; LR 7005-1)
// ---------------------------------------------------------------------------

#let certificate(meta) = {
  let c = need(meta, "certificate")
  let signers = need(meta, "signers")
  let dated = need(meta, "dated")
  [
    #title-block("Certificate of Service")
    #set par(first-line-indent: para-indent)
    I hereby certify that on #dated the #inl(need(meta, "title")) and the #inl(need(meta, "brief_title")) were electronically filed in this case and served upon the following parties using the CM/ECF system:
    #pad(left: 0.5in)[#for n in c.ecf [#n \ ]]
    I further certify that on the same date I mailed the same document(s) by United States Mail to the following non-ECF participants:
    #for n in c.non_ecf [
      #pad(left: 0.5in, block(breakable: false)[#n.name \ #lines-of(n.lines)])
      #v(0.4em)
    ]
    #set par(first-line-indent: 0pt)
    #v(1em)
    Dated: #dated
    #v(1.2em)
    #for s in signers {
      pad(left: 3.25in, block(breakable: false)[
        /s/ #s.signer
        #v(0.2em)
        #lines-of(s.lines)
      ])
    }
  ]
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let wieb-motion-brief(meta, md) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter", margin: page-margin,
    numbering: "1",
    footer: context align(center)[#text(size: type-size)[#counter(page).display()]],
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: body-leading, first-line-indent: 0pt)
  set enum(indent: para-indent, body-indent: 0.4em, numbering: "1.", spacing: body-leading)

  show heading.where(level: 1): it => block(above: 1.2em, below: 0.6em, width: 100%,
    align(center, text(size: type-size, weight: "bold")[#it.body]))
  show heading.where(level: 2): it => block(above: 1.0em, below: 0.6em, width: 100%,
    text(size: type-size, weight: "bold")[#it.body])
  show heading.where(level: 3): it => block(above: 0.8em, below: 0.5em, width: 100%,
    text(size: type-size, style: "italic")[#it.body])

  let parts = md.split(brief-marker)
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
  title-block(need(meta, "title"))
  set par(first-line-indent: para-indent)
  cmarker.render(motion, raw-typst: false, smart-punctuation: true, h1-level: 1)
  signature(meta)
  pagebreak()

  // 3. Brief in support: its own caption and title.
  caption(meta)
  title-block(need(meta, "brief_title"))
  set par(first-line-indent: para-indent)
  cmarker.render(brief, raw-typst: false, smart-punctuation: true, h1-level: 1)
  signature(meta)
  pagebreak()

  // 4. Certificate of service.
  certificate(meta)
}
