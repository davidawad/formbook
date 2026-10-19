// Memorandum of law in support of a motion for the U.S. District Court for the Central District of Illinois (ilcd).
// Rules: Civil LR 5.1 (format: letter paper, one-inch margins, numbered pages, double spacing, 12- or 14-point body,
// footnotes 10-point or larger), 7.1(B)(1) (memorandum identifies the rule under which the motion is filed),
// 7.1(B)(4) (double-spaced, 15 pages or 7,000 words; certificate of compliance), 40.1(E)(1) (division in the caption),
// 5.11(A) (s/name signatures), 11.1 (telephone number and typed name); Fed. R. Civ. P. 12(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; LR 5.1(B)(2) asks for a plain roman style
#let type-size = 12pt                   // LR 5.1(B)(2): body text 12-point or 14-point
#let footnote-size = 10pt               // LR 5.1(B)(2): footnote text no smaller than 10-point
#let page-margin = 1in                  // LR 5.1(A)
#let body-leading = 1.345em             // LR 5.1(B)(1): double spacing (0.655em line box + 1.345em = 2.0em = 24 pt at 12 pt)
#let single-leading = 0.5em             // single spacing: caption, counsel, signature, block quotations, footnotes
#let gap = 2em                          // one blank double-spaced line
#let para-indent = 0.5in                // first-line indent of body text
#let caption-left = 3.2in               // party column of the caption
#let paren-col = 0.3in                  // column of ")" marks
#let designation-indent = 1.25in        // "Plaintiff," and "v." sit under the party names
#let counsel-indent = 3.25in            // counsel block and signature block start at the right half of the page
#let page-limit = 15                    // LR 7.1(B)(4)(a): a memorandum must not exceed 15 pages unless it complies with the word limit
#let word-limit = 7000                  // LR 7.1(B)(4)(b)(1): the type-volume alternative

// Table of authorities: groups in order, with the heading each prints under.
#let toa-groups = (
  (kind: "case", title: "Cases"),
  (kind: "constitution", title: "Constitutional Provisions"),
  (kind: "statute", title: "Statutes"),
  (kind: "regulation", title: "Regulations"),
  (kind: "rule", title: "Rules"),
  (kind: "other", title: "Other Authorities"),
)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilcd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))

/// Words in the memorandum body, counted from the markdown: link targets, footnote markers and the footnote
/// labels are not words; headings, footnote text and quotations are (LR 7.1(B)(4)(d)). The cover, tables and
/// signature block are generated outside the body and are not counted. An approximation: a draft for the
/// filer's word processor count, which the certificate may rely on (LR 7.1(B)(4)(c)).
#let word-count(md) = {
  let s = md.replace(regex("\\((toa|https?):[^)]*\\)"), "")
  s = s.replace(regex("\\[\\^[^\\]]*\\]:?"), "")
  s.replace(regex("\\s+"), " ").split(" ").filter(w => w.match(regex("[A-Za-z0-9]")) != none).len()
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper, counsel
// ---------------------------------------------------------------------------

#let court-title(meta) = stack(dir: ttb, spacing: single-leading,
  align(center, text(weight: "bold", [UNITED STATES DISTRICT COURT])),
  align(center, text(weight: "bold", [CENTRAL DISTRICT OF ILLINOIS])),
  // LR 40.1(E)(1): the caption must identify the division in which the case is pending.
  align(center, text(weight: "bold", upper(meta.division))),
)

/// One ")" mark per line of a caption row: a long party name wraps onto more lines, and its row gets one mark per line.
#let paren-cell(content) = context {
  let h = measure(width: caption-left, content).height
  let n = int(calc.max(1, calc.round((h + single-leading).to-absolute().pt() / (0.655em + single-leading).to-absolute().pt())))
  align(right, stack(dir: ttb, spacing: single-leading, ..range(n).map(_ => [)])))
}

/// Caption: party names with ")" marks in their own column; the case number at the right, spanning the rows.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push(pad(left: designation-indent, [v.])) }
    for n in p.names { rows.push(inl(n)) }
    rows.push(pad(left: designation-indent, inl(p.designation)))
  }
  let case-cell = grid.cell(
    rowspan: rows.len(),
    align: horizon,
    pad(left: 0.15in, [Case No. #meta.case_number]),
  )
  // Row 1 carries the spanning cell; the later rows fill the free columns 1 and 2 only.
  let cells = ()
  for (k, r) in rows.enumerate() {
    cells.push(r)
    cells.push(paren-cell(r))
    if k == 0 { cells.push(case-cell) }
  }
  set par(leading: single-leading, spacing: 0pt)
  grid(
    columns: (caption-left, paren-col, 1fr),
    row-gutter: single-leading,
    ..cells,
  )
}

#let cover(meta) = {
  court-title(meta)
  v(gap)
  caption(meta)
  v(gap)
  align(center, text(weight: "bold", upper(meta.brief_title)))
  v(gap * 2)
  // The counsel block of the cover, in the right half of the page (LR 11.1 is met in the signature block).
  pad(left: counsel-indent, stack(dir: ttb, spacing: gap,
    ..meta.counsel.map(g => line-stack(g.names + g.lines)))
  )
}

// ---------------------------------------------------------------------------
// Signature and certificate
// ---------------------------------------------------------------------------

/// "Dated" at the left; "Respectfully submitted," and the firm at the right; "/s/ name" and the signer's
/// name, address, telephone and email typed below (LR 5.11(A)(2), LR 11.1).
#let signature-block(meta) = block(breakable: false, width: 100%, above: body-leading, below: 0pt,
  grid(
    columns: (counsel-indent, 1fr),
    [Dated: #meta.date],
    {
      line-stack(("Respectfully submitted,",))
      v(gap * 0.5)
      line-stack(meta.signature.firm)
      v(gap * 0.5)
      line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  ),
)

/// Certificate of compliance with the type-volume limitation (LR 7.1(B)(4)(c)). The count is the template's
/// count of the body (see word-count); the filer must confirm it with the word processor before filing.
#let certificate(meta, words) = {
  pagebreak()
  heading(level: 1, outlined: true)[Certificate of Compliance]
  set par(leading: body-leading, first-line-indent: para-indent)
  [I certify pursuant to Civil Local Rule 7.1(B)(4)(c) that this memorandum complies with the type-volume limitation. This memorandum contains #words words, including headings, footnotes, and quotations, and excluding the cover page, tables, and signature block.]
  block(breakable: false, width: 100%, above: body-leading, pad(left: counsel-indent,
    line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines.slice(0, 1))))
}

// ---------------------------------------------------------------------------
// Tables: contents (generated from headings) and authorities (generated from the links in the body)
// ---------------------------------------------------------------------------

/// Pages on which a key's link appears, as the body's page numbers (the body restarts at 1). Seven or more: "passim".
#let pages-of(key) = context {
  let hits = query(link).filter(l => type(l.dest) == str and l.dest == "toa:" + key)
  let ps = hits.map(l => counter(page).at(l.location()).first()).dedup().sorted()
  if ps.len() >= 7 { [passim] } else { ps.map(str).join(", ") }
}

#let toa(meta, body) = {
  align(center, text(weight: "bold", [TABLE OF AUTHORITIES]))
  v(gap)
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for g in toa-groups {
    // Only authorities the body cites appear: a key is cited when its link is in the body.
    let keys = meta.authorities.keys().filter(k => meta.authorities.at(k).kind == g.kind and body.contains("(toa:" + k + ")"))
    keys = keys.sorted(key: k => lower(meta.authorities.at(k).name))
    if keys.len() > 0 {
      block(width: 100%, above: gap, below: single-leading, sticky: true, text(weight: "bold", g.title))
      for k in keys {
        let a = meta.authorities.at(k)
        let name = if g.kind == "case" { text(style: "italic", a.name) } else { a.name }
        let cite = if a.cite != "" { [, #a.cite] } else { [] }
        block(width: 100%, above: 0pt, below: single-leading,
          par(hanging-indent: 0.5in, [#name#cite #box(width: 1fr, repeat[.]) #pages-of(k)]))
      }
    }
  }
}

/// The contents: level 1 to level 3 headings, with dot leaders and the body's page numbers.
#let toc() = {
  align(center, text(weight: "bold", [TABLE OF CONTENTS]))
  v(gap)
  set par(leading: single-leading, spacing: 0pt)
  show outline.entry: it => block(above: 0pt, below: single-leading, it)
  outline(title: none, depth: 3, indent: 1.5em)
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

#let ilcd-motion-brief(meta, body) = {
  assert("division" in meta, message: "ilcd-motion-brief: LR 40.1(E)(1) requires the division in the caption (frontmatter: division)")
  let words = word-count(body)

  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Cover: no page number (the cover is the first page of the document).
  cover(meta)

  // Front matter: contents and authorities, numbered in roman numerals.
  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)
  toc()
  pagebreak()
  toa(meta, body)

  // Body: arabic numbers from 1; the cited pages in the tables are these numbers.
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)

  // Headings: level 1 centered caps; level 2 bold with a hanging indent (I., II.); level 3 bold, indented (A., B.);
  // level 4 bold italic.
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    par(hanging-indent: 0.5in, first-line-indent: 0pt, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    pad(left: 0.5in, par(hanging-indent: 0.5in, first-line-indent: 0pt, text(weight: "bold", it.body))))
  show heading.where(level: 4): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    pad(left: 1in, text(weight: "bold", style: "italic", it.body)))

  // Quotations: indented and single-spaced (LR 5.1(B) double spacing applies to text; quotations are set off).
  show quote.where(block: true): it => block(width: 100%, above: body-leading, below: body-leading,
    pad(x: 0.5in, par(leading: single-leading, first-line-indent: 0pt, it.body)))

  // Footnotes: 10-point, single-spaced (LR 5.1(B)(2)).
  show footnote.entry: it => {
    set text(size: footnote-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // Authority links print as ordinary text.
  show link: set text(fill: black)

  // Paragraph spacing equals the leading, so the pitch across a paragraph break matches the pitch within one.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent)
  // Footnote definitions follow the conclusion heading in the markdown, but a footnote reference is only
  // resolved in the same render call: the definitions are moved ahead of the split and rendered with the body.
  let lines = body.split("\n")
  let footnote-defs = lines.filter(l => l.starts-with("[^")).join("\n")
  let text-body = lines.filter(l => not l.starts-with("[^")).join("\n")
  // The conclusion and the signature block go on one page: the conclusion is kept with the signature.
  let parts = text-body.split("\n# CONCLUSION\n")
  if parts.len() == 2 {
    cmarker.render(parts.at(0) + "\n\n" + footnote-defs, raw-typst: false, smart-punctuation: true)
    block(breakable: false, width: 100%, {
      cmarker.render("# CONCLUSION\n\n" + parts.at(1), raw-typst: false, smart-punctuation: true)
      signature-block(meta)
    })
  } else {
    cmarker.render(text-body + "\n\n" + footnote-defs, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  }

  if "type_volume" in meta and meta.type_volume {
    certificate(meta, words)
  }
}
