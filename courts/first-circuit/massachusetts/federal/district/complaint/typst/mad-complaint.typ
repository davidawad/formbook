// U.S. District Court, District of Massachusetts: complaint (Fed. R. Civ. P. 8 and 10; D. Mass. L.R. 3.1, 5.1).
// Requirement IDs (MAD-...) and the rule text are in ../README.md. Content-agnostic: every case-specific
// word comes from the sample's frontmatter or markdown body, never from this file. The markdown body is
// rendered by cmarker. No forced line breaks, no coordinates measured off the exemplar.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"     // MAD-FORM-002: L.R. 5.1 sets no typeface; EB Garamond is the serif vendored in fonts/
#let type-size = 13pt                // style choice: 13 pt EB Garamond is about the apparent size of 12 pt Times (README)
#let body-leading = 1.2em            // MAD-FORM-001: double spacing, 24 pt between baselines at 13 pt (EB Garamond line box 0.65 em + 1.2 em) (L.R. 5.1(a)(2))
#let single-leading = 0.45em         // single spacing: caption, quotations, signature block (exempt under L.R. 5.1(a)(2))
#let para-gap = 0.65em              // gap between paragraphs (a zero gap makes typst 0.15 stack paragraphs on top of each other)
#let page-margin = 1in               // style choice (the rules set paper size only, L.R. 5.1(a)(2))
#let para-indent = 0.5in             // first-line indent of numbered paragraphs (exemplar: number at 0.5 in)
#let number-gap = 0.3in              // gap between a paragraph number and its text
#let caption-left = 3.25in           // width of the party column of the caption
#let sig-indent = 3.0in              // left edge of the signature block
#let footer-size = 12pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mad-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, *et seq*, smart quotes) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A stack of single-spaced lines (counsel, party names, signature lines).
#let lines(items) = stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))

// ---------------------------------------------------------------------------
// Caption (MAD-CAP-001..003: court name, title, civil action number)
// ---------------------------------------------------------------------------

#let court-title() = align(center, stack(dir: ttb, spacing: single-leading,
  text(weight: "bold", "UNITED STATES DISTRICT COURT"),
  text(weight: "bold", "FOR THE DISTRICT OF MASSACHUSETTS"),
))

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    // Each party: its names, then its designation, indented; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 {
        rows.push(block(height: 0.6em))
        rows.push(pad(left: 0.5in, inl("v.")))
        rows.push(block(height: 0.6em))
      }
      for n in p.names { rows.push(inl(n)) }
      rows.push(block(height: 0.6em))
      rows.push(pad(left: 1.25in, inl(p.designation)))
    }
    stack(dir: ttb, spacing: single-leading, ..rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: para-gap, justify: false)
    [Civil Action No. #meta.case_number]
    v(body-leading)
    text(weight: "bold", inl(meta.title))
  }),
)

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs (Fed. R. Civ. P. 10(b)), quotations, prayer
// ---------------------------------------------------------------------------

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is a paragraph is one numbered
/// paragraph. Headings, quotations (a `>` chunk), lists (the prayer, lettered A., B., ...) and any chunk
/// beginning WHEREFORE are not numbered. A heading is kept in one unbreakable block with the chunk after
/// it, so a heading never ends a page.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Items are spaced by body-leading. A list may break across pages; only a heading in front of it
      // is kept with its first line.
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
    } else if t.starts-with(">") {
      // A quotation: unnumbered, single-spaced and indented (L.R. 5.1(a)(2) exempts quotations).
      let q = cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      if has-pending {
        block(breakable: false, width: 100%, { pending; q })
      } else {
        q
      }
      pending = []
      has-pending = false
    } else if t.starts-with("WHEREFORE") {
      // The prayer lead-in: an unnumbered paragraph, indented like a numbered one.
      let piece = block(width: 100%, {
        set par(leading: body-leading)
        h(para-indent)
        inl(t)
      })
      if has-pending {
        block(breakable: false, width: 100%, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    } else {
      // A numbered paragraph; only a heading in front of it is kept with its first line.
      let piece = block(width: 100%, {
        para-counter.step()
        set par(leading: body-leading)
        context [#h(para-indent)#(para-counter.display())#h(number-gap)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      })
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

/// The signature block (MAD-SIG-001: the board of bar overseers number under each attorney's name, L.R. 5.1(a)(1)).
#let signature(meta) = {
  let sig = meta.signature
  block(breakable: false, width: 100%, {
    set par(leading: single-leading, spacing: para-gap, justify: false)
    v(body-leading)
    pad(left: sig-indent, stack(dir: ttb, spacing: body-leading,
      lines(sig.party),
      stack(dir: ttb, spacing: body-leading,
        inl("/s/ " + sig.signer),
        stack(dir: ttb, spacing: body-leading, ..sig.attorneys.map(a => lines((
          a.name + " (BBO# " + a.bbo + ")",
          a.email,
        )))),
        lines(sig.firm),
      ),
    ))
    v(body-leading)
    [Dated: #meta.date]
  })
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let mad-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: para-gap, first-line-indent: 0pt, justify: true)

  // Headings: level 1 centered bold capitals; level 2 centered bold; level 3 bold, left, hanging.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.9em, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 0.9em, below: 0.9em, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: 0.9em, below: 0.9em, sticky: true,
    par(hanging-indent: 0.5in, text(weight: "bold", it.body)))

  // Quotations: single-spaced, indented 0.5 in on both sides.
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, top: 0.3em, bottom: body-leading,
    {
      set par(leading: single-leading, justify: true)
      it.body
    })

  // Lists (the prayer): lettered A., B., ...
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  court-title()
  v(body-leading * 2)
  caption(meta)
  v(body-leading * 2)

  if "lead_in" in meta {
    block(width: 100%, {
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(body, para-counter)

  if "jury_demand" in meta {
    block(breakable: false, width: 100%, {
      set par(leading: body-leading)
      h(para-indent)
      text(weight: "bold", inl(meta.jury_demand))
    })
  }

  signature(meta)
}
