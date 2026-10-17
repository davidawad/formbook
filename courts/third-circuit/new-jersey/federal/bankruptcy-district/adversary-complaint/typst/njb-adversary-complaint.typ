// Adversary complaint for the United States Bankruptcy Court, District of New Jersey (njb).
// Rules: FRBP 7010 (form of an adversary pleading: FRCP 10, caption, numbered paragraphs); FRBP 9004(a), (b)
// (legible; caption with court, title, case and adversary number, document designation); D.N.J. LBR 9004-1(a), (b)
// (attorney block top left; chapter, judge initials and hearing date in the caption). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no face named by the rules; Times New Roman substitute per docs/FONTS.md "No face named"; see README.md, Known gaps
#let type-size = 14pt                   // convention: NJ filings in RECAP are 12 to 14 pt; see README.md
#let body-leading = 1.145em             // double-spaced feel at 14 pt, tuned against the exemplar (README.md): 0.655em line box + 1.145em = 25.2 pt
#let single-leading = 0.45em            // counsel, caption and signature blocks
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let page-margin = 1in                  // FRBP 9004: legible paper; the exemplar uses 1 inch on all sides
#let text-width = 8.5in - 2 * page-margin
#let caption-left = 3.25in              // width of the left (party) column of the caption
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF NEW JERSEY")
#let lbr-note = "Caption in Compliance with D.N.J. LBR 9004-1"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("njb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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
// Cover: counsel, court, caption, title of the paper
// ---------------------------------------------------------------------------

#let cover(meta) = {
  // LBR 9004-1(a): attorney of record and the party represented, top left of the first page.
  line-stack(meta.counsel)
  v(1.2em)
  align(center, text(weight: "bold", court-name.join("\n")))
  v(0.6em)
  align(right, text(size: 11pt, lbr-note))

  // Caption: the debtor block and case data, then the adversary block and the title.
  let hearing = if "hearing" in meta and meta.hearing != none { (meta.hearing,) } else { () }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
      line-stack(("In re:",) + meta.debtor + ("Debtor.",))
    }),
    block(inset: (left: 0.1in), line-stack(
      ("Case No.: " + meta.case_no,)
        + ("Chapter " + str(meta.chapter),)
        + ("Judge: " + meta.judge,)
        + hearing
    )),
  )
  v(0.8em)
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
      // Each party: its names, then its designation; "v." between the parties.
      let rows = ()
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 { rows.push("v.") }
        rows += p.names + (p.designation,)
      }
      line-stack(rows)
    }),
    block(inset: (left: 0.1in), line-stack(
      ("Adv. Pro. No. " + meta.adv_no,)
    )),
  )
  v(1.4em)
  align(center, text(weight: "bold", upper(meta.title)))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = grid(
  columns: (2.9in, 1fr),
  column-gutter: 0.2in,
  [Dated: #meta.date],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(0.6em)
    line-stack(meta.signature.firm)
    v(0.6em)
    line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines)
  },
)

/// Numbered paragraphs (FRCP 10(b), as applied by FRBP 7010). Each blank-line-separated chunk of markdown is
/// one of: a heading (kept with the chunk after it), a list (lettered by the template), a bracketed note
/// (unnumbered, centered), or a paragraph (numbered). Numbering is applied per chunk, not with a `show par`
/// rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // Prayer items: a list may break across pages.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else if t.starts-with("WHEREFORE") {
      // The prayer lead-in is an unnumbered paragraph (the exemplar does not number it).
      pending + {
        set par(leading: body-leading, spacing: 0.7em, first-line-indent: 0pt)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      }
      pending = []
      has-pending = false
    } else if t.starts-with("[") {
      // Bracketed note: an editorial marker, not a paragraph; unnumbered.
      let note = {
        set par(leading: body-leading)
        align(center, text(style: "italic", inl(t)))
        v(body-leading * 0.5)
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; note })
      } else {
        note
      }
      pending = []
      has-pending = false
    } else {
      let piece = {
        para-counter.step()
        set par(leading: body-leading, spacing: 0.7em, first-line-indent: 0pt)
        context [#h(para-indent)#(para-counter.display()).#h(0.25in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      }
      // A heading is sticky (it stays with the paragraph after it); the paragraph itself may break across pages.
      pending + piece
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: 12pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0.7em, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 3 a bold left sub-heading.
  show heading.where(level: 1): it => block(width: text-width, above: 1.0em, below: 0.8em, sticky: true,
    align(center, text(size: 13pt, weight: "bold", upper(it.body))))
  show heading.where(level: 3): it => block(width: text-width, above: 0.8em, below: 0.6em, sticky: true,
    text(weight: "bold", style: "italic", it.body))

  cover(meta)
  pagebreak()

  if "lead_in" in meta {
    set par(leading: body-leading)
    h(para-indent)
    inl(meta.lead_in)
    v(0.7em)
  }

  // Lettered prayer items (a), (b), ...
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  v(1.2em)
  block(breakable: false, signature-block(meta))
}
