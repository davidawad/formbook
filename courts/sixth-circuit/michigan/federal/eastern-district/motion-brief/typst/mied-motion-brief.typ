// Motion to dismiss with brief in support, for the U.S. District Court for the Eastern District of
// Michigan (mied). One document: the motion (numbered 1, 2, ...), the brief's cover (unnumbered), the
// front matter (statement of issues, controlling authorities, contents; roman numerals) and the brief
// (numbered from 1), then the certificate of service.
// Rules: LR 5.1(a) (double spacing, 1-inch margins, 14-point proportional type, page numbers);
// LR 7.1(a) (conferral statement in the motion); LR 7.1(d) (brief contents and the 25-page limit);
// Fed. R. Civ. P. 12(b)(6). See ../README.md for the rule text, its source and the open questions.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a named style choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // LR 5.1(a)(3) names no face (any proportional type, 14 pt): kept per docs/FONTS.md "No face named"
#let type-size = 14pt                   // LR 5.1(a)(3): 14 point for proportional type, footnotes included
#let margin = 1in                       // LR 5.1(a)(2): at least 1 inch, top, bottom and sides
#let page-size = 12pt                   // page numbers are not text under LR 5.1(a)(3); style choice
// Double spacing (LR 5.1(a)(2)) is defined against the font's own single line: the font's line box is
// 0.65em, so single spacing is a 1.15em pitch (Times New Roman's single line box) and double is 2.3em.
#let single-leading = 0.5em             // single pitch 1.15em: captions, signature, authorities, tables
#let double-leading = 1.65em            // double pitch 2.3em: body text
#let para-indent = 0.5in
#let caption-left = 3.3in               // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mied-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, emphasis) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Markdown (headings, paragraphs, lists, quotations) as content.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Single-spaced stack of lines (party names, counsel, signature block).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption and cover
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "FOR THE EASTERN DISTRICT OF MICHIGAN")
  if "division" in meta { lines.push(upper(meta.division)) }
  set par(leading: single-leading, spacing: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading, ..lines.map(l => text(weight: "bold", l))))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    let rows = ("Case No. " + meta.case_number,)
    if "judge" in meta { rows.push(meta.judge) }
    if "judges" in meta { rows += meta.judges }
    line-stack(rows)
  }),
)

/// Cover of a paper: court title, caption, title of the paper.
#let cover(meta, title) = {
  court-title(meta)
  v(2.3em)
  caption(meta)
  v(2.3em)
  align(center, text(weight: "bold", title))
  v(2.3em)
}

// ---------------------------------------------------------------------------
// Headings, signature, tables of contents
// ---------------------------------------------------------------------------

/// Level 1: centered bold caps. Level 2: bold, flush left. Level 3: bold, indented 0.5 in.
#let heading-block(level, it) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  block(width: 100%, above: 2.3em, below: 2.3em, sticky: true, {
    if level == 1 { align(center, text(weight: "bold", upper(it.body))) }
    else if level == 2 { text(weight: "bold", it.body) }
    else { pad(left: 0.5in, text(weight: "bold", it.body)) }
  })
}

/// Signature block: the date (optional) and "Respectfully submitted," with the firm and the signer.
#let signature-block(meta) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  block(width: 100%, breakable: false, {
    if "date" in meta { [Dated: #meta.date] }
    pad(left: 3.2in, {
      [Respectfully submitted,]
      v(1.15em)
      line-stack(meta.signature.firm + ("By: /s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines)
    })
  })
}

/// Table of contents: the outline of the body headings (front matter headings are not outlined).
#let contents() = {
  align(center, text(weight: "bold", upper("Table of Contents")))
  v(2.3em)
  set par(leading: single-leading, spacing: 0.9em, first-line-indent: 0pt)
  outline(title: none, depth: 3, indent: 0.5in)
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let mied-motion-brief(meta, body) = {
  set text(font: font-family, size: type-size, lang: "en")
  set page(paper: "us-letter", margin: margin, numbering: "1")
  set par(leading: double-leading, spacing: double-leading, first-line-indent: para-indent, justify: false)
  show heading: it => heading-block(it.level, it)
  // Block quotations: single-spaced, indented on both sides.
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, {
    set par(leading: single-leading, spacing: 1.15em, first-line-indent: 0pt)
    it.body
  })

  // Split the markdown at its markers: [[brief]] starts the brief, [[body]] starts the numbered text,
  // [[toc]] places the contents, and CERTIFICATE OF SERVICE closes the body (it is not in the contents).
  let parts = body.split("[[brief]]")
  let motion = parts.at(0)
  let brief = parts.slice(1).join("[[brief]]")
  let front-body = brief.split("[[body]]")
  let front = front-body.at(0)
  let main = front-body.slice(1).join("[[body]]")
  let front-toc = front.split("[[toc]]")
  let cert-split = main.split("# CERTIFICATE OF SERVICE")
  let argument = cert-split.at(0)
  let cert = cert-split.slice(1).join("# CERTIFICATE OF SERVICE")

  // The motion: its own cover, the motion, the conferral statement, then the signature.
  {
    set heading(outlined: false)
    cover(meta, meta.motion_title)
    md(motion)
    v(2.3em)
    signature-block(meta)
  }

  // The brief's cover: unnumbered; the page count restarts from here.
  pagebreak()
  set page(numbering: none)
  counter(page).update(1)
  cover(meta, meta.brief_title)

  // Front matter: roman numerals, starting at ii (the cover is i).
  pagebreak()
  set page(numbering: "i")
  {
    set heading(outlined: false)
    if front-toc.len() > 1 {
      md(front-toc.at(0))
      pagebreak()
      contents()
      md(front-toc.slice(1).join("[[toc]]"))
    } else {
      md(front)
    }
  }

  // The brief: arabic numerals from 1.
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  md(argument)
  v(2.3em)
  signature-block(meta)

  // Certificate of service: not in the contents.
  pagebreak()
  {
    set heading(outlined: false)
    md("# CERTIFICATE OF SERVICE" + cert)
  }
}
