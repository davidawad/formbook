// United States District Court, Middle District of Florida: motion with legal memorandum (Local Rules 1.08, 3.01).
// Rule-driven and content-agnostic. No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The body is markdown rendered by cmarker; the metadata is the YAML frontmatter of the same sample
// file (schema: ../README.md, "Markdown contract"). Rule IDs (FLMD-...) refer to ../README.md.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Pagella"   // Book Antiqua substitute (docs/FONTS.md, visual only); Book Antiqua is named by LR 1.08(a) and used by the filed exemplar.
#let type-size = 14pt              // FLMD-TYPE-002: main text at least 13-point (1.08(a)); Times New Roman must be 14-point (1.08(b)).
#let body-leading = 1.31em         // FLMD-TYPE-001: 2.0 double-spaced. Measured baseline pitch with TeX Gyre Pagella at 14pt is 28.1pt (2.0em); 1.35em gives 2.05em.
#let single-leading = 0.5em        // FLMD-TYPE-003: quotations, caption, counsel and signature blocks are single-spaced.
#let page-margin = 1in             // FLMD-PAGE-002: 1 inch on all sides.
#let para-indent = 0.5in           // first-line indent of body paragraphs.
#let caption-w = 2.9in             // width of the party column of the caption; the case number column must hold "CASE NO.: 8:26-cv-02634-SDM-AEP" on one line.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flmd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (party names, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Markdown chunk (heading, list or paragraph), with `#` as level 1.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One centered line: a block, so consecutive lines stack instead of running together.
#let center-line(c, below: 0pt) = block(width: 100%, above: 0pt, below: below, align(center, c))

// ---------------------------------------------------------------------------
// Caption and cover (FRCP 10(a): court, title, file number, Rule 7(a) designation)
// ---------------------------------------------------------------------------

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
  center-line(text(weight: "bold", inl(meta.brief_title)), below: body-leading)
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, lists
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one unit:
///   `#` heading            centered caps (level 1); centered bold (level 2); bold, left (level 3); bold italic (level 4)
///   `1.` list              items lettered (a), (b), ...
///   `~ text`               a paragraph with no first-line indent (certificate lines, signature lines)
///   any other text         a body paragraph with a first-line indent (not numbered: M.D. Fla. memoranda are not)
/// Chunks are not split by the template: a heading is kept with the chunk after it (sticky).
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      set par(leading: body-leading)
      md(t)
      v(body-leading)
    } else if t.starts-with("~ ") {
      block(width: 100%, {
        set par(leading: body-leading, first-line-indent: 0pt)
        inl(t.slice(2))
      })
    } else {
      // The indent is an explicit space: cmarker's paragraphs do not take the document's first-line-indent.
      block(width: 100%, {
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent) + md(t)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (Fed. R. Civ. P. 11(a): signed by counsel of record) and certificates
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  // One unbreakable block: "Respectfully submitted," never ends a page apart from the signature.
  v(body-leading)
  block(width: 100%, breakable: false, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    h(para-indent) + [Respectfully submitted,]
    v(body-leading)
    pad(left: 3in, {
      stack(dir: ttb, spacing: single-leading, ..meta.signature.firm.map(inl))
      v(body-leading)
      for counsel in meta.signature.counsel {
        stack(dir: ttb, spacing: single-leading, ..counsel.map(inl))
        v(body-leading)
      }
      stack(dir: ttb, spacing: single-leading, ..meta.signature.address.map(inl), inl(meta.signature.at("for", default: "")))
    })
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let flmd-motion-brief(meta, body) = {
  // The certificate of service is written last in the sample; it is printed after the signature block.
  let parts = body.split("# CERTIFICATE OF SERVICE")
  let main = parts.at(0)
  let cert = if parts.len() > 1 { "# CERTIFICATE OF SERVICE" + parts.at(1) } else { none }

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
  // Blocks are separated by one leading unit, so the baseline gap between paragraphs is the full 2.0 em pitch.
  set block(spacing: body-leading)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  // FLMD-TYPE-004: indented quotations are single-spaced and smaller than the main text (1.08(a): 12-point).
  show quote.where(block: true): it => block(width: 100%, inset: (left: 0.5in, right: 0.5in), {
    set par(leading: single-leading, first-line-indent: 0pt)
    it.body
  })

  show heading: set block(above: body-leading, below: body-leading * 0.5)
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading * 0.5, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 2): it => block(width: 100%, above: 0pt, below: body-leading * 0.5, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: body-leading * 0.5, below: body-leading * 0.5, sticky: true,
    text(weight: "bold", it.body))
  show heading.where(level: 4): it => block(width: 100%, above: body-leading * 0.5, below: body-leading * 0.5, sticky: true,
    text(weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    block(width: 100%, {
      set par(leading: body-leading, first-line-indent: 0pt)
      h(para-indent) + inl(meta.lead_in)
    })
  }

  body-chunks(main)

  signature-block(meta)

  if cert != none {
    // Unbreakable: the certificate moves to the next page whole, rather than leaving its signature alone.
    block(width: 100%, breakable: false, body-chunks(cert))
  }
}
