// Memorandum in support of a dispositive motion, U.S. District Court for the District of Wyoming (wyd).
// Rules: D. Wyo. LR 7.1(b)(2)(A)-(B) (brief for a dispositive motion; 25-page limit); LR 10.1(a) (typed, double
// spaced, one side, 8 1/2 x 11, one-inch margins on all sides, not less than 12 point) and 10.1(b) (caption per
// Fed. R. Civ. P. 10(a) plus an attorney information block); Fed. R. Civ. P. 10(a). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/eb-garamond/; no system font is ever used
#let type-size = 13pt                   // LR 10.1(a): not less than 12 point (13 pt, as in the complaint template)
#assert(type-size >= 12pt, message: "wyd-motion-brief: D. Wyo. LR 10.1(a) requires type not less than 12 point")
#let page-w = 8.5in                     // LR 10.1(a): 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LR 10.1(a): one inch margin on all sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.05em              // double spacing, as in the complaint template (README)
#let single-leading = 0.3em             // single spacing for the attorney block, caption, service list, signature
#let para-indent = 0.5in
#let caption-left = 3.1in               // party column of the caption
#let caption-mid = 0.35in               // ")" column
#let page-limit = 25                    // LR 7.1(b)(2)(B): briefs in support of dispositive motions
#let court-name = ("UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF WYOMING")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wyd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for italic case names, *pro hac vice*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// First page: attorney information block (LR 10.1(b)), court name, caption, title
// ---------------------------------------------------------------------------

#let attorney-block(meta) = {
  let cols = meta.attorney.map(group => line-stack(group))
  grid(columns: meta.attorney.map(_ => 1fr), column-gutter: 0.3in, ..cols)
}

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt)
  v(1.5em)
  align(center, text(weight: "bold", court-name.at(0)))
  v(single-leading)
  align(center, text(weight: "bold", court-name.at(1)))
}

/// Caption (Fed. R. Civ. P. 10(a)): party names with designations on the left, a ")" column, and the case
/// number on the right, level with the separator ("v.") between the parties, as in the filed exemplar.
/// Designations ("Plaintiff," "Defendant.") are indented one inch, as in the exemplar.
#let caption(meta) = {
  let sep = meta.caption.at("separator", default: "v.")
  let rows = ()   // (text, is-designation)
  let sep-row = none
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      if sep-row == none { sep-row = rows.len() + 1 }
      rows += (("", false), (sep, false), ("", false))
    }
    for n in p.names { rows.push((n, false)) }
    rows.push((p.designation, true))
  }
  let right = ([],) * rows.len()
  right.at(if sep-row == none { 0 } else { sep-row }) = text("Case No. " + meta.case_number)
  let cells = ()
  for (i, r) in rows.enumerate() {
    let cell = inl(r.at(0))
    if r.at(1) { cell = pad(left: 1in, cell) }
    cells += (cell, [)], right.at(i))
  }
  set par(leading: single-leading, spacing: 0pt, justify: false)
  grid(
    columns: (caption-left, caption-mid, 1fr),
    row-gutter: single-leading,
    ..cells,
  )
}

#let first-page(meta) = {
  attorney-block(meta)
  court-title()
  v(1.5em)
  caption(meta)
  v(1.5em)
  block(width: text-width, align(center, text(weight: "bold", upper(meta.title))))
  v(body-leading * 0.5)
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs (unnumbered, first-line indent), numbered list
// ---------------------------------------------------------------------------

/// Headings. A heading that starts with a roman numeral (level 1) or a letter (level 2) is set flush with a
/// hanging number, as in the filed exemplar; any other heading (CONCLUSION) is centered and bold.
#let heading(level, title) = {
  let num = title.match(regex("^([IVXL]+\\.|[A-Z]\\.)[ \\t]+([\\s\\S]*)$"))
  v(body-leading * 0.5)
  if num != none {
    let inset = if level == 1 { 0pt } else { para-indent }
    let gap = if level == 1 { 0.5in } else { 0.4in }
    block(width: text-width, sticky: true, pad(left: inset, grid(
      columns: (gap, 1fr),
      text(weight: "bold", num.captures.at(0)),
      text(weight: "bold", num.captures.at(1)),
    )))
  } else {
    block(width: text-width, sticky: true,
      align(center, text(weight: "bold", title)))
  }
  v(body-leading * 0.5)
}

/// Walks the markdown body. Blank-line-separated chunks: a `#` heading, a numbered list (kept as written,
/// hanging indent, used for the relief requested), or a paragraph (first-line indent, not numbered).
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      heading(level, t.slice(level).trim())
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // A list item may run over several lines; a line that does not start with a number continues it.
      let parts = ()
      for line in t.split(regex("\\r?\\n")).filter(l => l.trim() != "") {
        let m = line.match(regex("^(\\d+)\\.[ \\t]+([\\s\\S]*)$"))
        if m != none {
          parts.push((m.captures.at(0), m.captures.at(1)))
        } else {
          parts.at(-1) = (parts.at(-1).at(0), parts.at(-1).at(1) + " " + line.trim())
        }
      }
      for it in parts {
        block(width: text-width, pad(left: para-indent, grid(columns: (0.35in, 1fr), [#it.at(0).], {
          set par(leading: body-leading)
          inl(it.at(1))
        })))
      }
    } else {
      block(width: text-width, {
        set par(leading: body-leading)
        h(para-indent)
        inl(t)
      })
    }
  }
}

/// Date line, "Respectfully submitted," and the signature block (right half of the page, as in the exemplar).
#let signature-block(meta) = {
  v(body-leading)
  block(width: text-width, breakable: false, {
    [#meta.dated]
    v(body-leading)
    pad(left: 2.5in, {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(single-leading * 2)
      line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines)
      v(single-leading * 2)
      line-stack(meta.signature.role)
    })
  })
}

/// Certificate of service (FRCP 5(b)): the statement, the persons served, and the signer.
#let certificate(meta) = {
  let c = meta.certificate
  v(body-leading)
  // One unbreakable block: the statement, the service list and the signature stay on one page.
  block(width: text-width, breakable: false, {
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(body-leading * 0.5)
    set par(leading: body-leading)
    h(para-indent)
    inl(c.text)
    v(body-leading * 0.5)
    pad(left: para-indent, line-stack(c.served))
    v(body-leading)
    pad(left: 2.5in, line-stack(("/s/ " + c.signer,)))
  })
}

#let wyd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, first-line-indent: 0pt, justify: false)

  first-page(meta)
  body-chunks(body)
  signature-block(meta)
  certificate(meta)

  // LR 7.1(b)(2)(B): the brief, counted from the caption page, may not exceed the page limit.
  context {
    let n = counter(page).final().first()
    assert(n <= page-limit, message: "wyd-motion-brief: D. Wyo. LR 7.1(b)(2)(B) limits this brief to " + str(page-limit) + " pages; the render is " + str(n))
  }
}
