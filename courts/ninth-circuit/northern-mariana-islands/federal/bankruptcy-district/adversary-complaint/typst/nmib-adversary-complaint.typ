// Adversary complaint for the Bankruptcy Court of the Northern Mariana Islands (Bankruptcy Division).
// Rules: FRBP 7001 (proceeding is an adversary proceeding), 7003 (commencement; Fed. R. Civ. P. 3 applies),
// 7008 (pleading; statement of consent to final orders), 7010 (Fed. R. Civ. P. 10 applies; caption must
// substantially conform to Official Form 416D); LBR 5005-1(b) (caption: chapter), LBR 7003-1 (cover sheet,
// not generated here), LR 5.2 form as summarized for LBR 9004-1 (see ../README.md, NMIB-ADV-...).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // NMIB-ADV-FORM-002: serif, vendored in /fonts
#let type-size = 13pt                   // NMIB-ADV-FORM-002: 12 point or larger; 13 pt is a style choice (see README.md)
#let pitch = 24pt                       // NMIB-ADV-FORM-003: double spacing on numbered lines
#let lines-per-page = 24                // NMIB-ADV-FORM-004: numbers 1 to 24 down the margin (as the filed motion in this court)
#let page-w = 8.5in
#let page-h = 11in
#let top-margin = 1.5in                 // NMIB-ADV-FORM-001: top margin at least 1.5 in (LR 5.2 summary)
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 1.5 in: holds the footer
#let left-margin = 1.3in
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let body-leading = 0.54em              // one body line per numbered line (tuned at 13 pt, as in the motion template)
#let single-leading = 0.2em             // counsel, caption, signature, headings that wrap
#let para-indent = 0.5in
#let caption-left = 3.2in               // width of the party column of the caption
#let counsel-lines = 7                  // the court title starts after the counsel block, at least on line 8

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmib-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nmib-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A heading: one numbered line, kept with the paragraph after it (a heading never ends a page).
#let heading-line(c) = block(width: text-width, height: pitch, above: 0pt, below: 0pt, sticky: true, context {
  assert(measure(width: text-width, c).height <= pitch, message: "nmib-adversary-complaint: a heading must fit on one numbered line")
  c
})

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 24 down the left margin, one per numbered line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.45in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

#let footer-block(title, case-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: 10pt)
    align(center, context counter(page).display())
    v(4pt)
    grid(
      columns: (1fr, auto),
      upper(title),
      [CASE NO. #case-number],
    )
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7), court title, caption (Official Form 416D), title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let counsel-block(meta) = context {
  // Lines 1-7 at least; more counsel lines push the court title down.
  let h = measure(width: text-width, line-stack(need(meta, "counsel"))).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch,
    line-stack(need(meta, "counsel")))
}

#let court-title(meta) = {
  for l in need(meta, "court") {
    on-grid(align(center, text(weight: "bold", upper(l))))
  }
}

/// Form 416D: each side is a block (In re debtor; plaintiff; defendant) with its designation under it.
#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    let rows = ()
    for side in need(meta, "caption") {
      rows += side.names + (side.designation,)
      rows.push("")
    }
    line-stack(rows.slice(0, rows.len() - 1))
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("Case No. " + need(meta, "case_number"), "Chapter " + need(meta, "chapter")))
    v(pitch * 0.5)
    // The clerk assigns the adversary number; a blank is printed until it is known.
    let adv = meta.at("adv_number", default: "_" * 8)
    [Adv. Proc. No. #adv]
    v(pitch * 0.5)
    text(weight: "bold", inl(need(meta, "brief_title")))
    if "jury_demand" in meta and meta.jury_demand {
      v(pitch * 0.5)
      text(weight: "bold", "DEMAND FOR JURY TRIAL")
    }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  v(pitch)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  v(pitch)
  on-grid(grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #need(meta, "date")],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(pitch * 0.5)
      line-stack(need(meta, "signature").firm)
      v(pitch * 0.5)
      line-stack(("By: /s/ " + need(meta, "signature").signer, need(meta, "signature").signer) + need(meta, "signature").lines)
    },
  ))
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (Fed. R. Civ. P. 10(b)). Headings and lists are rendered unnumbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
/// A paragraph that starts with "::" is unnumbered (a lead-in such as WHEREFORE); the marker is not printed.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else {
      let piece = if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
        // A list may break across pages; only a heading in front of it is kept with its first line.
        // Items are spaced by body-leading, so each item fills whole lines; the trailing v() closes the last one.
        // Not wrapped in on-grid: a fixed-height block cannot break between pages, and a list must.
        {
          set par(leading: body-leading)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
          v(body-leading)
        }
      } else if t.starts-with("::") {
        on-grid({ set par(leading: body-leading); h(para-indent); cmarker.render(t.slice(2).trim(), raw-typst: false, smart-punctuation: true, h1-level: 1) })
      } else {
        // A numbered paragraph breaks across pages like any text; only a heading in front of it is kept with its first line.
        para-counter.step()
        on-grid({ set par(leading: body-leading); context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)] })
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let nmib-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")
  let footer-title = need(meta, "footer_title")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(footer-title, need(meta, "case_number")),
  )
  set document(
    title: need(meta, "brief_title") + ", Adv. Proc. No. " + meta.at("adv_number", default: "(blank)"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",  // same line box as the motion template: body-leading gives a 24 pt pitch
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => heading-line(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-line(align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-line(text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  // Body: numbered allegations (Fed. R. Civ. P. 10(b)); markdown lists become (a), (b), ...
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
}
