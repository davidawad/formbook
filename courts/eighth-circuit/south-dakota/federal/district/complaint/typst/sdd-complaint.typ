// Complaint for the U.S. District Court for the District of South Dakota (sdd).
// Rules: D.S.D. Civ. LR 83.4 (form of papers: 8 1/2 x 11 inch, double-spaced text, headings single-spaced,
// margins at least one inch on all four sides, type at least 12 point), LR 10.1 (caption; signature block),
// LR 5.1(A)(4) ("/s/" before a filing user's typed name); Fed. R. Civ. P. 8(a), 10(a), 10(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/ (the only font the build can use)
#let type-size = 12pt                   // LR 83.4: type must be at least 12 point
#let pitch = 24pt                       // LR 83.4: double-spaced text; the baseline pitch at 12 pt
#let page-w = 8.5in                     // LR 83.4: 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LR 83.4: at least one inch on all four sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // EB Garamond's line box is 0.65em, so 1.35em leading gives a 24 pt pitch at 12 pt
#let single-leading = 0.5em             // single spacing (headings, caption, signature, tables): about 13.8 pt
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.25in              // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("sdd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A heading: kept with the paragraph after it, so a heading never ends a page (LR 83.4: single-spaced).
#let heading-block(c) = block(width: text-width, above: 12pt, below: 12pt, sticky: true, c)

/// Lines stacked at single spacing; each item is its own block, so no forced line breaks are needed.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// The page number, centered in the bottom margin.
#let footer-block() = align(center, text(size: type-size, context counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court title, caption (parties on the left, case number and title on the right)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  stack(dir: ttb, spacing: single-leading,
    align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")),
    align(center, text(weight: "bold", "DISTRICT OF SOUTH DAKOTA")),
    if "division" in meta and meta.division != none {
      align(center, text(weight: "bold", upper(meta.division)))
    },
  )
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 12pt, bottom: 10pt), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.15in), {
    line-stack(("Case No. " + meta.case_number,))
    v(pitch * 0.5)
    text(weight: "bold", inl(meta.brief_title))
    if "jury_demand" in meta and meta.jury_demand {
      v(pitch * 0.5)
      text(weight: "bold", "JURY TRIAL DEMANDED")
    }
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block (LR 10.1(B)): the signature, then the typed name, address, telephone and e-mail beneath it.
/// A party without an attorney signs personally; a filing user's name is preceded by "/s/" (LR 5.1(A)(4)).
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: text-width, above: pitch, breakable: false, grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      if "pro_se" in sig and sig.pro_se {
        v(pitch)
        line(length: 3.2in, stroke: 0.5pt)
        v(4pt)
        line-stack((sig.signer, "Plaintiff, without counsel") + sig.lines)
      } else {
        if "firm" in sig {
          line-stack(sig.firm)
          v(pitch * 0.5)
        }
        line-stack(("By: /s/ " + sig.signer, sig.signer) + sig.lines)
      }
    },
  ))
}

/// Body text. Each blank-line-separated chunk of markdown is one of:
///   - a heading (`#`, `##`, `###`): centered caps, bold, or bold italic; kept with the chunk after it;
///   - a table (`|`): set single-spaced, not numbered;
///   - a list (`1.`, `-`): lettered (a), (b), ... and not numbered;
///   - a paragraph: numbered 1, 2, ... (Fed. R. Civ. P. 10(b)), unless it starts with "~", which is
///     stripped and renders the paragraph unnumbered (used for the certification, which is not an allegation).
/// Numbers are a plain code-level count, not a counter: a counter read in `context` inside a block
/// measured wrongly in typst 0.15 and let neighbouring paragraphs overlap.
#let allegations(body, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  let pending = []
  let tail-used = false
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with("|") {
      pending
      pending = []
      set par(leading: single-leading, spacing: 0pt)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(pitch * 0.5)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pending
      pending = []
      set par(leading: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading)
    } else {
      let unnumbered = t.starts-with("~")
      let text-body = if unnumbered { t.slice(1).trim() } else { t }
      pending
      pending = []
      set par(leading: body-leading)
      let para = if unnumbered {
        [#h(para-indent)#cmarker.render(text-body, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      } else {
        n += 1
        [#h(para-indent)#str(n).#h(0.3in)#cmarker.render(text-body, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      }
      // The last paragraph stays on the page with the signature block: a signature alone on a page is not allowed.
      if i == chunks.len() - 1 {
        block(breakable: false, width: text-width, { para; tail })
        tail-used = true
      } else {
        para
      }
    }
  }
  pending
  if not tail-used { tail }
}
#let sdd-complaint(meta, body) = {

  set page(
    paper: "us-letter",
    margin: (top: margin + 4pt, bottom: margin, left: margin, right: margin),
    footer: footer-block(),
    footer-descent: 0pt,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set table(stroke: 0.5pt, inset: 5pt)
  show table: set text(size: type-size)

  // Headings: level 1 is a centered section in caps; level 2 a bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(text(weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", style: "italic", it.body))

  cover(meta)

  allegations(body, signature-block(meta))
}
