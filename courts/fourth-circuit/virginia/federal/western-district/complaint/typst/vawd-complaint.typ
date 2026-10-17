// Complaint for the U.S. District Court for the Western District of Virginia (vawd).
// Rules: Fed. R. Civ. P. 10(a) (caption: court, title, file number, Rule 7(a) designation), 10(b) (numbered
// paragraphs); W.D. Va. Local Rule 11(a) (attorney's office address, telephone, e-mail and bar number on the
// pleading). The local rules set no type size, margin or spacing for pleadings: the values below are the
// convention both filed exemplars show (see ../README.md). Content-agnostic: every case word comes from the
// sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to the exemplars; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no rule; Times New Roman substitute per docs/FONTS.md, vendored in fonts/. See README "Known gaps".
#let type-size = 12pt                   // no rule sets a size; 12 pt, the size of the Times used by the exemplars (docs/FONTS.md)
#let line-pitch = 27.6pt                // double spacing: baseline-to-baseline distance measured on both exemplars
#let body-leading = line-pitch - 1.15em // the text runs in a 1.15em line box (top-edge 0.9em, bottom-edge -0.25em); the gap makes the 27.6 pt pitch
#let single-pitch = 13.8pt              // one line of single-spaced text (1.15 x 12 pt, word-processor single spacing); the ")" marks are counted in these rows
#let single-leading = single-pitch - 1.15em // single spacing: the 1.15em line box plus this gap is single-pitch
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)
#let para-indent = 0.5in                // first line of a numbered paragraph
#let caption-width = 3.3in              // width of the party block in the box caption
#let footer-size = 12pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vawd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A frontmatter field the template cannot do without: a missing one stops the build.
#let need(meta, key) = {
  if key in meta and meta.at(key) != none { meta.at(key) } else { panic("vawd-complaint: the sample frontmatter needs `" + key + "`") }
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  align(center)[
    UNITED STATES DISTRICT COURT \
    WESTERN DISTRICT OF VIRGINIA \
    #upper(need(meta, "division"))
  ]
}

/// Box caption: the party block is closed by a rule at its right and bottom; the file number sits opposite.
#let caption-box(meta) = {
  let parties = need(meta, "caption").parties
  let items = ()
  for (i, p) in parties.enumerate() {
    if i > 0 { items.push(pad(left: 0.6in, [v.])) }
    for n in p.names { items.push(inl(n)) }
    items.push(pad(left: 1.5in, inl(p.designation)))
  }
  grid(
    columns: (caption-width, 1fr),
    column-gutter: 0.15in,
    block(width: caption-width, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.12in, bottom: 0.12in, top: 0.06in), {
      set par(leading: single-leading, first-line-indent: 0pt, justify: false)
      stack(dir: ttb, spacing: 0.9em, ..items)
    }),
    align(horizon, block(inset: (left: 0.1in), {
      set par(leading: single-leading, first-line-indent: 0pt)
      [#meta.at("case_label", default: "Civil Action No.") #need(meta, "case_number")]
    })),
  )
}

/// ")" caption: a column of ")" marks beside the party block. Each party line is one row of the grid; its ")"
/// column gets as many marks as the line takes up (a name can wrap), so the marks follow the text.
#let caption-parens(meta) = {
  let parties = need(meta, "caption").parties
  let rows = ()
  for (i, p) in parties.enumerate() {
    if i > 0 { rows.push(pad(left: 0.6in, [v.])) }
    for n in p.names { rows.push(inl(n)) }
    rows.push(pad(left: 1.5in, inl(p.designation)))
  }
  // Rows are sized from the measured height of the line, so the call is in a context.
  let cell-text(c) = context {
    let n = calc.max(1, calc.ceil(measure(width: caption-width, c).height / single-pitch))
    block(width: caption-width, height: n * single-pitch, c)
  }
  let cell-marks(c) = context {
    let n = calc.max(1, calc.ceil(measure(width: caption-width, c).height / single-pitch))
    stack(dir: ttb, spacing: 0pt, ..range(n).map(_ => block(height: single-pitch, width: 100%, align(center)[)])))
  }
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  grid(columns: (caption-width, 0.4in), ..rows.map(c => (cell-text(c), cell-marks(c))).flatten())
}

#let cover(meta) = {
  court-title(meta)
  v(line-pitch)
  if need(meta, "caption").at("style", default: "box") == "parens" {
    caption-parens(meta)
    v(line-pitch * 0.5)
    [#meta.at("case_label", default: "Civil Action No.") #need(meta, "case_number")]
  } else {
    caption-box(meta)
  }
  if "title" in meta and meta.title != none {
    v(line-pitch * 0.5)
    align(center, strong(upper(inl(meta.title))))
  }
  v(line-pitch)
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b))
// ---------------------------------------------------------------------------

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a list is
/// one numbered paragraph. Headings and lists are unnumbered; the first paragraph after the prayer heading
/// (the WHEREFORE clause) is unnumbered too. Numbering is applied per chunk, not with a `show par` rule: a show
/// rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  let unnumbered-next = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      if t.contains("PRAYER") { unnumbered-next = true }
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        block(breakable: false, width: 100%, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      let text-body = cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      let piece = if unnumbered-next {
        block(width: 100%, { set par(leading: body-leading); h(para-indent); text-body })
      } else {
        para-counter.step()
        block(width: 100%, {
          set par(leading: body-leading)
          context [#h(para-indent)#(para-counter.display()).#h(0.3in)#text-body]
        })
      }
      unnumbered-next = false
      if has-pending {
        block(breakable: false, width: 100%, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: 100%, pending) }
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Civ. P. 11(a); W.D. Va. Local Rule 11(a))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, width: 100%, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [DATED: #need(meta, "date").]
    v(line-pitch)
    pad(left: 3.25in, {
      [Respectfully submitted,]
      v(line-pitch)
      for l in sig.at("firm", default: ()) { inl(l); linebreak() }
      v(line-pitch)
      [By: /s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let vawd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "division", "caption", "date", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set document(
    title: "Complaint, No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set page(
    paper: "us-letter",
    margin: margins,
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    // A 1.15em line box (a word-processor single line); Liberation Serif's ascender-descender box is only 0.909em,
    // so single-spaced lines with no gap would touch.
    top-edge: 0.9em, bottom-edge: -0.25em,
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 a centered caps section; level 2 a centered bold sub-heading (COUNT I, its title);
  // level 3 a bold left-aligned sub-heading. Kept with the paragraph after them (a heading never ends a page).
  show heading.where(level: 1): it => block(width: 100%, above: line-pitch, below: 0pt, sticky: true,
    text(size: type-size, align(center, strong(upper(it.body)))))
  show heading.where(level: 2): it => block(width: 100%, above: line-pitch * 0.5, below: 0pt, sticky: true,
    text(size: type-size, align(center, strong(it.body))))
  show heading.where(level: 3): it => block(width: 100%, above: line-pitch, below: 0pt, sticky: true,
    text(size: type-size, strong(it.body)))

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    block(width: 100%, {
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(body, para-counter)

  signature-block(meta)
}
