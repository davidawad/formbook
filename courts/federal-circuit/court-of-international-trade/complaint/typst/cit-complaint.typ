// United States Court of International Trade (cit): complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (CIT-...) refer to ../README.md, which quotes the
// rule text: USCIT Rules 81(b), (d), (f) (paper, type size, double spacing, page numbers), 10(a), 10(b)
// (caption, numbered paragraphs), 7(a) (designation), 11(a) (signer's contact details). No case-specific
// text, no coordinates measured off the exemplar, no forced line breaks. The body is markdown, rendered
// by cmarker; the metadata is the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // vendored in /fonts; the only font this template uses
#let type-size = 12pt                    // CIT-TYPE-001: Rule 81(f), 12 point or larger, footnotes included
#let pitch = 24pt                        // CIT-SPACE-001: Rule 81(f), double spaced: 24 pt baseline pitch at 12 pt
#let body-leading = 0.695em              // gap between lines of body text; EB Garamond's line box is 1.3em at 12 pt, so this gives a 24 pt pitch (measured, ../README.md)
#let single-leading = 0em                // caption, counsel and signature lines: single spacing (about 15.7 pt at 12 pt)
#let page-w = 8.5in                      // CIT-PAPER-001: Rule 81(f), 8 1/2 by 11 inches
#let page-h = 11in
#let margin-x = 1in                      // CIT-PAPER-002: typed matter 6 1/2 in wide (limit 6 1/2 in) ...
#let margin-y = 1in                      // ... and 9 in tall (limit 9 1/2 in); the page number sits in the bottom margin
#let margins = (top: margin-y, bottom: margin-y, x: margin-x)
#let para-indent = 0.5in                 // first-line indent of numbered allegations
#let caption-left = 3.4in                // width of the party column of the caption
#let caption-paren = 0.3in               // width of the column of ")" marks (the caption's mark column)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cit-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A required metadata field; a missing one fails the build with its name.
#let need(meta, key) = {
  if key not in meta { panic("cit-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

// ---------------------------------------------------------------------------
// Cover: court title, caption (Rule 10(a)), title of the pleading
// ---------------------------------------------------------------------------

/// The caption: each party's names and designation, a ")" mark on every line (the rows of the grid are
/// the lines, so the marks line up with wrapped names), and the court number on the right.
#let caption(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  let sides = need(meta, "caption")
  let rows = ()
  for (i, side) in sides.enumerate() {
    for n in side.names { rows.push(inl(n)) }
    rows.push(pad(left: 1.2in, inl(side.designation)))
    if i < sides.len() - 1 { rows.push(align(center, [v.])) }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    pad(left: 0.2in, {
      [Court No. #need(meta, "court_no")]
      if "before" in meta { linebreak(); [Before: #meta.before] }
    })
  }
  let cells = ()
  for (k, r) in rows.enumerate() {
    if k == 0 {
      cells.push(r)
      cells.push([)])
      cells.push(grid.cell(rowspan: rows.len(), align(top, right)))
    } else {
      cells.push(r)
      cells.push([)])
    }
  }
  grid(columns: (caption-left, caption-paren, 1fr), row-gutter: 0pt, ..cells)
}

#let cover(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(need(meta, "court").map(l => [#l]).join(linebreak()))))
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, strong(upper(inl(need(meta, "brief_title")))))
  pagebreak()
}

// ---------------------------------------------------------------------------
// Signature block (Rule 11(a): the signer's address, e-mail and telephone are in the lines)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (2.6in, 1fr), column-gutter: 0.2in,
      [Dated: #need(meta, "date")],
      {
        [Respectfully submitted,]
        v(pitch * 0.5)
        [/s/ #sig.signer]
        linebreak()
        for l in sig.lines { inl(l); linebreak() }
      })
  })
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Rule 10(b)); headings unnumbered; lists lettered
// ---------------------------------------------------------------------------

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a list
/// is one numbered paragraph. Numbering is applied per chunk, not with a `show par` rule: a show rule that
/// re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, para-counter, unnumbered) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  // Paragraphs under a heading named in the frontmatter `unnumbered` list are not numbered (e.g. the prayer).
  let in-unnumbered = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
      in-unnumbered = unnumbered.contains(t.replace(regex("^#+\\s*"), "").trim())
    } else if in-unnumbered and not t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      let piece = {
        set par(leading: body-leading)
        [#h(para-indent)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      }
      if has-pending {
        block(breakable: false, width: 100%, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        block(breakable: false, width: 100%, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      let piece = {
        para-counter.step()
        set par(leading: body-leading)
        context [#h(para-indent)#(para-counter.display()).#h(0.4in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      }
      if has-pending {
        block(breakable: false, width: 100%, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: 100%, pending) }
}

#let running-number() = context align(center, counter(page).display())

#let cit-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margins,
    numbering: "1",
    footer: running-number(),
  )
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "court_no"))
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a centered bold sub-heading (a count); level 3 bold italic.
  show heading.where(level: 1): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    align(center, strong(it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    strong(emph(it.body)))

  cover(meta)

  if "lead_in" in meta {
    par(leading: body-leading, [#h(para-indent)#inl(meta.lead_in)])
  }

  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter, meta.at("unnumbered", default: ()))

  signature-block(meta)
}
