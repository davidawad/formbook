// Complaint for the U.S. District Court for the Northern District of Iowa (iand).
// Rules: N.D. Iowa LR 10(a) (8.5 x 11 inch paper), 10(b) (double spaced, one side, top margin of at least
// 1 inch, pages numbered at the bottom), 10(d) (caption with district, division, case number, litigants
// and a designation of the content); Fed. R. Civ. P. 8(a), 10(a), 10(b) (numbered paragraphs, one set of
// circumstances each); Fed. R. Civ. P. 38 (jury demand). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "TeX Gyre Termes"        // no typeface is named in LR 10; Termes matches the audited exemplar (docs/FONTS.md)
#let type-size = 12pt                   // no size is named in LR 10; 12 point is the usual federal filing size
#let pitch = 24pt                       // LR 10(b)(1): double spaced; the baseline pitch of body text
#let page-w = 8.5in                     // LR 10(a): 8 1/2 by 11 inch
#let page-h = 11in
#let margin = 1in                       // LR 10(b)(3): top margin of at least 1 inch (all sides set to 1 inch)
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: a 24 pt baseline pitch at 12 pt (measured on the ca9 template, see README.md)
#let single-leading = 0.5em             // single spacing for caption, counsel, signature: about 13.8 pt at 12 pt
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.1in               // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iand-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Round a block up to whole double-spaced lines, so the text after it stays on the pitch of body text.
/// A one-line block is otherwise shorter than the leading that follows it, and the lines collide.
#let on-grid(c, sticky: false) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: sticky, c)
}

/// Heading text: body size (typst's default heading size is larger), double-spaced if it wraps, so each line sits on the pitch.
#let heading-style(c) = {
  set text(size: type-size)
  par(leading: body-leading, first-line-indent: 0pt, c)
}

/// Single-spaced lines: one item per line, the same spacing as the caption.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Court title: three centered lines (LR 10(d): district and division).
#let court-title(meta) = {
  let lines = (
    "IN THE UNITED STATES DISTRICT COURT",
    "FOR THE NORTHERN DISTRICT OF IOWA",
  )
  if "division" in meta { lines.push(upper(meta.division)) }
  set par(leading: single-leading)
  stack(dir: ttb, spacing: single-leading, ..lines.map(l => align(center, text(weight: "bold", l))))
}

/// Caption: the parties on the left, closed by a column of ")" marks (one per line); the case number
/// and the designation of the paper on the right (LR 10(d); Fed. R. Civ. P. 10(a)).
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  grid(
    columns: (caption-left, 0.3in, 1fr),
    line-stack(rows),
    line-stack(rows.map(_ => ")")),
    block(inset: (left: 0.15in), {
      line-stack(("No. " + meta.case_number,))
      if "judge" in meta {
        v(single-leading)
        line-stack(("Judge: " + meta.judge,))
      }
      v(pitch)
      text(weight: "bold", line-stack(((meta.brief_title),)))
      if "jury_demand" in meta and meta.jury_demand {
        v(single-leading)
        text(weight: "bold", line-stack(("JURY DEMAND",)))
      }
    }),
  )
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// The signature block (after the body; a "SIGNATURE" chunk in the markdown places it).
#let signature-block(meta) = block(breakable: false, width: text-width, {
  v(body-leading)
  if "date" in meta {
    block(width: text-width, above: 0pt, below: 0pt, "Dated: " + meta.date)
    v(body-leading)
  }
  pad(left: 3.0in, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(body-leading * 0.5)
    if "party" in meta.signature { line-stack(meta.signature.party) ; v(body-leading * 0.5) }
    line-stack(meta.signature.firm)
    v(body-leading * 0.5)
    line-stack(("By: /s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines)
  })
  v(body-leading)
})

/// Body chunks (blank-line separated markdown): a heading, a list, the SIGNATURE marker, or a paragraph.
/// Paragraphs are numbered when the sample says so (complaints; Fed. R. Civ. P. 10(b)); a paragraph that
/// starts with "UNNUMBERED:" is not (the prayer's WHEREFORE and the jury demand). Numbering is
/// applied per chunk, not with a show rule: a show rule that re-wraps paragraph content recurses in typst 0.15.
#let body(meta, src) = {
  let para-counter = counter("paragraph")
  let numbered = meta.at("numbered", default: false)
  let chunks = src.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    let unnumbered = t.starts-with("UNNUMBERED:")
    if unnumbered { t = t.slice("UNNUMBERED:".len()).trim() }
    if t == "SIGNATURE" {
      signature-block(meta)
    } else if t.starts-with("#") {
      inl(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Prayer items are lettered (A., B., ...). A list may break across pages.
      set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set par(leading: body-leading, first-line-indent: 0pt)
      v(body-leading * 0.5)
      inl(t)
      v(body-leading * 0.5)
    } else if numbered and not unnumbered {
      para-counter.step()
      on-grid({
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        context para-counter.display()
        [.#h(0.3in)]
        inl(t)
      })
    } else {
      on-grid({
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        inl(t)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let iand-complaint(meta, src) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 centered caps; level 2 centered bold; level 3 bold, flush left. Each is kept with what follows.
  show heading.where(level: 1): it => on-grid(sticky: true, heading-style({
    align(center, text(weight: "bold", upper(it.body)))
  }))
  show heading.where(level: 2): it => on-grid(sticky: true, heading-style({
    align(center, text(weight: "bold", it.body))
  }))
  show heading.where(level: 3): it => on-grid(sticky: true, heading-style({
    text(weight: "bold", it.body)
  }))

  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading, first-line-indent: 0pt)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  body(meta, src)
}
