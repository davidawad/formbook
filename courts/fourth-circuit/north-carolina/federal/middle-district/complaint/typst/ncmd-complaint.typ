// U.S. District Court, Middle District of North Carolina: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (NCMD-...) refer to ../README.md, which quotes the
// rule text (M.D.N.C. Local Civil Rules, effective June 1, 2026; Fed. R. Civ. P. 8, 10, 38). No
// case-specific text, no coordinates measured off the exemplar, no forced line breaks. The markdown body
// is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"         // NCMD-FORM-002: proportional font; the rule names no face, so the default applies: Times New Roman substitute (docs/FONTS.md "No face named")
#let type-size = 13pt                    // NCMD-FORM-002: proportional font "no smaller than 13 point" (LR 7.1(a))
#let lines-per-page = 27                 // NCMD-FORM-003: "no more than 27 lines of regularly spaced text on a page" (LR 7.1(a))
#let pitch = 23pt                        // one double-spaced line; 27 x 23 pt = 621 pt, inside the 630 pt text height (see README.md)
#let body-leading = pitch - 1.15em      // the text runs in a 1.15em line box (top-edge 0.9em, bottom-edge -0.25em) (14.95 pt at 13 pt); the gap makes the 23 pt pitch
#let single-leading = 0.3em              // caption, headings, signature block, footnotes
#let top-margin = 1.25in                 // NCMD-FORM-004: top margin "not less than one and one-quarter inches" (LR 7.1(a))
#let bottom-margin = 1in                 // NCMD-FORM-004: bottom, left and right margins "not less than one inch" (LR 7.1(a))
#let side-margin = 1in
#let page-number-gap = 0.4in             // page number sits in the bottom margin (LR 7.1(a): "numbered at the bottom")
#let para-indent = 0.5in                 // first-line indent of numbered paragraphs
#let caption-left = 3.4in                // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncmd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, italics in titles, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ncmd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line per item; the stack keeps single spacing between items.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover block: court title, caption, title of the paper (NCMD-FIRST-001..003)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(need(meta, "court").map(l => [#l]).join(linebreak()))))
  if "division" in meta and meta.division != none {
    v(pitch * 0.5)
    align(center, strong(upper(meta.division)))
  }
}

#let caption(meta) = {
  let sides = need(meta, "caption").parties
  table(
    columns: (caption-left, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(right: 1.2em, bottom: 1em, {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      for (i, side) in sides.enumerate() {
        line-stack(side.names)
        v(single-leading)
        pad(left: 1.2in, inl(side.designation))
        if i < sides.len() - 1 { v(pitch * 0.5); align(center)[v.]; v(pitch * 0.5) }
      }
    }),
    pad(left: 1.2em, top: 0.3em, {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      [Civil Action No. #need(meta, "case_number")]
      v(pitch * 0.5)
      strong(upper(inl(need(meta, "brief_title"))))
      if "jury_demand" in meta and meta.jury_demand {
        v(pitch * 0.5)
        [(Jury Trial Demanded)]
      }
    }),
  )
}

// ---------------------------------------------------------------------------
// Signature block (NCMD-FIRST-004: telephone, mailing address, e-mail and state bar number)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  for k in ("firm", "signer", "bar_number", "address", "phone", "email", "role") {
    if k not in sig { panic("ncmd-complaint: signature block missing `" + k + "` (LR 7.1(b))") }
  }
  block(breakable: false, above: pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [This the #need(meta, "date_line")]
    v(pitch)
    grid(columns: (2.8in, 1fr), column-gutter: 0.2in, [], {
      [#sig.firm]
      v(pitch * 0.5)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      linebreak()
      inl(sig.bar_number)
      for l in sig.address { linebreak(); inl(l) }
      linebreak()
      inl(sig.phone)
      linebreak()
      inl(sig.email)
      v(pitch * 0.5)
      emph(inl(sig.role))
    })
  })
}

// ---------------------------------------------------------------------------
// Numbered allegations (FRCP 10(b)). Blank-line-separated markdown chunks: a heading, a list or a
// paragraph. A paragraph is numbered unless it lies under a level-1 heading named in
// `unnumbered_sections` (the prayer and the jury demand are not numbered).
// ---------------------------------------------------------------------------

#let allegations(body, para-counter, unnumbered, tail: none) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let numbered = true
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    // The last chunk is kept with the signature block, so a sign-off never stands alone on a page.
    let close(x) = if i == chunks.len() - 1 and tail != none {
      block(breakable: false, width: 100%, { x; tail })
    } else {
      x
    }
    if t.starts-with("# ") {
      numbered = not (upper(t.slice(2).trim()) in unnumbered)
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists are not numbered paragraphs. Items are spaced by body-leading; the trailing v() closes the last one.
      // Not wrapped in a fixed-height block: a list may break across pages.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      close(if has-pending {
        block(breakable: false, width: 100%, { pending; items })
      } else {
        items
      })
      pending = []
      has-pending = false
    } else {
      let piece = if numbered {
        para-counter.step()
        block(width: 100%, {
          set par(leading: body-leading, first-line-indent: 0pt)
          context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        })
      } else {
        block(width: 100%, {
          set par(leading: body-leading, first-line-indent: para-indent)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        })
      }
      if t.ends-with(":") {
        // A paragraph that introduces a list ("...that this Court:") stays with the list.
        pending += piece
        has-pending = true
      } else {
        close(if has-pending {
          block(breakable: false, width: 100%, { pending; piece })
        } else {
          piece
        })
        pending = []
        has-pending = false
      }
    }
  }
  if pending != [] { block(breakable: false, width: 100%, { pending; if tail != none { tail } }) }
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ncmd-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "brief_title", "date_line", "signature") {
    let _ = need(meta, k)
  }
  let unnumbered = meta.at("unnumbered_sections", default: ()).map(s => upper(s))

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, x: side-margin),
    footer: context align(center, text(size: type-size, counter(page).display())),
    footer-descent: page-number-gap,
  )
  set document(title: need(meta, "brief_title") + ", Civil Action No. " + need(meta, "case_number"))
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    // A 1.15em line box (a word-processor single line); Liberation Serif's ascender-descender box is only 0.909em,
    // so single-spaced lines with no gap would touch.
    top-edge: 0.9em, bottom-edge: -0.25em,
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings: level 1 a centered caps section; level 2 a bold sub-heading at the margin; level 3 bold italic.
  show heading.where(level: 1): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    strong(it.body))
  show heading.where(level: 3): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    strong(emph(it.body)))

  // ---- cover and caption on the first page ----
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)

  // ---- body ----
  let para-counter = counter("allegation")
  allegations(md, para-counter, unnumbered, tail: signature-block(meta))
}
