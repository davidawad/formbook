// United States District Court, Middle District of Florida: complaint (Fed. R. Civ. P. 8 and 10; M.D. Fla. Local Rule 1.08).
// Rule-driven and content-agnostic. No case-specific text, no coordinates measured off any filed complaint,
// no forced line breaks. The body is markdown rendered by cmarker; the metadata is the YAML frontmatter of the
// same sample file (schema: ../README.md, "Markdown contract"). Rule IDs (FLMD-...) refer to ../README.md.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute (docs/FONTS.md, metric-compatible); the filed exemplar is Times New Roman, LR 1.08(b).
#let type-size = 14pt              // FLMD-TYPE-002: main text at least 13-point (1.08(a)); Times New Roman must be 14-point (1.08(b)).
#let body-leading = 1.35em         // FLMD-TYPE-001: 2.0 double-spaced. Measured baseline pitch with Liberation Serif at 14pt is 28.1pt (2.0em), checked with pdftotext -bbox.
#let single-leading = 0.5em        // FLMD-TYPE-003: indented quotations, caption, counsel and signature blocks are single-spaced.
#let page-margin = 1in             // FLMD-PAGE-002: 1 inch on all sides.
#let para-indent = 0.5in           // first-line indent of numbered paragraphs and of unnumbered body text.
#let caption-w = 2.9in             // width of the party column of the caption; the case number column must hold "CASE NO.: 8:26-cv-02634-SDM-AEP" on one line.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flmd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (party names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Markdown chunk (heading, list or paragraph), with `#` as level 1.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

// ---------------------------------------------------------------------------
// Caption and cover (FRCP 10(a): court, title, file number, Rule 7(a) designation)
// ---------------------------------------------------------------------------

/// One centered line: a block, so consecutive lines stack instead of running together.
#let center-line(c, below: 0pt) = block(width: 100%, above: 0pt, below: below, align(center, c))

#let court-title(meta) = {
  center-line(text(weight: "bold", "UNITED STATES DISTRICT COURT"), below: single-leading)
  center-line(text(weight: "bold", "MIDDLE DISTRICT OF FLORIDA"), below: single-leading)
  if "division" in meta and meta.division != none {
    center-line(text(weight: "bold", upper(meta.division)))
  }
}

/// Party column: names, then the designation (indented); "vs." between the parties; a closing rule.
#let caption(meta) = grid(
  columns: (caption-w, 1fr),
  column-gutter: 0.25in,
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    let items = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { items.push(meta.caption.at("versus", default: "v.")) }
      for n in p.names { items.push(inl(n)) }
      items.push(pad(left: 0.5in, p.designation))
    }
    items.push("_" * 30 + "/")
    stack(dir: ttb, spacing: single-leading, ..items)
  },
  pad(top: 0.5in, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    "CASE NO.: " + meta.case_number
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  center-line(text(weight: "bold", inl(meta.brief_title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs (FRCP 10(b)), lettered lists
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one unit:
///   `#` heading            centered (level 1 caps; level 2 bold; level 3 bold italic, left)
///   `1.` list              items lettered (a), (b), ...
///   `~ text`               an unnumbered paragraph (a demand, a prayer, a signature line)
///   any other text         one numbered paragraph
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages like any text; its items are spaced by body-leading.
      set par(leading: body-leading)
      md(t)
      v(body-leading)
    } else if t.starts-with("~ ") {
      block(width: 100%, {
        set par(leading: body-leading, first-line-indent: para-indent)
        inl(t.slice(2))
      })
    } else {
      n += 1
      block(width: 100%, {
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent) + str(n) + "." + h(0.3in) + md(t)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (FRCP 11(a): a signed paper; Local Rule 1.08 applies to the signature page)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  v(body-leading)
  block(width: 100%, breakable: false, {
    set par(leading: body-leading, first-line-indent: para-indent)
    "RESPECTFULLY SUBMITTED " + meta.date + "."
  })
  v(body-leading)
  block(width: 100%, breakable: false, pad(left: 3in, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    stack(dir: ttb, spacing: single-leading,
      ..meta.signature.firm.map(inl),
      "s/" + meta.signature.signer,
      ..meta.signature.lines.map(inl),
    )
  }))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let flmd-complaint(meta, body) = {

  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context {
      // FLMD-PAGE-003: bottom center; no number is needed on page one.
      let n = counter(page).get().first()
      if n > 1 { align(center, text(size: type-size, str(n))) }
    },
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  // Blocks (paragraphs, list items) are separated by one leading unit: the baseline gap is then the full
  // 2.0 em pitch, as it is inside a paragraph. Without it, a block's first line lands on the previous block's last line.
  set block(spacing: body-leading)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centered section in caps; level 2 a centered bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading * 0.5, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 2): it => block(width: 100%, above: 0pt, below: body-leading * 0.5, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: body-leading, below: body-leading * 0.5, sticky: true,
    text(weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    block(width: 100%, {
      set par(leading: body-leading, first-line-indent: 0pt)
      h(para-indent) + inl(meta.lead_in)
    })
  }

  allegations(body)

  signature-block(meta)
}
