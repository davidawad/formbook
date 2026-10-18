// Complaint for the United States District Court for the Western District of Arkansas (arwd).
// Rules: Fed. R. Civ. P. 8(a) (short and plain statement, jurisdiction, demand) and 10(a)-(b) (caption,
// numbered paragraphs); W.D./E.D. Ark. Local Rule 5.5(a) (type not less than elite, double space, letter
// size, one side), 5.5(c)(1) (signature block with address, telephone and Arkansas Supreme Court ID number),
// 5.5(d) (the JS44 cover sheet is a separate filing). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "TeX Gyre Schola"        // LR 5.5(a): proportional serif; audited exemplar face per docs/FONTS.md
#let type-size = 12pt                   // LR 5.5(a): "type not less than elite" (elite = 12 cpi); 12 pt here
#let page-w = 8.5in                     // LR 5.5(a): letter size
#let page-h = 11in
#let margin = 1in                       // convention (no margin rule in LR 5.5); the exemplar is 1 inch
#let body-leading = 1.65em              // LR 5.5(a): double space; 27.6 pt baseline pitch at 12 pt (measured, README.md)
#let single-leading = 0.5em             // counsel, caption, court title and signature: single spaced
#let pitch = 0.65em + body-leading       // one double-spaced line: the EB Garamond line (0.65 em) plus the leading, 27.6 pt
#let para-indent = 0.5in                // first-line indent of numbered paragraphs (convention)
#let caption-left = 3.6in               // width of the party column of the caption (convention)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("arwd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, smart quotes).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A block of markdown, rendered as a block (for headings, paragraphs and lists).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number, centered in the bottom margin.
#let footer-number() = align(center, text(size: type-size, context counter(page).display()))

// ---------------------------------------------------------------------------
// First page: court, caption, title
// ---------------------------------------------------------------------------

/// The court title, single spaced and centered: one line per entry of `court` in the frontmatter.
#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  // One stack for every line, so the division is spaced like the lines above it.
  let lines = meta.court
  if "division" in meta { lines.push(meta.division) }
  align(center, stack(dir: ttb, spacing: single-leading, ..lines.map(i => upper(i))))
}

/// The caption: party names on the left with their designation on the right; "v." and the case number
/// share the row between the two parties. Single spaced.
#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  let cells = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      cells += ([v.], [CASE NO. #meta.case_number])
    }
    for (i, n) in p.names.enumerate() {
      cells += (inl(n), if i == 0 { align(right, inl(p.designation)) } else { [] })
    }
  }
  grid(columns: (caption-left, 1fr), column-gutter: 0.2in, row-gutter: single-leading, ..cells)
}

/// The title of the paper: centered and bold, in capitals, with an optional second line.
#let title-block(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", upper(inl(meta.title))))
  if "subtitle" in meta {
    align(center, text(weight: "bold", inl(meta.subtitle)))
  }
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither
/// a heading nor a list is one numbered paragraph; headings and lists are not numbered. A heading is kept
/// in one unbreakable block with the chunk after it, so it never ends a page.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading is set off by a blank line above (unless it stacks on the heading before it, such as
      // "COUNT I" over "STRICT LIABILITY") and is kept with the chunk after it.
      if has-pending { pending += v(body-leading) } else { pending += v(pitch) }
      pending += md(t)
      has-pending = true
      continue
    }
    let piece = if t.starts-with("^ ") {
      // An unnumbered paragraph (the WHEREFORE clauses): indented like a numbered one, but not counted.
      {
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        md(t.slice(2))
        v(body-leading)
      }
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists (lettered (a), (b) ... in the complaint) may break across pages.
      {
        set par(leading: body-leading)
        md(t)
        v(body-leading)
      }
    } else {
      para-counter.step()
      {
        block(width: 100%, {
          set par(leading: body-leading, first-line-indent: 0pt)
          h(para-indent)
          context [#para-counter.display()\.]
          h(0.3in)
          md(t)
        })
        v(body-leading)
      }
    }
    if has-pending {
      block(width: 100%, sticky: true, { pending; v(pitch + body-leading) })
    }
    piece
    pending = []
    has-pending = false
  }
  if has-pending { block(breakable: false, width: 100%, pending) }
}

/// Dated line, then the signature block: the firm, "/s/" over the signer's name, and the signer's
/// address, telephone, email, Arkansas Supreme Court ID (LR 5.5(c)(1), when it applies) and role.
#let signature-block(meta) = {
  v(body-leading)
  block(breakable: false, grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      if "firm" in meta.signature { line-stack(meta.signature.firm) }
      v(single-leading * 2)
      line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  ))
}

#let arwd-complaint(meta, body) = {
  let para-counter = counter("paragraph")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-number(),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered bold section in capitals; level 2 a centered bold sub-heading as typed;
  // level 3 a bold left-aligned sub-heading. Each heading takes one line of double spacing above and below.
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: 0pt, below: 0pt,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: 0pt, below: 0pt,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: 0pt, below: 0pt,
    text(weight: "bold", it.body))

  // First page: court title, caption, title of the paper.
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
  title-block(meta)
  v(body-leading)

  if "lead_in" in meta {
    set par(leading: body-leading)
    h(para-indent)
    inl(meta.lead_in)
    v(0pt)
  }

  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
}
