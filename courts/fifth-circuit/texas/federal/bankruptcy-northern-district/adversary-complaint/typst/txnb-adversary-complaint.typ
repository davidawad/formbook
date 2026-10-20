// Adversary complaint for the U.S. Bankruptcy Court, N.D. Texas (txnb).
// Rules: Fed. R. Bankr. P. 7001 (adversary proceeding), 7010 (Fed. R. Civ. P. 10 applies; caption per Official
// Form 416), 9004(a)-(b) (legible, caption contents); L.B.R. 7001-1 (division), L.B.R. 7003-1 (cover sheet is a
// separate filing); Fed. R. Civ. P. 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no font rule in the N.D. Tex. bankruptcy rules for complaints; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // convention; the mailing-matrix size rule (10 to 14 pt) is not a complaint rule
#let page-w = 8.5in                     // FRBP 9004(a): legible paper; 8 1/2 by 11 inch is the practice (Form 416 is letter size)
#let page-h = 11in
#let margin = 1in                       // convention
#let body-leading = 1.345em             // double spacing: about 24 pt pitch at 12 pt (convention, see README.md)
#let single-leading = 0.495em            // single spacing for counsel, caption and signature
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.25in              // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: counsel (top left), court title, caption (Form 416 style), title of the paper
// ---------------------------------------------------------------------------

#let counsel-block(meta) = line-stack(meta.counsel)

#let court-title(meta) = {
  align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT"))
  align(center, text(weight: "bold", "NORTHERN DISTRICT OF TEXAS"))
  if "division" in meta and meta.division != none {
    align(center, text(weight: "bold", upper(meta.division)))
  }
}

/// Form 416 caption: the debtor and the adversary parties on the left, the case and adversary numbers on
/// the right. "v." separates the adversary parties.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    let rows = ()
    if "debtor" in meta.caption and meta.caption.debtor != none {
      rows += ("In re: " + meta.caption.debtor, "", "Debtor.", "")
    }
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation + ".",)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    line-stack((
      "Chapter " + str(meta.chapter),
      "",
      "Case No. " + meta.case_number,
      "",
      "Adversary Proceeding No. " + meta.adversary_number,
    ))
  }),
)

#let cover(meta) = {
  counsel-block(meta)
  v(24pt)
  court-title(meta)
  v(24pt)
  caption(meta)
  v(24pt)
  align(center, text(weight: "bold", inl(meta.title)))
  v(24pt)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, {
  [Dated: #meta.date]
  v(12pt)
  grid(
    columns: (3in, 1fr),
    [],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(12pt)
      line-stack(meta.signature.firm)
      v(12pt)
      line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  )
})

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither
/// a heading nor a list is one numbered paragraph. A paragraph whose text starts with "<!-- unnumbered -->" is not
/// numbered (prayer, jury demand, or closing). Headings are kept with the paragraph after them.
/// Numbering is per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content recurses
/// without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading: its own block (sticky, with spacing from the show rules above).
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists are lettered (a), (b), ... by the enum setting in the template.
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with("<!-- unnumbered -->") {
      h(para-indent)
      cmarker.render(t.slice("<!-- unnumbered -->".len()).trim(), raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      // Numbered paragraph (Fed. R. Civ. P. 10(b)): the number is the first thing on the line.
      para-counter.step()
      h(para-indent)
      context para-counter.display()
      [. #h(0.1in)]
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    }
    parbreak()
  }
}

#let txnb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: 10pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => {
    v(24pt, weak: true)
    block(sticky: true, width: 100%, align(center, text(weight: "bold", it.body)))
    v(12pt, weak: true)
  }
  show heading.where(level: 2): it => {
    v(12pt, weak: true)
    block(sticky: true, text(weight: "bold", it.body))
    v(12pt, weak: true)
  }
  show heading.where(level: 3): it => {
    v(12pt, weak: true)
    block(sticky: true, text(weight: "bold", style: "italic", it.body))
    v(12pt, weak: true)
  }

  cover(meta)

  // Body: numbered paragraphs; markdown lists become (a), (b), ...
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
}
