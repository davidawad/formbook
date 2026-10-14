// Memorandum of law (motion brief) for the United States Bankruptcy Court, District of New Jersey (njb).
// Rules: D.N.J. LBR 9013-1(a)(3) (memorandum of law as a separate document, with the notice of motion,
// certifications, proposed order and certification of service as separate documents); FRBP 9004(a), (b)
// (legible; caption with court, title, case and adversary number, document designation); D.N.J. LBR 9004-1(a),
// (b) (attorney block top left; chapter, judge initials and hearing date in the caption); FRBP 9013(b) (motion
// states its grounds with particularity). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // the only vendored face (fonts/); see README.md, Known gaps
#let type-size = 14pt                   // convention: NJ filings in RECAP are 12 to 14 pt; see README.md
#let body-leading = 1.15em              // double-spaced feel at 14 pt, tuned against the exemplar (README.md)
#let single-leading = 0.45em            // counsel, caption and signature blocks
#let para-indent = 0.5in                // first-line indent of body paragraphs
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
  if m == none { panic("njb-motion-brief: the sample must start with a YAML frontmatter block") }
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
// Caption: counsel, court, case data, title of the paper
// ---------------------------------------------------------------------------

#let caption(meta) = {
  // LBR 9004-1(a): attorney of record and the party represented, top left of the first page.
  line-stack(meta.counsel)
  v(1.2em)
  align(center, text(weight: "bold", court-name.join("\n")))
  v(0.6em)
  align(right, text(size: 11pt, lbr-note))

  // LBR 9004-1(b): the chapter, the judge's initials and the hearing date are required in the caption.
  assert("hearing" in meta and meta.hearing != none,
    message: "njb-motion-brief: the caption needs a hearing date (D.N.J. LBR 9004-1(b))")

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
        + (meta.hearing,)
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
  align(center, text(weight: "bold", inl(meta.title)))
  v(0.8em)
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

/// The body: blank-line-separated markdown chunks. A heading is kept with the chunk after it; a paragraph is
/// indented and not numbered (memoranda of law in this court are not numbered by paragraph); a bracketed chunk
/// is an editorial note of the transcription, centered and italic.
#let body-text(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with("[") {
      pending + {
        set par(leading: body-leading)
        align(center, text(style: "italic", inl(t)))
        v(body-leading * 0.5)
      }
      pending = []
    } else {
      // Only the heading is sticky (it stays with the paragraph after it); the paragraph may break across pages.
      pending + {
        set par(leading: body-leading, spacing: 0.7em, first-line-indent: para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      }
      pending = []
    }
  }
  if pending != [] { pending }
}

#let motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: 12pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0.7em, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a bold left heading; level 3 bold italic.
  show heading.where(level: 1): it => block(width: text-width, above: 1.0em, below: 0.8em, sticky: true,
    align(center, text(size: 13pt, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: 0.9em, below: 0.6em, sticky: true,
    text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => block(width: text-width, above: 0.8em, below: 0.6em, sticky: true,
    text(size: type-size, weight: "bold", style: "italic", it.body))

  caption(meta)

  if "lead_in" in meta {
    set par(leading: body-leading, spacing: 0.7em, first-line-indent: para-indent)
    inl(meta.lead_in)
    v(0.7em)
  }

  body-text(body)

  v(1.2em)
  block(breakable: false, signature-block(meta))
}
