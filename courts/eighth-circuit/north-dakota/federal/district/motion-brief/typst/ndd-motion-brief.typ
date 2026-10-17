// Motion to dismiss with memorandum in support, for the U.S. District Court for the District of North Dakota (ndd).
// Rules: D.N.D. Civil Rule 5.1(B) (12-point type or larger, double-spaced, one-inch margins, page numbers at
// the bottom); Civil Rule 7.1(A)(1)(a) (a dispositive motion's memorandum: 40-page limit, tables optional and
// excluded from the limit); Fed. R. Civ. P. 7(b)(1) and 12(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Civil Rule 5.1(B)(2) sets a size, not a typeface; the vendored face is used
#let type-size = 12pt                   // Civil Rule 5.1(B)(2): 12-point font or larger
#let page-w = 8.5in                     // Civil Rule 5.1(B)(1): standard size paper
#let page-h = 11in
#let margin = 1in                       // Civil Rule 5.1(B)(2): minimum one-inch margin
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // Civil Rule 5.1(B)(2): double-spaced (measured, see README.md)
#let single-leading = 0.5em             // single-spaced: caption, signature block, service list (the case title may be single-spaced)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // party column of the caption
#let caption-paren = 0.3in              // the ")" column

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ndd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, section symbols, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines: each item is one block; the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = stack(dir: ttb, spacing: single-leading,
  ..(meta.court, meta.district, meta.division).map(s => align(center, text(weight: "bold", upper(s)))),
)

/// Party column, a column of ")" marks, and the case number and title. Each row is one single-spaced line,
/// so the two columns align. A party with no designation (an "In re" caption) has none printed.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names
    if "designation" in p and p.designation != "" { rows.push(p.designation) }
  }
  grid(
    columns: (caption-left, caption-paren, 1fr),
    column-gutter: 0pt,
    line-stack(rows),
    line-stack(rows.map(r => ")")),
    block(inset: (left: 0.2in), {
      set par(leading: single-leading, spacing: 0pt)
      let case-no = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "____________" }
      [Case No. #case-no]
      v(body-leading)
      text(weight: "bold", upper(meta.title))
    }),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: paragraphs, headings, signature, certificate of service
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  if "date" in meta and meta.date != "" {
    block(width: text-width, breakable: false, above: body-leading, below: 0pt, [Dated: #meta.date])
  }
  block(width: text-width, breakable: false, above: body-leading, below: 0pt,
    pad(left: 3.25in, {
      set par(leading: single-leading, spacing: 0pt)
      if "closing" in meta {
        [#meta.closing]
        v(body-leading)
      }
      line-stack(meta.signature.firm)
      v(body-leading)
      line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines)
    }))
}

#let certificate-block(meta) = {
  let c = meta.certificate
  block(width: text-width, breakable: false, above: body-leading, below: 0pt, {
    align(center, text(weight: "bold", upper(c.heading)))
    v(body-leading)
    block(width: text-width, below: body-leading, {
      h(para-indent)
      inl(c.text)
    })
    pad(left: 0.5in, line-stack(c.served))
    v(body-leading)
    pad(left: 3.25in, {
      set par(leading: single-leading, spacing: 0pt)
      line-stack(("/s/ " + c.signer,) + c.signer_lines)
    })
  })
}

/// Blank-line-separated markdown chunks become: a heading (unnumbered), a list (lettered (a), (b), ...),
/// or a body paragraph with a first-line indent. Briefs are not numbered (Civil Rule 7.1 does not require it).
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let lvl = t.match(regex("^#+")).text.len()
      heading(level: lvl, t.slice(lvl).trim())
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      {
        set par(leading: body-leading, spacing: 0pt)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else {
      block(width: text-width, above: 0pt, below: body-leading, {
        h(para-indent)
        inl(t)
      })
    }
  }
}

#let ndd-motion-brief(meta, body) = {
  assert("division" in meta, message: "ndd-motion-brief: the caption must designate the division (Civil Rule 3.1(A))")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings are double-spaced (Civil Rule 5.1(B)(2) allows single spacing only for the case title and quotations),
  // sticky (a heading never ends a page), and in the type size. Level 1: centred bold caps. Level 2: bold, with a
  // hanging indent so a wrapped lettered heading lines up. Level 3: bold italic, hanging.
  show heading.where(level: 1): it => block(width: text-width, above: 0pt, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: 0pt, below: body-leading, sticky: true,
    par(hanging-indent: 0.5in, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, above: 0pt, below: body-leading, sticky: true,
    par(hanging-indent: 0.5in, text(size: type-size, weight: "bold", style: "italic", it.body)))

  cover(meta)

  if "lead_in" in meta {
    block(width: text-width, above: 0pt, below: body-leading, {
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  body-chunks(body)

  signature-block(meta)

  if "certificate" in meta {
    certificate-block(meta)
  }
}
