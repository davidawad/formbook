// U.S. District Court, Southern District of Illinois: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (ILSD-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same sample file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"       // vendored in /fonts; no system font can be used (tools/render.sh)
#let type-size = 12pt                  // ILSD-FORM-002: 12-point type; the rule text is SDIL-LR 7.1(a)(3), briefs. Applied to complaints too (see README).
#let line-pitch = 24pt                 // ILSD-FORM-003: double spacing (SDIL-LR 5.1(a)); tuned so body lines land on this pitch.
#let body-leading = 16.2pt             // gap between lines of body text; with the natural line height of EB Garamond 12 pt (7.8 pt) the pitch is line-pitch (24 pt).
#let single-leading = 6.2pt           // single spacing: natural line height of EB Garamond 12 pt (7.8 pt) plus 6.2 pt is a 14 pt pitch. Caption, counsel, signature, headings that wrap.
#let margins = (top: 1in, bottom: 1in, x: 1in)  // ILSD-FORM-001: 1-inch margins (convention; see README)
#let para-indent = 0.5in               // first-line indent of numbered paragraphs (Fed. R. Civ. P. 10(b): numbered paragraphs)
#let caption-line = 14pt               // one single-spaced caption line
#let sig-indent = 3.25in               // signature block starts at the middle of the page

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, footnote references, links) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilsd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ilsd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A single-spaced block that stays with the block after it.
#let single(body) = block(sticky: true, par(leading: single-leading, body))

// ---------------------------------------------------------------------------
// Caption (Fed. R. Civ. P. 10(a): court name, title, file number; the title of the action)
// ---------------------------------------------------------------------------

/// The caption: parties on the left, a column of ")" marks, and the case number and jury
/// demand on the right, vertically centered against the parties.
#let caption(parties, case-number, jury) = {
  let left = ()
  for (i, p) in parties.enumerate() {
    for n in p.names { left.push(inl(n)) }
    left.push([])
    left.push(pad(left: 1.4in, inl(p.designation)))
    if i < parties.len() - 1 {
      left.push([])
      left.push(align(center, inl("v.")))
      left.push([])
    }
  }
  let rows = left.map(l => box(height: caption-line, width: 100%, align(horizon, l)))
  let marks = left.map(_ => box(height: caption-line, align(horizon, [)])))
  grid(
    columns: (3.5in, 0.4in, 1fr),
    column-gutter: 0pt,
    stack(dir: ttb, spacing: 0pt, ..rows),
    stack(dir: ttb, spacing: 0pt, ..marks),
    align(horizon, pad(left: 0.25in, stack(
      dir: ttb,
      spacing: 1.2em,
      [Case No. #case-number],
      if jury { strong[DEMAND FOR JURY TRIAL] },
    ))),
  )
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered or typed list items, unnumbered paragraphs
// ---------------------------------------------------------------------------

#let para-counter = counter("ilsd-paragraph")

/// Level 1 heading "# ...": centered, bold, capitals as written.
#let heading-one(s) = block(width: 100%, sticky: true, above: 18pt, below: 6pt, align(center, strong(s)))

/// Level 2 heading "## ...": centered, bold, kept with the text after it.
#let heading-two(s) = block(width: 100%, sticky: true, above: 12pt, below: 12pt, align(center, strong(s)))

/// A numbered paragraph. Numbering restarts at 1 for each sample; footnote definitions are passed
/// along so that a reference in this paragraph has its text on the same page.
#let numbered(s, defs) = {
  para-counter.step()
  context {
    let n = para-counter.get().first()
    par(first-line-indent: (amount: para-indent, all: true), leading: body-leading, [#n\. #h(0.4em) #inl(s + "\n\n" + defs)])
  }
}

/// An unnumbered paragraph ("%" marker): the prayer's "WHEREFORE" lead-in.
#let unnumbered(s, defs) = par(first-line-indent: (amount: para-indent, all: true), leading: body-leading, inl(s + "\n\n" + defs))

/// A list of prayer items: one line per "- " item, each hanging under its own label.
#let items(c, defs) = {
  for line in c.split("\n") {
    if line.starts-with("- ") {
      block(sticky: false, above: 0.6em, pad(left: 0.5in, par(
        hanging-indent: 0.5in, first-line-indent: 0pt, leading: body-leading,
        inl(line.slice(2)),
      )))
    }
  }
}

#let render-chunk(c, defs) = {
  if c.starts-with("# ") { heading-one(c.slice(2)) }
  else if c.starts-with("## ") { heading-two(c.slice(3)) }
  else if c.starts-with("- ") { items(c, defs) }
  else if c.starts-with("%") { unnumbered(c.slice(1), defs) }
  else if c.starts-with("[^") { none }
  else { numbered(c, defs) }
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Civ. P. 11(a): signed by at least one attorney of record)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  let line(body) = par(leading: single-leading, body)
  block(breakable: false, above: 1.2em, stack(
    dir: ttb,
    spacing: 0pt,
    line[Dated: #need(meta, "date")],
    v(1.2em),
    pad(left: sig-indent, stack(
      dir: ttb,
      spacing: single-leading,
      line[Respectfully submitted,],
      v(0.6em),
      line(strong(sig.firm)),
      v(0.6em),
      line[By: /s/ #sig.signer],
      ..sig.lines.map(l => line[#l]),
      v(0.6em),
      ..sig.at("other", default: ()).map(l => line[#l]),
      ..if "role" in sig { (v(0.3em), line(emph(sig.role))) } else { () },
    )),
  ))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ilsd-complaint(meta, body) = {
  set document(title: need(meta, "title") + " (" + need(meta, "case_number") + ")")
  set page(
    paper: "us-letter",
    margin: margins,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  show footnote.entry: set text(size: type-size)
  set par(justify: false, leading: body-leading)
  set block(spacing: 0pt)
  set heading(numbering: none)

  // Court name (Fed. R. Civ. P. 10(a))
  align(center, par(leading: single-leading)[
    UNITED STATES DISTRICT COURT \
    FOR THE SOUTHERN DISTRICT OF ILLINOIS
  ])
  v(line-pitch)

  caption(need(meta, "caption"), need(meta, "case_number"), meta.at("jury_demand", default: false))

  v(line-pitch)
  align(center, strong(need(meta, "title")))
  v(0.6em)

  // Unnumbered lead-in paragraph ("...for their Complaint against ... allege:")
  if "lead_in" in meta {
    par(first-line-indent: (amount: para-indent, all: true), leading: body-leading, inl(meta.lead_in))
  }

  // Body: blank-line-separated chunks; footnote definitions are shared by every chunk.
  let chunks = body.split("\n\n").map(c => c.trim()).filter(c => c != "")
  let defs = chunks.filter(c => c.starts-with("[^")).join("\n\n")
  for c in chunks { render-chunk(c, defs) }

  signature(meta)
}
