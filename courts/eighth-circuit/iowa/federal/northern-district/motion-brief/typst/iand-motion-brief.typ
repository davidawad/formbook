// Memorandum in support of a motion for the U.S. District Court for the Northern District of Iowa (iand).
// Rules: N.D. Iowa LR 7(b)(3), (d) (a brief is filed with the motion; the brief states the grounds and cites the
// authorities), 7(h) (20 pages, not counting the table of contents, table of authorities and signature block);
// LR 10(a) (8.5 x 11 inch paper), 10(b) (double spaced, one side, top margin of at least 1 inch, pages numbered
// at the bottom; a brief of more than 10 pages has a subject matter table of contents on its first page),
// 10(d) (caption with district, division, case number, litigants and a designation of the content).
// Fed. R. Civ. P. 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no typeface is named in LR 10; EB Garamond is the vendored serif (README.md, gap 2)
#let type-size = 12pt                   // no size is named in LR 10; 12 point is the usual federal filing size
#let pitch = 24pt                       // LR 10(b)(1): double spaced; the baseline pitch of body text
#let page-w = 8.5in                     // LR 10(a): 8 1/2 by 11 inch
#let page-h = 11in
#let margin = 1in                       // LR 10(b)(3): top margin of at least 1 inch (all sides set to 1 inch)
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: a 24 pt baseline pitch at 12 pt (measured on the ca9 template, see README.md)
#let single-leading = 0.5em             // single spacing for caption, counsel, signature, TOC entries: about 13.8 pt at 12 pt
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.1in               // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iand-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Round a block up to whole double-spaced lines, so the text after it stays on the pitch of body text.
/// A one-line block is otherwise shorter than the leading that follows it, and the lines collide.
#let on-grid(c, sticky: false, width: text-width) = context {
  let h = measure(width: width, c).height
  block(width: width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: sticky, c)
}

/// Heading text: body size (typst's default heading size is larger), double-spaced if it wraps, so each line sits on the pitch.
#let heading-style(c) = {
  set text(size: type-size)
  par(leading: body-leading, first-line-indent: 0pt, c)
}

/// Single-spaced lines: one item per line, the same spacing as the caption.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption (LR 10(d))
// ---------------------------------------------------------------------------

/// Court title: three centered lines (district and division).
#let court-title(meta) = {
  let lines = (
    "IN THE UNITED STATES DISTRICT COURT",
    "FOR THE NORTHERN DISTRICT OF IOWA",
  )
  if "division" in meta { lines.push(upper(meta.division)) }
  set par(leading: single-leading)
  stack(dir: ttb, spacing: single-leading, ..lines.map(l => align(center, text(weight: "bold", l))))
}

/// Caption: the parties on the left, closed by a column of ")" marks (one per line); the case number,
/// the judges and the designation of the paper on the right.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  grid(
    columns: (caption-left, 0.3in, 1fr),
    line-stack(rows),
    line-stack(rows.map(_ => ")")),
    block(inset: (left: 0.15in), {
      let label = meta.at("case_label", default: "No.")
      line-stack((label + " " + meta.case_number,))
      if "judge" in meta {
        v(single-leading)
        line-stack(("Judge: " + meta.judge,))
      }
      if "magistrate_judge" in meta {
        v(single-leading)
        line-stack(("Magistrate Judge: " + meta.magistrate_judge,))
      }
      v(pitch)
      text(weight: "bold", line-stack((meta.brief_title,)))
    }),
  )
}

// ---------------------------------------------------------------------------
// Table of contents (LR 10(b)(4))
// ---------------------------------------------------------------------------

/// Subject matter table of contents: the headings of the brief with their pages. Not a heading itself, so it
/// is not listed in its own entries.
#let contents() = {
  align(center, text(weight: "bold", "TABLE OF CONTENTS"))
  v(pitch)
  set par(leading: single-leading)
  outline(title: none, depth: 2, indent: 1.5em)
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// The signature block (a "SIGNATURE" chunk in the markdown places it).
#let signature-block(meta) = block(breakable: false, width: text-width, {
  v(body-leading)
  if "date" in meta {
    block(width: text-width, above: 0pt, below: 0pt, "Dated: " + meta.date)
    v(body-leading)
  }
  pad(left: 3.0in, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    if "party" in meta.signature { line-stack(meta.signature.party); v(body-leading * 0.5) }
    line-stack(meta.signature.firm)
    v(body-leading * 0.5)
    line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines)
  })
  v(body-leading)
})

/// Body chunks (blank-line separated markdown). A chunk is one of:
///   "# ...", "## ...", "### ..."   headings (level 1 centered caps; level 2 bold, flush left; level 3 italic)
///   "SIGNATURE"                   the signature block
///   "SINGLE: ..."                 single-spaced lines (one per source line), e.g. a service list
///   "NUMBERED: ..."               a numbered paragraph (LR 10(b)); other paragraphs are not numbered
///   a list                        numbered 1., 2., ... (memorandum lists; not lettered)
///   "> ..."                       a block quotation, single-spaced and indented
///   anything else                 a paragraph with a first-line indent
/// Numbering is applied per chunk, not with a show rule: a show rule that re-wraps paragraph content recurses in typst 0.15.
#let body(meta, src) = {
  let para-counter = counter("paragraph")
  let chunks = src.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t == "<!--SIGNATURE-->" {
      signature-block(meta)
    } else if t.starts-with("<!--SINGLE-->") {
      let lines = t.slice("<!--SINGLE-->".len()).trim().split("\n").map(l => l.trim()).filter(l => l != "")
      line-stack(lines)
      v(body-leading)
    } else if t.starts-with("#") {
      inl(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set par(leading: body-leading, first-line-indent: 0pt)
      v(body-leading * 0.5)
      inl(t)
      v(body-leading * 0.5)
    } else if t.starts-with(">") {
      pad(left: 0.5in, right: 0.5in, on-grid(width: text-width - 1in, {
        set par(leading: single-leading, first-line-indent: 0pt)
        inl(t.trim(">").trim())
      }))
    } else if t.starts-with("<!--NUMBERED-->") {
      para-counter.step()
      on-grid({
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        context para-counter.display()
        [.#h(0.3in)]
        inl(t.slice("<!--NUMBERED-->".len()).trim())
      })
    } else {
      on-grid({
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        inl(t)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let iand-motion-brief(meta, src) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", top-edge: "ascender", bottom-edge: "descender")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 centered caps; level 2 bold, flush left; level 3 italic, flush left. Each is kept with what follows.
  show heading.where(level: 1): it => on-grid(sticky: true, heading-style({
    align(center, text(weight: "bold", upper(it.body)))
  }))
  show heading.where(level: 2): it => on-grid(sticky: true, heading-style({
    text(weight: "bold", it.body)
  }))
  show heading.where(level: 3): it => on-grid(sticky: true, heading-style({
    text(style: "italic", it.body)
  }))

  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)

  if meta.at("toc", default: false) {
    contents()
    pagebreak()
  }

  body(meta, src)
}
