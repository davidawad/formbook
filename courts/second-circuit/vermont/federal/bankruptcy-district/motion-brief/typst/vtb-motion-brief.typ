// U.S. Bankruptcy Court, District of Vermont: motion with memorandum (FRBP 9013; Vt. LBR 9013-1, 9013-5, 9013-6).
//
// Rule-driven and content-agnostic. Requirement IDs (VT-MB-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed paper, no forced line
// breaks. The body is markdown rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same sample file (contract: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in /fonts (no system fonts). Not set by any Vt. LBR.
#let type-size = 12pt                    // Vt. LBR 5005-1 sets no size; 12 pt is the court's usual practice (README, gap 2).
#let body-leading = 1.665em              // VT-AC-003: 2.0 line spacing; measured pitch 27.8 pt at 12 pt (README).
#let single-leading = 0.45em             // quotations, caption, signature block: single-spaced.
#let page-margin = 1in                   // VT-AC-002: no less than 3/4 inch, exclusive of page numbers.
#let indent = 0.5in                      // first-line indent of numbered paragraphs.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, bold) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("vtb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vtb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (VT-AC-004: FRBP 7010 and Official Form 416A; FRBP 9004(b))
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set par(leading: single-leading)
  align(center)[
    #for l in need(meta, "court") [*#l*\ ]
  ]
  v(1.5em)
  let d = need(meta, "debtor")
  let c = need(meta, "caption")
  table(
    columns: (3.35in, 1fr),
    stroke: none,
    inset: 0pt,
    table.cell(
      stroke: (right: 0.7pt + black, bottom: 0.7pt + black),
      inset: (right: 0.18in, bottom: 0.14in, top: 0pt),
    )[
      In re: #d.name, \
      #h(1.5in) Debtor.
    ],
    table.cell(inset: (left: 0.25in))[
      Chapter #d.chapter \
      Case No. #d.case_no
    ],
    table.cell(
      stroke: (right: 0.7pt + black, bottom: 0.7pt + black),
      inset: (right: 0.18in, top: 0.9em, bottom: 0.14in),
    )[
      #for p in c.plaintiffs [#p, \ ]
      #h(1.5in) Plaintiff#if c.plaintiffs.len() > 0 [,] \
      #h(0.5in) v. \
      #for dn in c.defendants [#dn; \ ]
      #h(1.5in) Defendants.
    ],
    table.cell(inset: (left: 0.25in, top: 0.9em))[
      Adv. Proc. No. #need(meta, "adv_no")
    ],
  )
  v(1.5em)
  align(center)[#strong(inl(need(meta, "title")))]
  v(1em)
}

// ---------------------------------------------------------------------------
// Body (VT-AC-005: numbered allegations, FRCP 10(b) via FRBP 7010)
// ---------------------------------------------------------------------------

/// Blank-line-separated blocks of the markdown body.
#let body-blocks(body) = (
  body
    .replace("\r\n", "\n")
    .split("\n\n")
    .map(s => s.trim())
    .filter(s => s.len() > 0)
)

#let heading(level, text) = {
  let t = text.trim()
  if level == 1 {
    block(width: 100%, sticky: true, above: 1.2em, below: 0.6em, align(center, strong(inl(t))))
  } else if level == 2 {
    block(width: 100%, sticky: true, above: 1.0em, below: 0.6em, align(center, strong(inl(t))))
  } else {
    block(width: 100%, sticky: true, above: 0.8em, below: 0.6em, strong(emph(inl(t))))
  }
}

#let render-blocks(blocks, unnumbered: 0) = {
  // The first `unnumbered` paragraphs (the introduction, as filed) carry no number.
  let n = 0
  let seen = 0
  for b in blocks {
    if b.starts-with("### ") {
      heading(3, b.slice(4))
    } else if b.starts-with("## ") {
      heading(2, b.slice(3))
    } else if b.starts-with("# ") {
      heading(1, b.slice(2))
    } else if b.starts-with("> ") {
      // Quotation: single-spaced, indented both sides (LBR 5005-1(a)(5)); one quoted paragraph per block.
      pad(left: 0.5in, right: 0.5in, {
        set par(leading: single-leading)
        inl(b.slice(2))
      })
    } else if b.starts-with("1. ") or b.starts-with("- ") {
      // Prayer and other lists: lettered (a), (b), ... ; one item per block.
      let items = b.split("\n")
      for (i, it) in items.enumerate() {
        let text = it.replace(regex("^\\s*(\\d+\\.|-)\\s+"), "")
        block(width: 100%, pad(left: indent, [(#"abcdefghijklmnopqrstuvwxyz".at(i)) #inl(text)]))
      }
    } else {
      seen += 1
      if seen <= unnumbered {
        block(width: 100%, [#h(indent) #inl(b)])
      } else {
        n += 1
        block(width: 100%, [#h(indent) #n. #inl(b)])
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (VT-AC-006: LBR 5005-1(b), attorney identification below the signature line)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let s = need(meta, "signature")
  set par(leading: single-leading)
  v(1.5em)
  block(breakable: false, {
    s.at("dated")
    v(1.5em)
    pad(left: 3.0in, {
      for l in s.at("lines") [#l \ ]
    })
  })
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let vtb-motion-brief(meta, body) = {
  // VT-MB-001 (LBR 9013-1(f)(1)): a stipulated motion carries "stipulated" in its title.
  if meta.at("stipulated", default: false) and not lower(need(meta, "title")).contains("stipulated") {
    panic("vtb-motion-brief: a stipulated motion must include the word \"stipulated\" in its title (Vt. LBR 9013-1(f)(1))")
  }
  // VT-MB-002 (LBR 9013-5(a)): a motion and memorandum filed as one document name both in the caption.
  if meta.at("memorandum", default: false) and not lower(need(meta, "title")).contains("memorandum") {
    panic("vtb-motion-brief: a combined motion and memorandum must name the memorandum in the title (Vt. LBR 9013-5(a))")
  }
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size)
  set par(justify: false, leading: body-leading, first-line-indent: 0pt)
  // Paragraph-to-paragraph gap equals the leading, so every baseline step is one 2.0 line pitch.
  set block(spacing: body-leading)
  caption(meta)
  render-blocks(body-blocks(body), unnumbered: meta.at("unnumbered", default: 0))
  signature(meta)
}
