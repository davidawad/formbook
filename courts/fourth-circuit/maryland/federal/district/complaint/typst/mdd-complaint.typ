// U.S. District Court for the District of Maryland (mdd): complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (LR-..., FRCP-...) refer to ../README.md, which quotes
// the rule text (D. Md. Local Rules, effective Dec. 1, 2025; Fed. R. Civ. P.). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"   // LR-102.2.b: Times New Roman or larger typeface. Metric-compatible substitute, vendored in /fonts (docs/FONTS.md).
#let type-size = 12pt                   // LR-102.2.b: at least 12 pt text (Times New Roman 12 pt).
#let footnote-size = 10pt               // LR-102.2.b: at least 10 pt footnotes.
#let num-size = 12pt                    // page numbers: not text under LR-102.2.b
#let line-pitch = 27.6pt                // LR-102.2.b: double-spaced = 2 x 1.15 x 12 pt (Times New Roman 12 pt, double in Word)
#let body-leading = 1.645em             // 0.655 em natural line + 1.645 em leading = 2.30 em = line-pitch at 12 pt (pdftotext -bbox check, Liberation Serif)
#let single-leading = 0.5em             // 0.655 em natural line + 0.5 em = 1.155 em: single spacing (Times New Roman 12 pt single, 1.15 em)
#let margin = 1in                       // LR-102.2.b: one-inch margin on all sides
#let margins = (top: margin, bottom: margin, left: margin, right: margin)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.6in               // width of the party column of the caption
#let max-pages = 40                     // LR-103.1.d: a pleading shall not exceed forty pages

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, the section sign, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mdd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mdd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A stack of single-spaced lines (one item per line; each item may be markdown).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture: LR-102.2.b, page numbers at the bottom of every page after the first
// ---------------------------------------------------------------------------

#let page-footer = context {
  let loc = here()
  if loc.page() > 1 {
    align(center, text(size: num-size, numbering(loc.page-numbering(), ..counter(page).at(loc))))
  }
}

// ---------------------------------------------------------------------------
// Caption and title. LR-102.2.a: the original complaint carries the names and addresses of all parties and
// the county of residence of any Maryland party. FRCP 10(a): court name, title, file number, designation.
// ---------------------------------------------------------------------------

/// One party in the caption: names, then address and county (if any), then the designation, indented.
#let party-block(p) = {
  let lines = p.names
  lines += need(p, "address")
  if "county" in p { lines.push(p.county) }
  stack(
    dir: ttb, spacing: single-leading,
    line-stack(lines),
    v(line-pitch * 0.5),
    pad(left: 1.8in, inl(need(p, "designation"))),
  )
}

#let caption(meta) = {
  let parties = need(meta.caption, "parties")
  for p in parties {
    if "Maryland" in need(p, "address").join(" ") and "county" not in p {
      panic("mdd-complaint: LR-102.2.a: a Maryland party needs its county of residence (`county`)")
    }
  }
  table(
    columns: (caption-left, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(right: 1.2em, bottom: 1em, {
      for (k, p) in parties.enumerate() {
        party-block(p)
        if k < parties.len() - 1 {
          v(line-pitch * 0.5)
          align(center, [v.])
          v(line-pitch * 0.5)
        }
      }
    }),
    pad(left: 1.2em, top: 0.3em, {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      let num = meta.at("case_number", default: "")
      if num == "" { [Case No. #box(width: 1.6in, line(length: 100%, stroke: 0.5pt))] } else { [Case No. #num] }
    }),
  )
}

// ---------------------------------------------------------------------------
// Signature block. LR-102.1.b.i: at the bottom of every court document, counsel states name, address,
// telephone, email and fax number, and bar number. LR-102.1.a: counsel signs.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  for k in ("name", "bar", "firm", "address", "phone", "fax", "email", "role") {
    if k not in sig { panic("mdd-complaint: LR-102.1.b.i: the signature block needs `" + k + "`") }
  }
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(
      columns: (1fr, 3.1in),
      [#if "date" in meta [Dated: #meta.date]],
      line-stack((
        "Respectfully submitted,",
        "/s/ " + sig.name,
        sig.name,
        sig.bar,
        ..sig.firm,
        ..sig.address,
        "Telephone: " + sig.phone,
        "Facsimile: " + sig.fax,
        sig.email,
        sig.role,
      )),
    )
  })
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (FRCP 10(b)). Each blank-line-separated chunk that is neither a heading nor a
// list is one numbered paragraph; headings and lists are not numbered. Numbering is applied per chunk, not
// with a `show par` rule (a show rule that re-wraps paragraph content recurses without end in typst 0.15).
// ---------------------------------------------------------------------------

/// One chunk of the body (a heading, a list, an unnumbered paragraph or a numbered paragraph).
#let chunk(c, para-counter) = {
  let t = c.trim()
  if t.starts-with("#") {
    cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
  } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
    // Lettered prayer items (a), (b), ... ; a list may break across pages.
    set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
    set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
    cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    parbreak()
  } else if t.starts-with("^ ") {
    // Unnumbered paragraph (the WHEREFORE paragraph and the jury demand): a leading "^ " in the sample.
    [#h(para-indent) #inl(t.slice(2))]
    parbreak()
  } else {
    para-counter.step()
    [#h(para-indent) #context [#para-counter.display().] #h(0.3in) #inl(t)]
    parbreak()
  }
}

/// The body, then the signature block. The last chunk (the jury demand) and the signature block stay on one
/// page, so a signature never stands alone at the top of a page.
#let allegations(body, para-counter, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (k, c) in chunks.enumerate() {
    if k == chunks.len() - 1 {
      block(breakable: false, {
        chunk(c, para-counter)
        tail
      })
    } else {
      chunk(c, para-counter)
    }
  }
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let mdd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "brief_title", "signature") {
    let _ = need(meta, k)
  }
  let para-counter = counter("allegation")

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, numbering: "1", footer: page-footer)
  set document(title: need(meta, "brief_title"), author: need(meta, "signature").name)
  // Line box: Liberation Serif's natural line is 0.655 em (no top-edge/bottom-edge override, which would enlarge it).
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
  )
  // Paragraph spacing equals the leading: typst adds leading only inside a paragraph, so the gap between
  // paragraphs needs the same extra space to keep one double-spaced pitch throughout.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings: level 1 centered caps; level 2 bold, hanging; level 3 bold italic; level 4 centered (cause sub-titles).
  show heading: set block(sticky: true)
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading,
    text(size: type-size, align(center, strong(upper(it.body)))))
  show heading.where(level: 2): it => block(width: 100%, above: body-leading, below: body-leading,
    text(size: type-size, par(hanging-indent: 0.5in, first-line-indent: 0pt, strong(it.body))))
  show heading.where(level: 3): it => block(width: 100%, above: body-leading, below: body-leading,
    text(size: type-size, par(first-line-indent: 0pt, strong(emph(it.body)))))
  show heading.where(level: 4): it => block(width: 100%, above: 0pt, below: body-leading,
    text(size: type-size, align(center, it.body)))

  // ---- cover: court, caption, title ----
  align(center, line-stack(need(meta, "court")))
  v(line-pitch)
  caption(meta)
  v(line-pitch)
  align(center, strong(upper(inl(meta.brief_title))))
  v(line-pitch * 0.5)

  // Unnumbered lead-in (the "for its complaint against ... alleges as follows" paragraph), if the sample has one.
  if "lead_in" in meta {
    h(para-indent)
    inl(meta.lead_in)
    parbreak()
  }

  allegations(body, para-counter, signature-block(meta))

  // ---- end check: LR-103.1.d, the pleading's total length ----
  context {
    let n = counter(page).get().first()
    if n > max-pages {
      panic("mdd-complaint: LR-103.1.d: a pleading shall not exceed " + str(max-pages) + " pages (this one has " + str(n) + ")")
    }
  }
}
