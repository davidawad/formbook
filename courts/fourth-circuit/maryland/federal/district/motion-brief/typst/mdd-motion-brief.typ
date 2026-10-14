// U.S. District Court for the District of Maryland (mdd): memorandum in support of a motion (FRCP 12(b)).
//
// Rule-driven and content-agnostic. Requirement IDs (LR-..., FRCP-...) refer to ../README.md, which quotes
// the rule text (D. Md. Local Rules, effective Dec. 1, 2025; Fed. R. Civ. P.). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"        // LR-102.2.b: Times New Roman or larger typeface. Vendored in /fonts; see ../README.md.
#let type-size = 13pt                   // LR-102.2.b: at least 12 pt text. 13 pt EB Garamond matches TNR 12 pt cap height (README).
#let footnote-size = 11pt               // LR-102.2.b: at least 10 pt footnotes (same equivalence, README).
#let num-size = 12pt                    // page numbers: not text under LR-102.2.b
#let line-pitch = 27.6pt                // LR-102.2.b: double-spaced = 2 x 1.15 x 12 pt (Times New Roman 12 pt, double in Word)
#let body-leading = 1.47em              // 0.65 em natural line + 1.47 em leading = 2.12 em = line-pitch at 13 pt (pdftotext -bbox check)
#let single-leading = 0.5em             // 0.65 em natural line + 0.5 em = 1.15 em: single spacing (Times New Roman 12 pt single)
#let margin = 1in                       // LR-102.2.b: one-inch margin on all sides
#let margins = (top: margin, bottom: margin, left: margin, right: margin)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let max-memo-pages = 30                // LR-105.3: a memorandum in support shall not exceed thirty pages (excl. TOC)
#let toc-threshold = 15                 // LR-105.4: a table of contents is required above fifteen pages

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, the section sign, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mdd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mdd-motion-brief: the sample must start with a YAML frontmatter block") }
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
// Caption and title. LR-102.2.a: every filing other than the original complaint carries a short caption:
// the names of the first plaintiff and the first defendant only, and the civil action number.
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let parties = need(meta, "caption").at("parties")
  if parties.len() != 2 {
    panic("mdd-motion-brief: LR-102.2.a: the short caption names the first plaintiff and the first defendant only (" + str(parties.len()) + " parties given)")
  }
  table(
    columns: (caption-left, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.75pt) } else { none },
    pad(right: 1.2em, bottom: 1em, {
      for (k, p) in parties.enumerate() {
        line-stack(p.names)
        v(line-pitch * 0.5)
        pad(left: 1.8in, inl(need(p, "designation")))
        if k < parties.len() - 1 {
          v(line-pitch * 0.5)
          align(center, [v.])
          v(line-pitch * 0.5)
        }
      }
    }),
    pad(left: 1.2em, top: 0.3em, {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      [Case No. #need(meta, "case_number")]
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
    if k not in sig { panic("mdd-motion-brief: LR-102.1.b.i: the signature block needs `" + k + "`") }
  }
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(
      columns: (1fr, 3.1in),
      [#if "date" in meta [Dated: #meta.date]],
      line-stack((
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
// Certificate of service (LR-102.1.c). A paper filed through CM/ECF is served by its notice of electronic
// filing, so a certificate is optional here; a sample that carries one has it after the signature block.
// ---------------------------------------------------------------------------

#let certificate-block(meta) = {
  let cert = meta.at("certificate", default: none)
  if cert != none {
    heading(level: 1, numbering: none)[Certificate of Service]
    set par(first-line-indent: para-indent)
    inl(need(cert, "text"))
    parbreak()
    block(breakable: false, above: line-pitch, {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      line-stack(("/s/ _______________________", need(cert, "signer")))
    })
  }
}

// ---------------------------------------------------------------------------
// Table of contents (LR-105.4). Built from the headings of the body, with page numbers in the body's numbering.
// ---------------------------------------------------------------------------

#let toc-section() = {
  align(center, strong[TABLE OF CONTENTS])
  v(line-pitch * 0.5)
  outline(title: none, depth: 3, indent: 0.5in)
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let mdd-motion-brief(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "case_number", "brief_title", "signature") {
    let _ = need(meta, k)
  }
  let toc = meta.at("toc", default: false)

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, numbering: "1", footer: page-footer)
  set document(title: need(meta, "brief_title"), author: need(meta, "signature").name)
  // Line box: EB Garamond's natural line is 0.65 em (no top-edge/bottom-edge override, which would enlarge it).
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  // Paragraph spacing equals the leading: typst adds leading only inside a paragraph, so the gap between
  // paragraphs needs the same extra space to keep one double-spaced pitch throughout.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  show enum: set par(first-line-indent: 0pt)
  show list: set par(first-line-indent: 0pt)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings: level 1 centered caps; level 2 bold, hanging; level 3 bold italic.
  show heading: set block(sticky: true)
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading,
    text(size: type-size, align(center, strong(upper(it.body)))))
  show heading.where(level: 2): it => block(width: 100%, above: body-leading, below: body-leading,
    text(size: type-size, par(hanging-indent: 0.5in, first-line-indent: 0pt, strong(it.body))))
  show heading.where(level: 3): it => block(width: 100%, above: body-leading, below: body-leading,
    text(size: type-size, par(first-line-indent: 0pt, strong(emph(it.body)))))

  // Cover: court, short caption, title (LR-102.2.a; the title is the paper's, LR-102.1.b.i does not apply to it).
  let cover = {
    align(center, line-stack(need(meta, "court")))
    v(line-pitch)
    caption(meta)
    v(line-pitch)
    align(center, strong(upper(inl(meta.brief_title))))
    v(line-pitch * 0.5)
  }

  // The memorandum proper, then the signature block and the certificate.
  let memo = {
    cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    block(breakable: false, above: 0pt, {
      signature-block(meta)
      certificate-block(meta)
    })
    // ---- end check: LR-105.3 page limit (body only; the cover and TOC are not counted, LR-105.3(b)) ----
    context {
      let n = counter(page).get().first()
      if n > max-memo-pages {
        panic("mdd-motion-brief: LR-105.3: a memorandum shall not exceed " + str(max-memo-pages) + " pages (this one has " + str(n) + ")")
      }
      if not toc and n > toc-threshold {
        panic("mdd-motion-brief: LR-105.4: a memorandum over " + str(toc-threshold) + " pages needs a table of contents (set `toc: true`)")
      }
    }
  }

  if toc {
    page(numbering: none, footer: none, cover)
    page(numbering: "i", {
      counter(page).update(1)
      toc-section()
    })
    page(numbering: "1", {
      counter(page).update(1)
      memo
    })
  } else {
    cover
    memo
  }
}
