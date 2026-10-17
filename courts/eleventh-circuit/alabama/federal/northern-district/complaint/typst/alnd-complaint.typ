// Complaint for the U.S. District Court for the Northern District of Alabama (alnd).
// Rules: Fed. R. Civ. P. 8(a), 10(a)-(c) (caption, numbered paragraphs, one set of circumstances per
// paragraph), 11(a) (signature); Local Rule 23.1 (class-action legend, when the case is one). The local rules
// of the court (rev. Dec. 4, 2019) set no typeface, margin or spacing rule for pleadings; the layout below
// follows the filed exemplar where the rules leave it open. See ../README.md for every requirement and its
// status. Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a stated layout choice in ../README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // no ALND typeface rule; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // 12 pt, the exemplar's size (no ALND rule sets one; Liberation Serif has Times metrics, docs/FONTS.md)
#let pitch = 24pt                       // double spacing, the convention of the exemplar (no ALND rule states it)
#let body-leading = 1.345em             // gap between body lines: Liberation Serif sets a 0.655 em line box, so this gives a 24 pt baseline pitch at 12 pt
#let single-leading = 0.495em            // captions, signature blocks, headings: a 1.15 em (13.8 pt) pitch at 12 pt
#let page-w = 8.5in
#let margins = (top: 1in, bottom: 1in, x: 1in)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs; the number sits at this indent
#let number-gap = 0.45in                // number to text, as in the exemplar
#let caption-left = 3.2in               // width of the party column of the caption
#let page-number-size = type-size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let text-width = page-w - margins.x * 2

/// Rounds a block up to whole lines of `pitch`: typst leaves out the leading after a paragraph's last line,
/// so without this the next block would start one line too high and overprint.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// One paragraph as a breakable block. typst leaves out the leading after a paragraph's last line, so the
/// trailing v() makes n lines take exactly n pitches, and the block can still break across pages (a fixed
/// height block could not, and its continuation would overprint).
#let para-block(c) = block(width: text-width, above: 0pt, below: 0pt, {
  c
  v(body-leading)
})

/// Inline markdown (case names in italics, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (the first page carries the start of the text)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  align(center, strong({
    for l in meta.court {
      inl(l)
      linebreak()
    }
  }))
}

#let caption(meta) = table(
  columns: (caption-left, 1fr),
  inset: 0pt,
  stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
  pad(right: 1.2em, bottom: 1em, {
    // Each party: its names, then its designation set in from the names; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push(align(center, [v.])) }
      for n in p.names { rows.push(inl(n)) }
      rows.push(pad(left: 1.8in, inl(p.designation)))
    }
    set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    stack(dir: ttb, spacing: single-leading, ..rows)
  }),
  pad(left: 1.2em, top: 0.3em, {
    set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    [Case No.: #meta.case_number]
  }),
)

// ---------------------------------------------------------------------------
// Headings (level 1: centered bold capitals; level 2 and 3: centered bold)
// ---------------------------------------------------------------------------

#let heading-block(c) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, on-grid(c))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b))
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one unit:
///   - a heading (`#`, `##`, `###`) is set by its show rule;
///   - a list (`1.`, `-`) is lettered A., B., ... (prayer for relief);
///   - a chunk starting with `{unnumbered}` is an unnumbered paragraph with a first-line indent (the prayer lead-in);
///   - a chunk starting with `{centered}` is an unnumbered centered line (the "(Against All Defendants)" legend);
///   - any other chunk is one numbered paragraph.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      heading-block(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Items are spaced by body-leading; a list may break across pages.
      {
        set par(leading: body-leading)
        set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else if t.starts-with("{unnumbered}") {
      let rest = t.slice("{unnumbered}".len()).trim()
      para-block({
        set par(leading: body-leading, first-line-indent: para-indent)
        cmarker.render(rest, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else if t.starts-with("{centered}") {
      let rest = t.slice("{centered}".len()).trim()
      para-block({
        set par(leading: body-leading, first-line-indent: 0pt)
        align(center, cmarker.render(rest, raw-typst: false, smart-punctuation: true, h1-level: 1))
      })
    } else {
      // One block per paragraph, so the number and the text share the paragraph's first line.
      para-counter.step()
      para-block(context {
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        para-counter.display()
        h(number-gap)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Date and signature (Fed. R. Civ. P. 11(a): signed by at least one attorney of record)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = meta.signature
  block(breakable: false, above: pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [#meta.date_line]
    v(pitch)
    grid(
      columns: (1fr,) * sig.firms.len(),
      column-gutter: 0.3in,
      ..sig.firms.map(lines => {
        set par(leading: single-leading, first-line-indent: 0pt, justify: false)
        for l in lines {
          if l == "" { v(single-leading * 4) } else { inl(l); linebreak() }
        }
      }),
    )
    v(pitch)
    for l in sig.lines { inl(l); linebreak() }
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let alnd-complaint(meta, body) = {
  for k in ("court", "caption", "brief_title", "case_number", "signature", "date_line") {
    if k not in meta { panic("alnd-complaint: missing required metadata field `" + k + "`") }
  }
  let para-counter = counter("allegation")

  set document(title: meta.brief_title)
  set page(
    paper: "us-letter",
    margin: margins,
    footer: context align(center, text(size: page-number-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false)
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  show heading: set text(size: type-size)
  show heading.where(level: 1): it => heading-block(align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => heading-block(align(center, strong(it.body)))
  show heading.where(level: 3): it => heading-block(align(center, strong(it.body)))

  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
  heading-block(align(center, strong(upper(inl(meta.brief_title)))))

  if "lead_in" in meta {
    para-block({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(body, para-counter)
  signature-block(meta)
}
