// Motion with supporting argument for the United States Bankruptcy Court, S.D. Indiana (insb).
// Rules: S.D.Ind. B-9013-1(a) (every request is a separate motion; it is named in the caption, states the order or
// relief sought, and contains a short and plain statement of its basis); Fed.R.Bankr.P. 9013(b) (a motion must
// state its grounds with particularity and set forth the relief requested); S.D.Ind. B-7007-1(a) (a Rule 12 motion
// needs a supporting brief, which may be combined with the motion in one document, 35-page limit); S.D.Ind. B-9013-2
// (a certificate of service accompanies a paper filed under Rule 9013 or 9014); Fed.R.Bankr.P. 9004(a) (clearly
// legible); S.D.Ind. B-5005-3 (no larger than 8-1/2 x 11). The S.D.Ind. Local Rules set no font, margin or line
// spacing: those are layout choices, marked as such in ../README.md.
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or is a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"      // layout choice: no S.D.Ind. font rule; vendored in fonts/
#let type-size = 12pt                 // layout choice: the Rule 9004(a) legibility floor is the only requirement
#let pitch = 27.6pt                   // layout choice: double spacing, matching the filed exemplar (27.6 pt baseline pitch, measured)
#let page-w = 8.5in                   // S.D.Ind. B-5005-3: no larger than 8-1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                     // layout choice
#let text-width = page-w - 2 * margin
#let body-leading = 1.65em            // double spacing: 0.65 em line box + 1.65 em leading = 27.6 pt at 12 pt (measured, README.md)
#let single-leading = 0.5em           // single spacing for the caption, the counsel and the signature block
#let para-indent = 0.5in              // first-line indent of body paragraphs
#let caption-left = 3.4in             // width of the party column of each caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("insb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown: a chunk of body text, rendered double spaced.
#let body-md(t) = {
  set par(leading: body-leading, spacing: 0pt, justify: false)
  cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
}

/// Fill whole lines: the block is rounded up to a multiple of `pitch`, so every paragraph ends on the
/// line grid and the next one cannot be drawn over it. `w` is the width the content is set at, so the
/// measurement matches the layout (a measure at a wider width under-counts the lines).
#let on-grid(c, w: text-width) = context {
  let h = measure(width: w, c).height
  block(width: w, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// A heading: one or more lines, kept with the chunk after it so it never ends a page.
#let heading-block(c) = block(width: text-width, above: pitch * 0.5, below: pitch * 0.5, sticky: true, on-grid(c))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (B-9013-1(a): the request is named in the caption)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, text(weight: "bold", [UNITED STATES BANKRUPTCY COURT])) + linebreak()
  align(center, text(weight: "bold", [SOUTHERN DISTRICT OF INDIANA])) + linebreak()
  if "division" in meta and meta.division != none {
    align(center, text(weight: "bold", upper(meta.division) + " DIVISION"))
  }
}

/// The bankruptcy caption: the debtor in the left column, the case number and chapter on the right.
#let bankruptcy-caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    line-stack(("In re:", "") + meta.debtor.names + (meta.debtor.designation,))
  }),
  block(inset: (left: 0.1in), line-stack((
    "Case No. " + meta.case_number,
    "Chapter " + meta.chapter,
  ))),
)

#let cover(meta) = {
  court-title(meta)
  v(pitch)
  bankruptcy-caption(meta)
  v(pitch)
  align(center, text(weight: "bold", inl(meta.title)))
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body, signature and certificate of service
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, {
  if "date_line" in meta and meta.date_line != none {
    on-grid({ set par(leading: body-leading); h(para-indent); inl(meta.date_line) })
  }
  v(pitch * 0.5)
  pad(left: 3in, block(width: 3.5in, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("/s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines)
  }))
})

/// Body chunks, each separated by a blank line in the sample:
///   `#` heading                    centered (level 1) or bold (level 2); kept with the next chunk
///   `> ...`                         block quotation, indented both sides, not indented on the first line
///   anything else                   paragraph, first-line indent (motions are not numbered)
/// Each chunk is measured at the width it is set at (see on-grid).
#let argument(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    let piece = if t.starts-with("#") {
      pending += body-md(t)
      has-pending = true
      none
    } else if t.starts-with(">") {
      let inner = t.split("\n").map(l => {
        let s = l.trim()
        if s.starts-with(">") { s = s.slice(1) }
        s.trim()
      }).join("\n")
      pad(left: 1in, right: 0.5in, on-grid(w: text-width - 1.5in, {
        set par(leading: single-leading, spacing: single-leading, justify: false)
        cmarker.render(inner, raw-typst: false, smart-punctuation: true)
      }))
    } else if t.match(regex("^(Id\\.|[0-9])")) != none {
      // A citation line that continues after a block quotation: flush left, not indented.
      on-grid({ set par(leading: body-leading); inl(t) })
    } else {
      on-grid({ set par(leading: body-leading); h(para-indent); inl(t) })
    }
    // A heading is held until the chunk after it, so it never ends a page.
    if piece != none {
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let certificate(meta) = {
  pagebreak()
  align(center, text(weight: "bold", [CERTIFICATE OF SERVICE]))
  v(pitch)
  on-grid({ set par(leading: body-leading); h(para-indent); inl(meta.certificate.text) })
  v(pitch)
  pad(left: 3in, block(width: 3.5in, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack((("/s/ " + meta.certificate.signer),) + meta.certificate.lines)
  }))
}

#let insb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: none,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  show heading.where(level: 1): it => heading-block(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(text(size: type-size, weight: "bold", it.body))

  cover(meta)
  argument(body)
  signature-block(meta)
  if "certificate" in meta and meta.certificate != none {
    certificate(meta)
  }
}
