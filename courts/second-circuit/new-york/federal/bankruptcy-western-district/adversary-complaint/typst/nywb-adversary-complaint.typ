// Adversary complaint for the United States Bankruptcy Court, Western District of New York (nywb).
// Rules: Fed. R. Bankr. P. 7001 (proceedings brought as adversary proceedings), 7008(a) (statement of jurisdiction,
// the pleader's consent to final orders), 7010 (caption: Civil Rule 10 applies, the caption substantially conforms
// to Form 416), 9004(b) (caption contents); Civil Rule 10(b) (numbered paragraphs, applies through Rule 7010);
// W.D.N.Y. LBR 9004-1 (letter-size paper), 9004-2 (caption with the judge's initial; date, signature, name, address
// and telephone). See ../README.md for the source, date and gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no W.D.N.Y. font rule (LBR 9004-1: "plainly and legibly written"); Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // convention: 12 point, as the filed exemplar
#let page-w = 8.5in                     // LBR 9004-1: letter size paper
#let page-h = 11in
#let margin = 1in                       // convention: one-inch margins on every side (no W.D.N.Y. margin rule)
#let body-leading = 1.645em             // convention: double spacing; Liberation Serif line box 0.655em + 1.645em = 2.3em = 27.6 pt at 12 pt, the exemplar's pitch
#let single-leading = 0.5em             // single spacing for the caption, counsel and signature blocks
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let number-gap = 0.25in                // gap between the paragraph number and its text
#let caption-left = 3.4in               // width of the party column of the caption
#let block-gap = 1.645em                // space between a heading and the text it introduces (one double-spaced line)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nywb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item: each item is a block, and the stack keeps the single spacing.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption (debtor, then adversary parties), title of the pleading
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  for line in meta.court_name {
    align(center, text(weight: "bold", upper(line)))
    linebreak()
  }
  v(single-leading * 2)
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    // The main case: the debtor, then the adversary parties; "v." between the parties.
    let rows = ()
    if "debtor" in meta and meta.debtor != none {
      rows += ("In re:", "") + meta.debtor.names + (meta.debtor.designation, "")
    }
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("") ; rows.push("vs.") ; rows.push("") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("Case No. " + meta.case_number,) + if "chapter" in meta { (meta.chapter,) } else { () }
      + if "judge" in meta { ("Hon. " + meta.judge,) } else { () })
    v(single-leading * 2)
    line-stack(("Adv. Pro. No. " + if "adv_number" in meta and meta.adv_number != none { meta.adv_number } else { "__________" },))
    v(single-leading * 2)
    text(weight: "bold", inl(meta.brief_title))
  }),
)

#let counsel-block(meta) = {
  v(single-leading * 3)
  align(left, pad(left: caption-left + 0.25in, line-stack(meta.counsel)))
}

#let cover(meta, pagebreak: true) = {
  court-title(meta)
  caption(meta)
  if "counsel" in meta and meta.counsel != none { counsel-block(meta) }
  if pagebreak { pagebreak() }
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Civil Rule 10(b), through Rule 7010), unnumbered headings and lists
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  v(body-leading)
  block(breakable: false, grid(
    columns: (3.0in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      line-stack(meta.signature.firm)
      v(single-leading * 2)
      line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  ))
}

/// Each blank-line-separated chunk of markdown is a heading, a list, or a numbered paragraph. The numbering is
/// applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content recurses without
/// end in typst 0.15 (the same finding as cand-complaint).
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Prayer items (markdown list) are lettered A., B., ... ; a list may break across pages.
      block(width: 100%, below: body-leading, {
        set par(leading: body-leading)
        set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else if t.starts-with(">") {
      // A block quotation: indented on both sides, single-spaced, not numbered (as in the filed complaint).
      block(width: 100%, below: body-leading, pad(left: 0.5in, right: 0.5in, {
        set par(leading: single-leading, first-line-indent: 0pt, justify: false)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      }))
    } else if t.starts-with("WHEREFORE") {
      // The prayer lead-in is not a numbered allegation (the filed complaint leaves it unnumbered).
      block(width: 100%, below: body-leading, sticky: true, {
        set par(leading: body-leading, first-line-indent: 0pt, justify: false)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      para-counter.step()
      block(width: 100%, below: body-leading, {
        set par(leading: body-leading, first-line-indent: 0pt, justify: false)
        context [#h(para-indent)#(para-counter.display()).#h(number-gap)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      })
    }
  }
}

#let nywb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    numbering: none,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: level 1 centered bold caps; level 2 centered bold; level 3 bold italic at the left margin.
  // Each heading is kept with the text after it.
  show heading.where(level: 1): it => block(width: 100%, above: block-gap, below: block-gap, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: block-gap, below: block-gap, sticky: true,
    align(center, par(spacing: 0pt, text(weight: "bold", it.body))))
  show heading.where(level: 3): it => block(width: 100%, above: block-gap, below: block-gap, sticky: true,
    par(hanging-indent: 0.5in, first-line-indent: 0pt, spacing: 0pt, text(weight: "bold", style: "italic", it.body)))

  // Page numbers: centered at the foot of each page from page 1 (the cover is page 1; the exemplar numbers it too).
  set page(numbering: "1", footer: context align(center, text(size: 10pt, counter(page).display())))

  cover(meta, pagebreak: false)

  if "lead_in" in meta and meta.lead_in != none {
    block(width: 100%, above: body-leading, below: body-leading, {
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(body, para-counter)

  signature-block(meta)
}
