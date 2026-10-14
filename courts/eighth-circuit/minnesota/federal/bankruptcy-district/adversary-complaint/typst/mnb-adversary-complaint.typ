// Adversary complaint for the U.S. Bankruptcy Court, District of Minnesota (mnb).
// Rules: Fed. R. Bankr. P. 7001 (adversary proceeding), 7008 (core or non-core statement), 7010 (caption,
// Form 416A), 9004(a) (legibility), 9011 (signature block); D. Minn. LBR 9004-1(a) (letter-size paper),
// 9004-1(b)(2) (print to PDF). Fed. R. Civ. P. 10(b) applies through 7010 (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no font rule in the local rules; EB Garamond is the vendored serif (README.md)
#let type-size = 12pt                   // no size rule in the local rules; 12 pt is the convention in both exemplars
#let page-w = 8.5in                     // LBR 9004-1(a): letter-size paper
#let page-h = 11in
#let margin = 1in                       // convention in both exemplars; no local rule sets margins
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: 24 pt baseline pitch at 12 pt, as in the exemplars
#let single-leading = 0.5em             // single spacing for the caption, the signature block and lists of names
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let pitch-gap = 24pt                   // one double-spaced line between blocks
#let caption-left = 3.5in               // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item. An empty string is a blank line; a line starting with ">" is indented
/// (the party designations "Plaintiff," and "Debtors.").
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if i == "" {
    v(single-leading)
  } else if i.starts-with(">") {
    pad(left: 1.8in, inl(i.slice(1).trim()))
  } else {
    inl(i)
  }))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number centred in the bottom margin.
#let footer-page-number() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Caption: court, debtor box, adversary box (Fed. R. Bankr. P. 7010; Official Form 416A)
// ---------------------------------------------------------------------------

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, text(weight: "bold", [UNITED STATES BANKRUPTCY COURT])) + linebreak()
  align(center, text(weight: "bold", [DISTRICT OF MINNESOTA]))
}

#let caption(meta) = {
  court-title()
  v(pitch-gap)
  // Debtor box: "In re:" and the debtor names on the left; the case numbers on the right.
  block(width: text-width, stroke: (top: 0.75pt, bottom: 0.75pt), inset: (top: 8pt, bottom: 8pt),
    grid(
      columns: (caption-left, 1fr),
      column-gutter: 0.2in,
      block(width: caption-left, inset: (right: 0.1in), line-stack(meta.caption.debtor)),
      block(inset: (left: 0.1in), line-stack(meta.caption.debtor_case)),
    ))
  // Adversary box: the plaintiff and defendant on the left; the adversary number and the title on the right.
  block(width: text-width, inset: (top: 8pt, bottom: 8pt), stroke: (bottom: 0.75pt),
    grid(
      columns: (caption-left, 1fr),
      column-gutter: 0.2in,
      block(width: caption-left, inset: (right: 0.1in), line-stack(meta.caption.parties)),
      block(inset: (left: 0.1in), {
        set par(leading: single-leading, spacing: 0pt)
        line-stack(meta.caption.adversary)
        v(pitch-gap)
        text(weight: "bold", inl(meta.title))
        if "jury_demand" in meta and meta.jury_demand {
          v(single-leading)
          text(weight: "bold", "DEMAND FOR JURY TRIAL")
        }
      }),
    ))
  v(pitch-gap)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  v(pitch-gap)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt)
      line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  )
}

/// Numbered paragraphs (Fed. R. Civ. P. 10(b), through Fed. R. Bankr. P. 7010). Each blank-line-separated chunk
/// of markdown that is neither a heading nor a list is one numbered paragraph; a WHEREFORE paragraph is not
/// numbered. A chunk starting with a heading is kept with the chunk after it. Markdown lists are lettered
/// (A., B., ...) and unnumbered. `tail` (the signature block) is kept with the last chunk, so it never
/// stands alone on a page.
#let allegations(body, tail: none) = {
  let n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let last = chunks.len() - 1
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    // The last chunk carries the tail; a block that cannot break keeps them together.
    let emit(x) = if i == last and tail != none {
      block(breakable: false, width: text-width, { x; tail })
    } else {
      x
    }
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      let items = {
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if pending != [] {
        emit(block(breakable: false, width: text-width, { pending; items }))
      } else {
        emit(items)
      }
      pending = []
    } else {
      let numbered = not t.starts-with("WHEREFORE")
      // Each paragraph is a block: cmarker returns block-level paragraphs, which cannot sit inside a line.
      let piece = block(width: text-width, {
        if numbered {
          n += 1
          [#h(para-indent)#(str(n) + ".")#h(0.4in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        } else {
          [#h(para-indent)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        }
      })
      if pending != [] {
        emit(block(breakable: false, width: text-width, { pending; piece }))
      } else {
        emit(piece)
      }
      pending = []
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let mnb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-page-number(),
    footer-descent: 0pt,
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Paragraph spacing equals the leading: a line is 24 pt from the next, and so is a paragraph.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  // Bulleted lists carry their own letters (A., B., ...) as text, so the bullet is dropped.
  set list(marker: [], indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centred caps section; level 2 a centred bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => block(width: text-width, above: 12pt, below: 12pt, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: 12pt, below: 12pt, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, above: 12pt, below: 12pt, sticky: true,
    text(weight: "bold", style: "italic", it.body))

  caption(meta)

  // The unnumbered lead-in (the paragraph that says who files and on what basis) comes before paragraph 1.
  if "lead_in" in meta {
    block(width: text-width, [#h(para-indent)#cmarker.render(meta.lead_in, raw-typst: false, smart-punctuation: true, h1-level: 1)])
  }

  allegations(body, tail: signature-block(meta))
}
