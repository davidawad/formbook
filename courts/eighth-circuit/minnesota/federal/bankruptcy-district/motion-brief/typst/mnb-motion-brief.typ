// Motion with memorandum for the U.S. Bankruptcy Court, District of Minnesota (mnb).
// Rules: Fed. R. Bankr. P. 9013 (form of motions), 9014 (contested matters), 9004(a) (legibility), 9004(b) (caption),
// 9011 (signature block); D. Minn. LBR 9013-1(a) (notice and motion substantially complying with Local Form 9013-1,
// concise memorandum of facts and law, verification if facts are at issue, proposed order, proof of service if
// required), 9004-1(a) (letter-size paper), 9004-1(b)(2) (print to PDF). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no font rule in the local rules; EB Garamond is the vendored serif (README.md)
#let type-size = 12pt                   // no size rule in the local rules; 12 pt is the convention in the exemplars
#let page-w = 8.5in                     // LBR 9004-1(a): letter-size paper
#let page-h = 11in
#let margin = 1in                       // convention in the exemplars; no local rule sets margins
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: 24 pt baseline pitch at 12 pt, as in the exemplars
#let single-leading = 0.5em             // single spacing for the caption, the signature block and lists of names
#let para-indent = 0.5in                // first-line indent of numbered paragraphs and of memorandum text
#let pitch-gap = 24pt                   // one double-spaced line between blocks
#let caption-left = 3.5in               // width of the party column of the caption
// The sample's body has two parts, split by this line: the notice and motion, then the memorandum of law.
#let part-split = "<!-- memorandum -->"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mnb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item. An empty string is a blank line; a line starting with ">" is indented
/// (the party designations "Debtor.").
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
// Caption: court, debtor box, and the title of the part (Fed. R. Bankr. P. 9004(b); 9013)
// ---------------------------------------------------------------------------

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, text(weight: "bold", [UNITED STATES BANKRUPTCY COURT])) + linebreak()
  align(center, text(weight: "bold", [DISTRICT OF MINNESOTA]))
}

#let caption(meta, title) = {
  court-title()
  v(pitch-gap)
  // Debtor box: "In re:" and the debtor names on the left; the case number and chapter on the right.
  block(width: text-width, stroke: (top: 0.75pt, bottom: 0.75pt), inset: (top: 8pt, bottom: 8pt),
    grid(
      columns: (caption-left, 1fr),
      column-gutter: 0.2in,
      block(width: caption-left, inset: (right: 0.1in), line-stack(meta.caption.debtor)),
      block(inset: (left: 0.1in), line-stack(meta.caption.debtor_case)),
    ))
  v(pitch-gap)
  align(center, text(weight: "bold", inl(title)))
  v(pitch-gap)
}

// ---------------------------------------------------------------------------
// Body, signature and verification
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  v(pitch-gap)
  block(breakable: false, grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt)
      if "firm" in meta.signature { line-stack(meta.signature.firm) + v(pitch-gap) }
      line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  ))
}

#let verification-block(meta) = if "verification" in meta {
  block(breakable: false, width: text-width, {
    align(center, text(weight: "bold", "VERIFICATION"))
    v(pitch-gap)
    set par(leading: body-leading)
    [#h(para-indent)#inl(meta.verification.text)]
    v(pitch-gap)
    grid(
      columns: (2.6in, 1fr),
      column-gutter: 0.2in,
      [#meta.verification.date],
      {
        set par(leading: single-leading, spacing: 0pt)
        line-stack(("/s/ " + meta.verification.signer,) + meta.verification.lines)
      },
    )
  })
}

/// Paragraphs of a part. Each blank-line-separated chunk of markdown is one paragraph: numbered (Fed. R. Bankr.
/// P. 9013; LBR 9013-1(a)(1)) in the notice, unnumbered in the memorandum. A chunk starting with a heading is kept
/// with the chunk after it; a WHEREFORE paragraph and a markdown list are never numbered. `tail` (the signature
/// block) is kept with the last chunk, so it never stands alone on a page.
#let paragraphs(body, numbered-paragraphs: true, tail: none) = {
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
    } else if t.starts-with(">") {
      // A block quotation (the text of a statute) is single-spaced and indented.
      let quote = block(width: text-width, inset: (left: 0.5in, right: 0.5in), {
        set par(leading: single-leading, spacing: 0.6em)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
      v(pitch-gap - single-leading)
      if pending != [] {
        emit(block(breakable: false, width: text-width, { pending; quote }))
      } else {
        emit(quote)
      }
      pending = []
    } else {
      let is-numbered = numbered-paragraphs and not t.starts-with("WHEREFORE")
      // Each paragraph is a block: cmarker returns block-level paragraphs, which cannot sit inside a line.
      let piece = block(width: text-width, {
        if is-numbered {
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

#let mnb-motion-brief(meta, body) = {
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
  // Bulleted lists carry their own letters, e.g. "(A)", as text, so the bullet is dropped.
  set list(marker: [], indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centred caps section; level 2 a centred bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => block(width: text-width, above: 12pt, below: 12pt, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: 12pt, below: 12pt, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, above: 12pt, below: 12pt, sticky: true,
    text(weight: "bold", style: "italic", it.body))

  let parts = body.split(part-split)
  let notice = parts.at(0)
  let memo = if parts.len() > 1 { parts.at(1) } else { none }

  // Part 1: the notice of hearing and motion, numbered paragraphs (LBR 9013-1(a)(1)), then the signature and,
  // if the facts are at issue, the verification (LBR 9013-1(a)(3)).
  caption(meta, meta.notice_title)

  if "lead_in" in meta {
    block(width: text-width, [#h(para-indent)#cmarker.render(meta.lead_in, raw-typst: false, smart-punctuation: true, h1-level: 1)])
  }

  if memo == none {
    paragraphs(notice, tail: signature-block(meta))
    verification-block(meta)
  } else {
    paragraphs(notice, tail: signature-block(meta))
    verification-block(meta)
    pagebreak()

    // Part 2: the memorandum of facts and law (LBR 9013-1(a)(2)); its paragraphs are unnumbered.
    caption(meta, meta.memo_title)
    paragraphs(memo, numbered-paragraphs: false, tail: signature-block(meta))
  }
}
