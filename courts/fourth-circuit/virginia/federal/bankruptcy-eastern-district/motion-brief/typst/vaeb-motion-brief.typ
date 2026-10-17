// Motion with memorandum for the United States Bankruptcy Court, E.D. Virginia (vaeb).
// Rules: FRBP 9013 (form and service of motions: grounds stated with particularity; relief sought),
// LBR 9013-1(C) (grounds and relief), 9013-1(F) (memorandum of points and authorities, which may be combined
// with the motion), LBR 7056-1(C) (summary judgment: a "Statement of Undisputed Material Facts" in numbered
// paragraphs), LBR 5005-1(C) (letter size, one side, top margin of 1 1/2 inches, counsel on page 1, debtor,
// case number, chapter and adversary number), FRBP 7010 and Fed. R. Civ. P. 10(a) (caption). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"         // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; no E.D. Va. rule names a typeface (README.md)
#let type-size = 12pt                    // convention: 12 point, as in both filed exemplars
#let body-leading = 1.345em              // double spacing: Liberation Serif's line box is 0.655em, so this gives a 24 pt pitch at 12 pt
#let single-leading = 0.5em              // single spacing for counsel, caption, signature, service list: about 13.8 pt
#let para-indent = 0.5in                 // first-line indent of body paragraphs
#let page-w = 8.5in                      // LBR 5005-1(C)(3): letter size
#let page-h = 11in
#let top-margin = 1.5in                  // LBR 5005-1(C)(3): top margin not less than 1 1/2 inches
#let bottom-margin = 1in
#let left-margin = 1in
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let caption-left = 3.4in                // width of the party column of the caption
#let caption-paren = 0.3in               // width of the column of ")" marks
#let caption-right = text-width - caption-left - caption-paren

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vaeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline or block markdown (italic names, *Counsel for ...*).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced caption, counsel or signature line.
#let single(c) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  c
}

// ---------------------------------------------------------------------------
// Page one: counsel (LBR 5005-1(C)(5)), court, caption (FRBP 7010, Form 416), title
// ---------------------------------------------------------------------------

#let lines(items) = single(stack(dir: ttb, spacing: single-leading, ..items.map(md)))

#let counsel-block(meta) = lines(meta.counsel)

#let court-title(meta) = align(center, single(stack(dir: ttb, spacing: single-leading,
  text(weight: "bold", "IN THE UNITED STATES BANKRUPTCY COURT"),
  text(weight: "bold", "FOR THE EASTERN DISTRICT OF VIRGINIA"),
  meta.division,
)))

/// The caption as a grid: the party column, a column of ")" marks, and the bankruptcy and adversary
/// numbers. Every row is one grid row, so the three columns stay level line for line.
#let caption(meta) = {
  let left = ([In re:], [#h(0.5in)#meta.debtor.name,], [#h(0.5in)Debtor.], [])
  let debtor-rows = left.len()
  let party-start = debtor-rows
  for (k, p) in meta.parties.enumerate() {
    if k > 0 { left.push([#h(0.25in)v.]) }
    for n in p.names { left.push(md(n)) }
    left.push([#h(0.5in)#p.designation])
  }
  let adversary-row = party-start + 1
  let right = range(left.len()).map(i => {
    if i == 0 { [Chapter #meta.debtor.chapter] }
    else if i == 1 { [Case No. #meta.debtor.case_number] }
    else if i == adversary-row { [Adversary Proceeding] }
    else if i == adversary-row + 1 {
      if "adversary_number" in meta and meta.adversary_number != "" { [Case No. #meta.adversary_number] }
      else { [Case No. #underline[#h(1.3in)]] }
    }
    else { [] }
  })
  let cells = ()
  for i in range(left.len()) {
    cells.push(left.at(i))
    cells.push([)])
    cells.push(pad(left: 0.15in, right.at(i)))
  }
  single(grid(
    columns: (caption-left, caption-paren, caption-right),
    row-gutter: single-leading,
    ..cells,
  ))
}

#let cover(meta) = {
  counsel-block(meta)
  v(body-leading)
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Headings, body, signature and service
// ---------------------------------------------------------------------------

/// Heading levels: 1 centered bold capitals; 2 centered bold (the subtitle of a count); 3 bold italic.
#let heading-block(c) = block(width: 100%, above: body-leading * 0.5, below: body-leading * 0.5, sticky: true, c)

/// One chunk of body markdown. Paragraphs are numbered (FRCP 10(b)) only under the sections the
/// frontmatter names in `numbered_sections`; the jurisdiction, parties, background and count sections
/// are numbered, the introduction and the prayer are not.
#let body-chunk(t, numbered, para-counter) = {
  if numbered {
    para-counter.step()
    block(width: 100%, above: 0pt, below: body-leading, context [#h(para-indent)#para-counter.display().#h(0.2in)#md(t)])
  } else {
    block(width: 100%, above: 0pt, below: body-leading, [#h(para-indent)#md(t)])
  }
}

#let render-body(body, meta, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let numbered-sections = meta.at("numbered_sections", default: ()).map(s => upper(s))
  let in-numbered = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).text.len()
      let heading-text = upper(t.trim("#", at: start, repeat: true).trim())
      if level == 1 { in-numbered = numbered-sections.contains(heading-text) }
      heading-block(md(t))
    } else if t.starts-with("|") {
      // A table (FRBP 7010 caption rules do not apply; this is body text): single-spaced, boxed rows.
      block(width: 100%, above: 0pt, below: body-leading, breakable: false,
        pad(left: para-indent, {
          set table(stroke: 0.5pt, inset: 5pt, align: left)
          set par(leading: single-leading, spacing: 0pt)
          md(t)
        }))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list (the prayer's items, the sub-items of a fact): lettered (a), (b), ...
      set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set par(leading: body-leading)
      md(t)
      v(body-leading * 0.5)
    } else {
      set par(leading: body-leading, spacing: 0pt)
      body-chunk(t, in-numbered, para-counter)
    }
  }
}

/// The signature block: date (if given) at left; firm, "By: /s/" and the signer at right.
#let signature-block(meta) = block(width: 100%, breakable: false, above: body-leading, grid(
  columns: (2.7in, 1fr),
  column-gutter: 0.2in,
  if "date" in meta and meta.date != none { [Date: #meta.date] } else { [] },
  single(stack(dir: ttb, spacing: single-leading,
    [Respectfully submitted,],
    v(body-leading * 0.5),
    if meta.signature.firm.len() > 0 { stack(dir: ttb, spacing: single-leading, ..meta.signature.firm.map(md)) } else { [] },
    if meta.signature.firm.len() > 0 { [By: /s/ #meta.signature.signer] } else { [/s/ #meta.signature.signer] },
    stack(dir: ttb, spacing: single-leading, ..meta.signature.lines.map(md)),
  )),
))

/// Certificate of service (FRBP 7005; Fed. R. Civ. P. 5(b)): form wording, the service list from the frontmatter.
#let service-block(meta) = if "service" in meta and meta.service != none {
  let s = meta.service
  block(width: 100%, breakable: true, above: body-leading, {
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(body-leading * 0.5)
    set par(leading: body-leading, spacing: 0pt)
    [#h(para-indent) I hereby certify that on the #s.date, I caused a copy of the foregoing to be served by electronic means through the ECF system#if s.mailed.len() > 0 [ and a copy mailed to the following:] else [.]]
    if s.mailed.len() > 0 {
      v(body-leading * 0.5)
      grid(columns: (1fr, 1fr), column-gutter: 0.3in, row-gutter: single-leading * 2,
        ..s.mailed.map(addr => pad(left: 0.5in, lines(addr))))
    }
    v(body-leading)
    single(align(right, block(width: 3.2in, lines(("/s/ " + s.signer, s.signer)))))
  })
} else { none }

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let vaeb-motion-brief(meta, body) = {
  // Tier 1 (the rules' mandated form): every element LBR 5005-1(C) and FRBP 7010 name must be present.
  assert(meta.kind == "motion-brief", message: "vaeb-motion-brief: frontmatter kind must be motion-brief")
  assert("counsel" in meta and meta.counsel.len() > 0, message: "LBR 5005-1(C)(5): counsel, State Bar number and address are required on page 1")
  assert("division" in meta, message: "FRBP 7010 (Form 416): the division of the court is required in the caption")
  assert("debtor" in meta and "name" in meta.debtor and "chapter" in meta.debtor and "case_number" in meta.debtor,
    message: "LBR 5005-1(C)(2): the debtor's name, chapter and case number must appear on the document")
  assert("parties" in meta and meta.parties.len() > 0, message: "FRCP 10(a): the caption must name the parties")
  assert("title" in meta, message: "FRCP 10(a): the title of the paper is required")
  assert(upper(body).contains("WHEREFORE"), message: "LBR 9013-1(C): the motion must state the relief sought")
  assert(not meta.at("summary_judgment", default: false) or upper(body).contains("STATEMENT OF UNDISPUTED MATERIAL FACTS"),
    message: "LBR 7056-1(C): a summary judgment memorandum must include a Statement of Undisputed Material Facts")
  assert(not meta.at("summary_judgment", default: false) or meta.at("numbered_sections", default: ()).len() > 0,
    message: "LBR 7056-1(C): the Statement of Undisputed Material Facts must be in numbered paragraphs")

  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(text(weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", style: "italic", it.body))

  cover(meta)
  render-body(body, meta, para-counter)
  signature-block(meta)
  service-block(meta)
}
