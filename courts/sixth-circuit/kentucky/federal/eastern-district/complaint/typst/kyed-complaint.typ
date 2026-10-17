// U.S. District Court, Eastern District of Kentucky: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (KYED-...) refer to ../README.md, which quotes the
// rule text (Fed. R. Civ. P. 8(a), 10(a), 10(b); E.D. Ky. LR 5.2(a)). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The body is markdown rendered by
// cmarker; the caption, signature and metadata come from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"   // KYED-FORM-002: proportionally spaced font; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // KYED-FORM-002: at least 12-point type.
#let line-pitch = 24pt                  // KYED-FORM-001: text double spaced. Measured on the render (README.md).
#let body-leading = 1.345em             // gap between lines of body text, tuned so the baseline pitch is line-pitch.
#let single-leading = 0.495em            // caption, headings, block quotes, signature block: single spaced.
#let margin-all = 1in                   // KYED-FORM-001: at least one inch on all sides.
#let text-width = 8.5in - 2 * margin-all
#let para-indent = 0.5in                // first-line indent of numbered paragraphs.
#let footer-size = 12pt                 // page number; the footer is not a text block but is kept at the form size.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics, bold, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Whole numbered lines: the content is measured and its block is rounded up to a multiple of `line-pitch`,
/// so whatever follows it stays on the grid. Without the measure, a multi-line paragraph is laid out
/// shorter than it draws and the next paragraph lands on its last line (seen on the first render).
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: 100%, height: calc.ceil(h / line-pitch) * line-pitch, above: 0pt, below: 0pt, c)
}

#let need(meta, key) = {
  if key not in meta { panic("kyed-complaint: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kyed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Lines in a single-spaced stack (caption, signature block, block quotes).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption (KYED-FIRST-001, KYED-FIRST-002)
// ---------------------------------------------------------------------------

/// Court title, centered and bold, one line per entry in the frontmatter `court` list.
#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  align(center, strong(for l in need(meta, "court") { [#upper(l)] + linebreak() }))
}

/// Parties: each party's names, then its designation right-aligned; "v." between the parties.
#let party-column(meta) = {
  let parties = need(meta, "caption")
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for (i, p) in parties.enumerate() {
    if i > 0 {
      v(line-pitch * 0.5)
      pad(left: 1.2in, [v.])
      v(line-pitch * 0.5)
    }
    for n in p.names { inl(n); linebreak() }
    if p.designation != "" {
      v(single-leading)
      align(right, pad(right: 0.3in, inl(p.designation)))
    }
  }
}

#let caption(meta) = {
  // Civil action number and the e-filing legend sit centered above the rule (as in the exemplar).
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  align(center)[Civil Action No. #need(meta, "case_number")]
  if "electronically_filed" in meta and meta.electronically_filed {
    v(single-leading)
    align(center)[ELECTRONICALLY FILED]
  }
  v(line-pitch * 0.5)
  block(width: 100%, stroke: (bottom: 0.75pt), height: 0pt)
  v(line-pitch * 0.5)
  grid(
    columns: (1fr, 2.4in),
    column-gutter: 0.25in,
    party-column(meta),
    {
      set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
      if "jury_demand" in meta and meta.jury_demand { [JURY DEMAND] }
    },
  )
  v(line-pitch * 0.5)
  block(width: 100%, stroke: (bottom: 0.75pt), height: 0pt)
}

// ---------------------------------------------------------------------------
// Body (KYED-CONT-001: numbered paragraphs, KYED-CONT-002: lettered lists)
// ---------------------------------------------------------------------------

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown is one
/// unit: a heading, a list, a block quote (`> `), an unnumbered paragraph (`:: `), or a numbered paragraph.
/// Numbering is applied per chunk, not with a `show par` rule (a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15).
#let body-chunks(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      let items = {
        set par(leading: body-leading, first-line-indent: 0pt)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending { block(breakable: false, width: 100%, { pending; items }) } else { items }
      pending = []
      has-pending = false
    } else if t.starts-with(">") {
      // A block quotation: single spaced, indented both sides, not numbered (the quoted policy clause).
      let lines = t.split("\n").map(l => l.trim().trim(">").trim()).join("\n")
      let quote = {
        set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        pad(left: 0.75in, right: 0.75in, bottom: body-leading * 0.7, cmarker.render(lines, raw-typst: false, smart-punctuation: true, h1-level: 1))
      }
      if has-pending { block(breakable: false, width: 100%, { pending; quote }) } else { quote }
      pending = []
      has-pending = false
    } else {
      // A paragraph: numbered, unless it is marked `:: ` (the opening sentence and the prayer lead-in).
      let unnumbered = t.starts-with("::")
      let text-body = if unnumbered { t.slice(2).trim() } else { t }
      let piece = if unnumbered {
        on-grid([#h(para-indent)#inl(text-body)])
      } else {
        para-counter.step()
        on-grid(context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(text-body, raw-typst: false, smart-punctuation: true, h1-level: 1)])
      }
      if has-pending { block(breakable: false, width: 100%, { pending; piece }) } else { piece }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: 100%, pending) }
}

// ---------------------------------------------------------------------------
// Signature block (KYED-SIG-001: Fed. R. Civ. P. 11(a) name, address, phone, email, bar number)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    grid(columns: (1fr, 3.1in), [], {
      [Respectfully submitted,]
      v(single-leading * 2)
      for l in sig.at("preamble", default: ()) { inl(l); linebreak() }
      v(single-leading * 2)
      [s/#sig.signer]
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let kyed-complaint(meta, md) = {
  for k in ("court", "caption", "case_number", "title", "signature") {
    let _ = need(meta, k)
  }
  let para-counter = counter("allegation")

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: margin-all,
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set document(title: need(meta, "title") + ", No. " + str(need(meta, "case_number")))
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centered caps section; level 2 a centered bold count heading; level 3 bold, left.
  show heading.where(level: 1): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    text(size: type-size, align(center, strong(upper(it.body)))))
  show heading.where(level: 2): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    text(size: type-size, align(center, strong(it.body))))
  show heading.where(level: 3): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    text(size: type-size, strong(it.body)))

  // ---- first page: court title, caption, title of the paper ----
  court-title(meta)
  v(line-pitch)
  caption(meta)
  align(center, block(above: line-pitch, below: line-pitch, strong(upper(need(meta, "title")))))

  // ---- body ----
  body-chunks(md, para-counter)

  signature-block(meta)
}
