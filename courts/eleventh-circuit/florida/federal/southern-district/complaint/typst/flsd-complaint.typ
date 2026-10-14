// Complaint for the U.S. District Court for the Southern District of Florida (flsd).
// Rules: S.D. Fla. L.R. 5.1(a) (paper, margins, spacing, type size, pagination, caption, signature block);
// L.R. 3.3 (civil cover sheet is a separate filing, not generated here); Fed. R. Civ. P. 8(a), 10(a), 10(b)
// (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no font rule in L.R. 5.1; the only vendored face (fonts/), see README.md
#let type-size = 12pt                   // L.R. 5.1(a)(4): fonts no smaller than 12 point
#let page-w = 8.5in                     // L.R. 5.1(a)(3): standard 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // L.R. 5.1(a)(4): 1 inch on top, bottom and each side
#let body-leading = 1.65em              // L.R. 5.1(a)(4): at least 1 1/2 spaces; the exemplar is double-spaced (27.6 pt pitch at 12 pt), see README.md
#let single-leading = 0.5em             // quotations of 50 words or more, footnotes, signature and caption blocks
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let style-width = 3.25in               // L.R. 5.1(a)(5)(C): the style fills no more than the left side of the page

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flsd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, italics, links).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A block of single-spaced lines (caption style, counsel and signature blocks), one item per line.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Paginated consecutively at the bottom center of each page (L.R. 5.1(a)(4)).
#let footer-page-number() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Caption: court (L.R. 5.1(a)(5)(A)), docket line (B), style on the left (C), title (D)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, stack(dir: ttb, spacing: single-leading,
    text(weight: "bold", "UNITED STATES DISTRICT COURT"),
    text(weight: "bold", "SOUTHERN DISTRICT OF FLORIDA"),
    ..if "division" in meta { (text(weight: "bold", upper(meta.division)),) } else { () },
  ))
}

#let style-block(meta) = block(width: style-width, {
  // Each party: its names, then its designation; "v." between the parties; the "/" closes the style.
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  rows.push("/")
  line-stack(rows)
})

#let caption(meta) = {
  court-title(meta)
  v(body-leading * 2)
  // Docket line centered across the page (L.R. 5.1(a)(5)(B)): category, number, assigned judges.
  align(center, text("CIVIL CASE NO. " + meta.case_number))
  v(body-leading * 2)
  style-block(meta)
  v(body-leading * 2)
  align(center, text(weight: "bold", upper(meta.title)))
  v(body-leading * 2)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)); headings; unnumbered prayer paragraphs
// ---------------------------------------------------------------------------

#let para-counter = counter("allegation")

/// Each blank-line-separated chunk of markdown is one unit: a heading, a list, a numbered paragraph, or an
/// unnumbered paragraph. Unnumbered: a paragraph that starts with WHEREFORE (the prayer for relief) and the
/// paragraph under the DEMAND FOR JURY TRIAL heading. Numbering is applied per chunk, not with a `show par`
/// rule (a show rule that re-wraps paragraph content recurses without end in typst 0.15).
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let unnumbered = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      unnumbered = t.replace("#", "").trim() == "DEMAND FOR JURY TRIAL"
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: 100%, {
        set par(leading: body-leading, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else if unnumbered or t.starts-with("WHEREFORE") {
      par(leading: body-leading, first-line-indent: (amount: para-indent, all: true), inl(t))
    } else {
      para-counter.step()
      par(leading: body-leading, first-line-indent: (amount: para-indent, all: true),
        context [#(para-counter.display()).#h(0.3in)#inl(t)])
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block and the rest of the first page
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: 100%, breakable: false, {
  [Dated: #meta.date]
  v(body-leading)
  pad(left: style-width + 0.25in, {
    [Respectfully submitted,]
    v(body-leading)
    // L.R. 5.1(a)(6): name, street address, telephone, e-mail and bar number of each counsel.
    line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
  })
})

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let flsd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-page-number(),
    footer-descent: 0.3in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)

  // Headings: level 1 centered bold capitals; level 2 centered bold; level 3 bold, left.
  // A heading is sticky: it never ends a page.
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    text(weight: "bold", it.body))

  caption(meta)

  // The lead-in (the paragraph before the first heading) is unnumbered.
  if "lead_in" in meta {
    par(leading: body-leading, first-line-indent: (amount: para-indent, all: true), inl(meta.lead_in))
  }

  body-chunks(body)

  v(body-leading)
  signature-block(meta)
}
